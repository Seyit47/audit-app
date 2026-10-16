import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/location/location_hub.dart';

import '../../../core/router/app_router.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/settings/remote_config.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/widgets/photo_capture.dart';
import '../data/audit_local_repository.dart';
import '../domain/geofence.dart';

/// How old the phone's last known position may be when no fresh reading comes (indoors, weak GPS).
/// The tracker keeps it current during working hours; a minute is at most ~80 m on foot.
const lastKnownMaxAge = Duration(seconds: 60);

/// A reading this recent is current: no need to wait for the next one.
const instantMaxAge = Duration(seconds: 15);

/// Precise enough to stop refining: GPS outdoors reaches 3–10 m within seconds.
const goodAccuracyM = 15.0;

/// How long a check keeps refining before it settles on the best reading it got.
const refineFor = Duration(seconds: 12);

bool freshEnough(DateTime at, DateTime now, {Duration maxAge = lastKnownMaxAge}) => now.difference(at) <= maxAge;

/// Whether a known position can be used without asking GPS again.
bool usableAtOnce({required DateTime at, required double accuracyM, required DateTime now}) =>
    freshEnough(at, now, maxAge: instantMaxAge) && accuracyM <= goodAccuracyM;

/// Location for the audit and new-shop checks, from the app's shared stream ([LocationHub]): the best
/// position so far at once, then each more precise reading as GPS sharpens, until one is within
/// [goodAccuracyM] or [refineFor] has passed. A reading counts once it is within the company limit (the
/// screens check that); a position older than [instantMaxAge] is shown as provisional only.
class GeolocatorLocator extends Locator {
  GeolocatorLocator(this._hub, {this.refine = refineFor});

  final LocationHub _hub;
  final Duration refine;

  @override
  Future<Fix?> current() => watch().last;

  @override
  Stream<Fix?> watch() async* {
    try {
      // Location off: say so at once instead of waiting for a timeout.
      if (!await Geolocator.isLocationServiceEnabled()) {
        yield null;
        return;
      }
    } catch (_) {}
    _hub.acquire();
    try {
      final now = DateTime.now();
      final known = _hub.latest ?? await _lastKnown();
      Fix? best;
      if (known != null && freshEnough(known.timestamp, now, maxAge: instantMaxAge)) {
        yield best = _fix(known);
        if (known.accuracy <= goodAccuracyM) return;
      } else if (known != null && freshEnough(known.timestamp, now)) {
        yield best = _fix(known, provisional: true);
      }
      // Each sharper reading as it arrives.
      final end = DateTime.now().add(refine);
      final readings = StreamIterator(_hub.positions);
      try {
        while (true) {
          final left = end.difference(DateTime.now());
          if (left <= Duration.zero || !await readings.moveNext().timeout(left, onTimeout: () => false)) break;
          final p = readings.current;
          if (best == null || best.provisional || p.accuracy < best.accuracyM) yield best = _fix(p);
          if (p.accuracy <= goodAccuracyM) return;
        }
      } finally {
        await readings.cancel();
      }
      if (best != null && !best.provisional) return;
      // No reading at all (indoors, no signal): a recent position from the system counts.
      final last = await _lastKnown();
      if (last != null && freshEnough(last.timestamp, DateTime.now())) {
        yield _fix(last);
      } else if (best == null) {
        yield null;
      }
    } finally {
      _hub.release();
    }
  }

  static Fix _fix(Position p, {bool provisional = false}) => Fix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy, provisional: provisional);

  static Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }
}

final photoCaptureProvider = Provider<PhotoCapture>((ref) => CameraPhotoCapture(() => rootNavigatorKey.currentState));
final locatorProvider = Provider<Locator>((ref) => GeolocatorLocator(ref.watch(locationHubProvider)));

/// Sends the outbox right after "Завершить аудит" (T092) or a new shop; tests replace it.
/// Only a push: the full pull runs on app start, resume, reconnect and the 15-minute timer.
final syncTriggerProvider = Provider<void Function()>(
  (ref) =>
      () => unawaited(ref.read(syncControllerProvider.notifier).pushNow()),
);

class AuditState {
  const AuditState({this.shop, this.draft, this.photos = const [], this.fix, this.geo = GeoStatus.locating, this.finishing = false, this.finished = false});

  final Shop? shop;
  final AuditDraft? draft;
  final List<Photo> photos;
  final Fix? fix;
  final GeoStatus geo;
  final bool finishing;
  final bool finished;

  String get comment => draft?.comment ?? '';
  bool get hasViolation => draft?.hasViolation ?? false;
  bool get canAddPhoto => draft != null && photos.length < AuditLocalRepository.maxPhotos;

  /// "Завершить аудит": inside the shop radius, at least one photo and a comment
  /// (a recorded violation still needs the comment).
  bool get canFinish => geo == GeoStatus.inside && !(fix?.provisional ?? true) && photos.isNotEmpty && comment.trim().isNotEmpty && !finishing && !finished;

  AuditState copyWith({Shop? shop, AuditDraft? draft, List<Photo>? photos, Fix? fix, GeoStatus? geo, bool? finishing, bool? finished}) => AuditState(
    shop: shop ?? this.shop,
    draft: draft ?? this.draft,
    photos: photos ?? this.photos,
    fix: fix ?? this.fix,
    geo: geo ?? this.geo,
    finishing: finishing ?? this.finishing,
    finished: finished ?? this.finished,
  );
}

/// The audit screen's state for one shop (T090): locate and check the geofence, keep the draft,
/// take photos, and finish into the outbox.
class AuditController extends Notifier<AuditState> {
  AuditController(this.shopId);

  final String shopId;
  StreamSubscription<List<Photo>>? _photos;

  AuditLocalRepository get _repo => ref.read(auditLocalRepositoryProvider);

  @override
  AuditState build() {
    ref.onDispose(() => _photos?.cancel());
    Future.microtask(_start);
    return const AuditState();
  }

  Future<void> _start() async {
    final db = ref.read(databaseProvider);
    final shop = await (db.select(db.shops)..where((s) => s.id.equals(shopId))).getSingleOrNull();
    final draft = await _repo.openDraft(shopId);
    if (!ref.mounted) return;
    state = state.copyWith(shop: shop, draft: draft);
    _photos = _repo.watchDraftPhotos(draft.auditId).listen((photos) {
      if (ref.mounted) state = state.copyWith(photos: photos.where((p) => p.status == 'DRAFT').toList());
    });
    await locate();
  }

  /// The "Проверить заново" button and the first check on open.
  Future<void> locate() async {
    state = state.copyWith(geo: GeoStatus.locating);
    // The last known position at once, then the GPS fix when it answers.
    await for (final fix in ref.read(locatorProvider).watch()) {
      if (!ref.mounted) return;
      _apply(fix);
    }
  }

  void _apply(Fix? fix) {
    final shop = state.shop;
    final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final geo = shop == null
        ? GeoStatus.unavailable
        : shop.status != 'ACTIVE'
        ? GeoStatus.notActive
        : geofence(fix: fix, shopLat: shop.lat, shopLng: shop.lng, radiusM: shop.auditRadiusM, minAccuracyM: config.minGpsAccuracyM);
    state = AuditState(shop: shop, draft: state.draft, photos: state.photos, fix: fix, geo: geo, finishing: state.finishing, finished: state.finished);
  }

  Future<void> takePhoto() async {
    final draft = state.draft;
    if (draft == null || !state.canAddPhoto) return;
    final photo = await ref.read(photoCaptureProvider).capture(fix: state.fix);
    if (photo != null) await _repo.addPhoto(draft, photo);
  }

  Future<void> removePhoto(Photo photo) => _repo.removePhoto(photo);

  Future<void> setComment(String comment) => _saveText(comment: comment);

  Future<void> toggleViolation() => _saveText(hasViolation: !state.hasViolation);

  Future<void> _saveText({String? comment, bool? hasViolation}) async {
    await _repo.saveText(shopId, comment: comment, hasViolation: hasViolation);
    final db = ref.read(databaseProvider);
    final draft = await (db.select(db.auditDrafts)..where((d) => d.shopId.equals(shopId))).getSingleOrNull();
    if (ref.mounted && draft != null) state = state.copyWith(draft: draft);
  }

  /// Saves the audit and its photos to the outbox; returns its outbox item, or null when it may not finish yet.
  Future<String?> finish() async {
    final draft = state.draft;
    final fix = state.fix;
    final shop = state.shop;
    if (!state.canFinish || draft == null || fix == null || shop == null) return null;
    state = state.copyWith(finishing: true);
    final distance = distanceMeters(fix.lat, fix.lng, shop.lat, shop.lng);
    final item = await _repo.finish(
      draft,
      FinishedAudit(finishedAt: DateTime.now().toUtc(), fix: fix, distanceM: distance.round(), withinRadius: distance <= shop.auditRadiusM),
    );
    ref.read(syncTriggerProvider)();
    if (ref.mounted) state = state.copyWith(finishing: false, finished: true);
    return item;
  }
}

final auditControllerProvider = NotifierProvider.autoDispose.family<AuditController, AuditState, String>(AuditController.new);
