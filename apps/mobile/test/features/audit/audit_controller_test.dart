import 'dart:convert';

import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/sync/pull_service.dart';
import 'package:audit_mobile/core/widgets/photo_capture.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeLocator implements Locator {
  Fix? next;

  @override
  Future<Fix?> current() async => next;
}

class FakeCapture implements PhotoCapture {
  var n = 0;

  @override
  Future<CapturedPhoto?> capture({Fix? fix}) async =>
      CapturedPhoto(id: 'photo-${n++}', path: '/tmp/none-$n.jpg', sizeBytes: 100, sha256: 'h$n', takenAt: DateTime.utc(2026, 10, 7, 9, n), fix: fix);
}

const shopLat = 37.95;
const shopLng = 58.38;
const inside = Fix(lat: shopLat, lng: shopLng + 0.0005, accuracyM: 8); // ~44 m away
const outside = Fix(lat: shopLat, lng: shopLng + 0.01, accuracyM: 8); // ~880 m away
const blurry = Fix(lat: shopLat, lng: shopLng, accuracyM: 120);

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late FakeLocator locator;
  late int syncs;

  Future<ProviderContainer> open({Fix? fix = inside}) async {
    locator.next = fix;
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        locatorProvider.overrideWithValue(locator),
        photoCaptureProvider.overrideWithValue(FakeCapture()),
        syncTriggerProvider.overrideWithValue(() => syncs++),
      ],
    );
    c.listen(auditControllerProvider('s1'), (_, _) {});
    // Let the draft open, the photo stream start and the location check run.
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    return c;
  }

  AuditController ctrl() => container.read(auditControllerProvider('s1').notifier);
  AuditState state() => container.read(auditControllerProvider('s1'));
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 30));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    locator = FakeLocator();
    syncs = 0;
    await db
        .into(db.shops)
        .insert(
          ShopsCompanion.insert(
            id: 's1',
            code: 'CL-1',
            name: 'Shop',
            type: 'MARKET',
            address: 'Street',
            lat: shopLat,
            lng: shopLng,
            auditRadiusM: 100,
            status: 'ACTIVE',
            updatedAt: DateTime.utc(2026, 10, 7),
          ),
        );
    await db
        .into(db.syncCursors)
        .insert(
          SyncCursorsCompanion.insert(
            name: PullService.meCursor,
            value: jsonEncode({
              'config': {'minGpsAccuracyM': 50},
            }),
            updatedAt: DateTime.utc(2026, 10, 7),
          ),
        );
    await db.into(db.routes).insert(RoutesCompanion.insert(id: 'r1', date: DateTime.utc(2026, 10, 7), updatedAt: DateTime.utc(2026, 10, 7)));
    await db
        .into(db.routeStops)
        .insert(
          RouteStopsCompanion.insert(
            id: 'st1',
            routeId: 'r1',
            shopId: 's1',
            position: 0,
            plannedAt: DateTime.utc(2026, 10, 7, 4),
            isAuditTask: true,
            status: 'PLANNED',
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('the geofence and accuracy check use the cached shop', () async {
    container = await open(fix: outside);
    expect(state().geo, GeoStatus.outside);
    locator.next = blurry;
    await ctrl().locate();
    expect(state().geo, GeoStatus.inaccurate);
    locator.next = inside;
    await ctrl().locate();
    expect(state().geo, GeoStatus.inside);
    expect(state().shop!.name, 'Shop');
  });

  test('a shop pending review cannot be audited, even standing inside its radius', () async {
    await (db.update(db.shops)..where((x) => x.id.equals('s1'))).write(const ShopsCompanion(status: Value('PENDING_REVIEW')));
    container = await open();
    expect(state().geo, GeoStatus.notActive);
    expect(state().canFinish, isFalse);
  });

  test('Finish needs at least one photo and a comment, inside the radius', () async {
    container = await open();
    expect(state().canFinish, isFalse);
    await ctrl().takePhoto();
    await settle();
    expect(state().photos, hasLength(1));
    expect(state().canFinish, isFalse);
    await ctrl().setComment('   ');
    expect(state().canFinish, isFalse);
    await ctrl().setComment('Все ценники на месте');
    expect(state().canFinish, isTrue);
    locator.next = outside;
    await ctrl().locate();
    expect(state().canFinish, isFalse);
  });

  test('at most 20 photos', () async {
    container = await open();
    for (var i = 0; i < 22; i++) {
      await ctrl().takePhoto();
      await settle();
    }
    expect(state().photos, hasLength(20));
    expect(state().canAddPhoto, isFalse);
  });

  test('the draft is restored after a restart', () async {
    container = await open();
    await ctrl().takePhoto();
    await ctrl().setComment('Черновик');
    await ctrl().toggleViolation();
    await settle();
    final auditId = state().draft!.auditId;
    container.dispose();

    container = await open();
    expect(state().draft!.auditId, auditId);
    expect(state().comment, 'Черновик');
    expect(state().hasViolation, isTrue);
    expect(state().photos, hasLength(1));
  });

  test('the violation chip toggles hasViolation and the comment stays required', () async {
    container = await open();
    await ctrl().takePhoto();
    await settle();
    await ctrl().toggleViolation();
    expect(state().hasViolation, isTrue);
    expect(state().canFinish, isFalse);
    await ctrl().setComment('Нет ценников');
    expect(state().canFinish, isTrue);
    await ctrl().toggleViolation();
    expect(state().hasViolation, isFalse);
  });

  test('Finish enqueues PHOTO items, then AUDIT_CREATE depending on them, and triggers a sync', () async {
    container = await open();
    await ctrl().takePhoto();
    await ctrl().takePhoto();
    await ctrl().toggleViolation();
    await ctrl().setComment('Стойка перекрыта');
    await settle();
    expect(await ctrl().finish(), isTrue);

    final items = await (db.select(db.outbox)..orderBy([(o) => OrderingTerm(expression: o.createdAt)])).get();
    final photos = items.where((o) => o.kind == OutboxKind.photo).toList();
    final audit = items.singleWhere((o) => o.kind == OutboxKind.auditCreate);
    expect(photos, hasLength(2));
    expect((jsonDecode(audit.dependsOn) as List).toSet(), {for (final p in photos) p.id});
    final body = jsonDecode(audit.payloadJson) as Map<String, dynamic>;
    expect(body['hasViolation'], isTrue);
    expect(body['routeStopId'], 'st1');
    expect((body['photoIds'] as List), hasLength(2));
    expect((await db.select(db.routeStops).getSingle()).status, 'DONE');
    expect(await db.select(db.auditDrafts).get(), isEmpty);
    expect((await db.select(db.audits).getSingle()).synced, isFalse);
    expect(syncs, 1);
    expect(state().finished, isTrue);
  });
}
