import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/sync/outbox_repository.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/widgets/photo_capture.dart';
import '../domain/geofence.dart';

/// What "Завершить аудит" records.
class FinishedAudit {
  const FinishedAudit({required this.finishedAt, required this.fix, required this.distanceM, required this.withinRadius});

  final DateTime finishedAt;
  final Fix fix;
  final int distanceM;
  final bool withinRadius;
}

/// Audit drafts and their photos on the device, and the finish that queues the outbox.
class AuditLocalRepository {
  AuditLocalRepository(this._db, this._outbox, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final OutboxRepository _outbox;
  final DateTime Function() _clock;

  static const maxPhotos = 20;

  /// The shop's open draft, or a new one (with today's stop for the shop, if any).
  Future<AuditDraft> openDraft(String shopId) async {
    final existing = await (_db.select(_db.auditDrafts)..where((d) => d.shopId.equals(shopId))).getSingleOrNull();
    if (existing != null) return existing;
    final stop = await (_db.select(_db.routeStops)
          ..where((s) => s.shopId.equals(shopId) & s.status.isIn(const ['PLANNED', 'IN_PROGRESS']))
          ..limit(1))
        .getSingleOrNull();
    final draft = AuditDraftsCompanion.insert(shopId: shopId, auditId: const Uuid().v7(), routeStopId: Value(stop?.id), startedAt: _clock().toUtc());
    await _db.into(_db.auditDrafts).insert(draft);
    if (stop != null) {
      await (_db.update(_db.routeStops)..where((s) => s.id.equals(stop.id))).write(const RouteStopsCompanion(status: Value('IN_PROGRESS')));
    }
    return (_db.select(_db.auditDrafts)..where((d) => d.shopId.equals(shopId))).getSingle();
  }

  Stream<List<Photo>> watchDraftPhotos(String auditId) => (_db.select(_db.photos)
        ..where((p) => p.auditId.equals(auditId))
        ..orderBy([(p) => OrderingTerm(expression: p.takenAt)]))
      .watch();

  Future<void> addPhoto(AuditDraft draft, CapturedPhoto photo) => _db.into(_db.photos).insert(PhotosCompanion.insert(
        id: photo.id,
        kind: 'AUDIT',
        auditId: Value(draft.auditId),
        shopId: Value(draft.shopId),
        localPath: Value(photo.path),
        mime: 'image/jpeg',
        sizeBytes: photo.sizeBytes,
        sha256: photo.sha256,
        takenAt: photo.takenAt,
        lat: Value(photo.fix?.lat),
        lng: Value(photo.fix?.lng),
        accuracyM: Value(photo.fix?.accuracyM),
        status: const Value('DRAFT'),
      ));

  Future<void> removePhoto(Photo photo) async {
    await (_db.delete(_db.photos)..where((p) => p.id.equals(photo.id))).go();
    final path = photo.localPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> saveText(String shopId, {String? comment, bool? hasViolation}) =>
      (_db.update(_db.auditDrafts)..where((d) => d.shopId.equals(shopId))).write(AuditDraftsCompanion(
        comment: comment == null ? const Value.absent() : Value(comment),
        hasViolation: hasViolation == null ? const Value.absent() : Value(hasViolation),
      ));

  /// One transaction: the local audit, PHOTO items, then AUDIT_CREATE depending on them, the stop
  /// and shop marked visited, and the draft removed (contracts/sync.md).
  Future<void> finish(AuditDraft draft, FinishedAudit done) => _db.transaction(() async {
        final photos = await (_db.select(_db.photos)..where((p) => p.auditId.equals(draft.auditId))).get();
        final comment = draft.comment.trim();
        await _db.into(_db.audits).insert(AuditsCompanion.insert(
              id: draft.auditId,
              shopId: draft.shopId,
              routeStopId: Value(draft.routeStopId),
              startedAtDevice: draft.startedAt,
              finishedAtDevice: done.finishedAt,
              lat: done.fix.lat,
              lng: done.fix.lng,
              gpsAccuracyM: done.fix.accuracyM,
              distanceM: Value(done.distanceM),
              withinRadius: Value(done.withinRadius),
              comment: comment,
              hasViolation: Value(draft.hasViolation),
            ));
        final photoItems = <String>[];
        for (final p in photos) {
          photoItems.add(await _outbox.enqueue(OutboxKind.photo, {
            'id': p.id,
            'kind': 'AUDIT',
            'mime': p.mime,
            'sizeBytes': p.sizeBytes,
            'sha256': p.sha256,
            'takenAt': p.takenAt.toUtc().toIso8601String(),
            'lat': ?p.lat,
            'lng': ?p.lng,
            'accuracyM': ?p.accuracyM,
            'localPath': p.localPath,
          }));
        }
        await (_db.update(_db.photos)..where((p) => p.auditId.equals(draft.auditId))).write(const PhotosCompanion(status: Value('PENDING_UPLOAD')));
        await _outbox.enqueue(OutboxKind.auditCreate, {
          'id': draft.auditId,
          'shopId': draft.shopId,
          'routeStopId': ?draft.routeStopId,
          'startedAt': draft.startedAt.toUtc().toIso8601String(),
          'finishedAt': done.finishedAt.toUtc().toIso8601String(),
          'lat': done.fix.lat,
          'lng': done.fix.lng,
          'accuracyM': done.fix.accuracyM,
          'comment': comment,
          'hasViolation': draft.hasViolation,
          'photoIds': [for (final p in photos) p.id],
        }, dependsOn: photoItems);
        if (draft.routeStopId != null) {
          await (_db.update(_db.routeStops)..where((s) => s.id.equals(draft.routeStopId!)))
              .write(RouteStopsCompanion(status: const Value('DONE'), auditId: Value(draft.auditId)));
        }
        await (_db.update(_db.shops)..where((s) => s.id.equals(draft.shopId))).write(ShopsCompanion(lastVisitAt: Value(done.finishedAt)));
        await (_db.delete(_db.auditDrafts)..where((d) => d.shopId.equals(draft.shopId))).go();
      });
}

final auditLocalRepositoryProvider = Provider<AuditLocalRepository>((ref) => AuditLocalRepository(ref.watch(databaseProvider), ref.watch(outboxProvider)));
