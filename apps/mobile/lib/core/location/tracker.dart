import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/audit/domain/geofence.dart';
import '../../features/route/data/route_local_repository.dart';
import '../auth/session.dart';
import '../auth/session_provider.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../router/app_router.dart';
import '../settings/remote_config.dart';
import '../sync/outbox_repository.dart';
import '../sync/sync_providers.dart';

/// Tracking (FR-017, research R-11): only while signed in as an ACTIVE agent within working hours.
/// Working hours are compared in the device's local time, which is the company time zone in the
/// field (Asia/Ashgabat).
bool shouldCollect({required bool signedIn, required String workStatus, required String workStart, required String workEnd, required DateTime now}) {
  if (!signedIn || workStatus != 'ACTIVE') return false;
  int minutes(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  final m = now.hour * 60 + now.minute;
  return m >= minutes(workStart) && m < minutes(workEnd);
}

/// A shop zone of today's route for the geofence pings.
class Zone {
  const Zone({required this.id, required this.lat, required this.lng, required this.radiusM});

  final String id;
  final double lat;
  final double lng;
  final int radiusM;
}

class Ping {
  const Ping({required this.recordedAt, required this.fix, required this.trigger, this.speedKmh, this.batteryPct});

  final DateTime recordedAt;
  final Fix fix;
  final String trigger;
  final double? speedKmh;
  final int? batteryPct;
}

/// Keeps a fix when the agent moved 25 m or 2 minutes passed (heartbeat), and adds
/// GEOFENCE_ENTER / GEOFENCE_EXIT when a route shop's zone is entered or left.
class PingDecider {
  PingDecider({this.zones = const []});

  static const minMove = 25.0;
  static const heartbeat = Duration(minutes: 2);

  List<Zone> zones;
  Fix? _last;
  DateTime? _lastAt;
  final _inside = <String>{};

  List<Ping> onFix(Fix fix, DateTime at, {double? speedKmh, int? batteryPct}) {
    final out = <Ping>[];
    Ping ping(String trigger) => Ping(recordedAt: at, fix: fix, trigger: trigger, speedKmh: speedKmh, batteryPct: batteryPct);
    for (final z in zones) {
      final inside = distanceMeters(fix.lat, fix.lng, z.lat, z.lng) <= z.radiusM;
      if (inside && _inside.add(z.id)) out.add(ping('GEOFENCE_ENTER'));
      if (!inside && _inside.remove(z.id)) out.add(ping('GEOFENCE_EXIT'));
    }
    final last = _last;
    final due = last == null || at.difference(_lastAt!) >= heartbeat || distanceMeters(last.lat, last.lng, fix.lat, fix.lng) >= minMove;
    if (out.isEmpty && due) out.add(ping('HEARTBEAT'));
    if (out.isNotEmpty) {
      _last = fix;
      _lastAt = at;
    }
    return out;
  }
}

/// `pings_buffer` → outbox PINGS items of at most 200 (contracts/sync.md).
class PingBuffer {
  PingBuffer(this._db, this._outbox);

  final AppDatabase _db;
  final OutboxRepository _outbox;

  static const batch = 200;

  Future<void> add(Ping p) => _db
      .into(_db.pingsBuffer)
      .insert(
        PingsBufferCompanion.insert(
          recordedAt: p.recordedAt,
          lat: p.fix.lat,
          lng: p.fix.lng,
          accuracyM: p.fix.accuracyM,
          speedKmh: Value(p.speedKmh),
          batteryPct: Value(p.batteryPct),
          trigger: Value(p.trigger),
        ),
      );

  Future<void> flush() => _db.transaction(() async {
    final rows = await (_db.select(_db.pingsBuffer)..orderBy([(p) => OrderingTerm(expression: p.id)])).get();
    for (var i = 0; i < rows.length; i += batch) {
      final chunk = rows.sublist(i, i + batch > rows.length ? rows.length : i + batch);
      await _outbox.enqueue(OutboxKind.pings, {
        'pings': [
          for (final r in chunk)
            {
              'recordedAt': r.recordedAt.toUtc().toIso8601String(),
              'lat': r.lat,
              'lng': r.lng,
              'accuracyM': r.accuracyM,
              'speedKmh': ?r.speedKmh,
              'batteryPct': ?r.batteryPct,
              'trigger': r.trigger,
            },
        ],
      });
    }
    if (rows.isNotEmpty) await _db.delete(_db.pingsBuffer).go();
  });
}

/// Runs the location stream while [shouldCollect] holds; re-checked every minute and whenever the
/// session, settings or route change. Android shows the required foreground notification.
class Tracker {
  Tracker(this._ref);

  final Ref _ref;
  StreamSubscription<Position>? _positions;
  Timer? _tick;
  final _decider = PingDecider();
  final _battery = Battery();
  Position? _lastPosition;
  DateTime _lastFlush = DateTime.now();

  void start() {
    _tick ??= Timer.periodic(const Duration(minutes: 1), (_) => _evaluate());
    _evaluate();
  }

  void dispose() {
    _tick?.cancel();
    _tick = null;
    _stopStream();
  }

  Future<void> _evaluate() async {
    final user = _ref.read(sessionProvider).value;
    final config = _ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final on =
        _ref.read(locationGrantedProvider) &&
        shouldCollect(
          signedIn: user?.role == Role.agent,
          workStatus: config.workStatus,
          workStart: config.workStart,
          workEnd: config.workEnd,
          now: DateTime.now(),
        );
    if (!on) {
      _stopStream();
      await _flush();
      return;
    }
    await _updateZones();
    _positions ??= Geolocator.getPositionStream(locationSettings: _settings()).listen(_onPosition, onError: (_) => _stopStream());
    // Heartbeat while standing still: the stream only fires on movement.
    final last = _lastPosition;
    if (last != null) await _onPosition(last, at: DateTime.now());
    if (DateTime.now().difference(_lastFlush) >= const Duration(minutes: 5)) await _flush();
  }

  Future<void> _updateZones() async {
    final db = _ref.read(databaseProvider);
    final stops = await _ref.read(routeLocalRepositoryProvider).watchStops().first;
    final shops = {for (final s in await (db.select(db.shops)..where((s) => s.id.isIn(stops.map((st) => st.shopId)))).get()) s.id: s};
    _decider.zones = [
      for (final st in stops)
        if (shops[st.shopId] case final s?) Zone(id: s.id, lat: s.lat, lng: s.lng, radiusM: s.auditRadiusM),
    ];
  }

  Future<void> _onPosition(Position p, {DateTime? at}) async {
    _lastPosition = p;
    int? battery;
    try {
      battery = await _battery.batteryLevel;
    } catch (_) {}
    final pings = _decider.onFix(
      Fix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy),
      (at ?? p.timestamp).toUtc(),
      speedKmh: p.speed >= 0 ? p.speed * 3.6 : null,
      batteryPct: battery,
    );
    final buffer = PingBuffer(_ref.read(databaseProvider), _ref.read(outboxProvider));
    for (final ping in pings) {
      await buffer.add(ping);
    }
  }

  Future<void> _flush() async {
    _lastFlush = DateTime.now();
    await PingBuffer(_ref.read(databaseProvider), _ref.read(outboxProvider)).flush();
  }

  void _stopStream() {
    _positions?.cancel();
    _positions = null;
  }

  LocationSettings _settings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: PingDecider.minMove.toInt(),
        intervalDuration: const Duration(seconds: 30),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Аудит',
          notificationText: 'Рабочее время: отслеживание маршрута',
          enableWakeLock: true,
        ),
      );
    }
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: PingDecider.minMove.toInt(),
      showBackgroundLocationIndicator: true,
      pauseLocationUpdatesAutomatically: false,
    );
  }
}

/// Started by the app for the agent role; follows the session, settings and permission.
final trackerProvider = Provider<Tracker>((ref) {
  final tracker = Tracker(ref);
  ref.listen(sessionProvider, (_, _) => tracker.start());
  ref.listen(remoteConfigProvider, (_, _) => tracker.start());
  ref.listen(locationGrantedProvider, (_, _) => tracker.start());
  ref.onDispose(tracker.dispose);
  tracker.start();
  return tracker;
});
