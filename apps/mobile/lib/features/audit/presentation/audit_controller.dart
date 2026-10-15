import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/router/app_router.dart';
import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/settings/remote_config.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/widgets/photo_capture.dart';
import '../data/audit_local_repository.dart';
import '../domain/geofence.dart';

/// How old the phone's last known position may be when a fresh fix can't be had (indoors, weak GPS).
/// The tracker keeps it current during working hours; a minute is at most ~80 m on foot.
const lastKnownMaxAge = Duration(seconds: 60);

/// A position the system already has is used at once when this recent and precise: no waiting for GPS.
const instantMaxAge = Duration(seconds: 15);
const instantMaxAccuracyM = 30.0;

bool freshEnough(DateTime at, DateTime now, {Duration maxAge = lastKnownMaxAge}) => now.difference(at) <= maxAge;

/// Whether a known position can be used without asking GPS again.
bool usableAtOnce({required DateTime at, required double accuracyM, required DateTime now}) =>
    freshEnough(at, now, maxAge: instantMaxAge) && accuracyM <= instantMaxAccuracyM;

class GeolocatorLocator implements Locator {
  @override
  Future<Fix?> current() async {
    try {
      // Location off: say so at once instead of waiting for a timeout.
      if (!await Geolocator.isLocationServiceEnabled()) return null;
    } catch (_) {}
    // 1. What the system already knows (the tracker keeps it warm during working hours): instant.
    final known = await _lastKnown();
    if (known != null && usableAtOnce(at: known.timestamp, accuracyM: known.accuracy, now: DateTime.now())) return _fix(known);
    // 2. A fresh fix, at most 10 s.
    try {
      return _fix(
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 10)),
        ),
      );
    } catch (_) {
      // 3. Timed out (indoors, weak GPS): a recent position from the system, the tracker's included.
      final last = await _lastKnown();
      return last != null && freshEnough(last.timestamp, DateTime.now()) ? _fix(last) : null;
    }
  }

  static Fix _fix(Position p) => Fix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy);

  static Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }
}

final photoCaptureProvider = Provider<PhotoCapture>((ref) => CameraPhotoCapture(() => rootNavigatorKey.currentState));
final locatorProvider = Provider<Locator>((ref) => GeolocatorLocator());

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
  bool get canFinish => geo == GeoStatus.inside && photos.isNotEmpty && comment.trim().isNotEmpty && !finishing && !finished;

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
    final fix = await ref.read(locatorProvider).current();
    if (!ref.mounted) return;
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
