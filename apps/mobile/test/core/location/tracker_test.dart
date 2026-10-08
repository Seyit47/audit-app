import 'dart:convert';

import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/location/tracker.dart';
import 'package:audit_mobile/core/sync/outbox_repository.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collection is gated', () {
    final day = DateTime(2026, 10, 7, 10);
    bool gate({bool signedIn = true, String status = 'ACTIVE', DateTime? now}) =>
        shouldCollect(signedIn: signedIn, workStatus: status, workStart: '08:00', workEnd: '19:00', now: now ?? day);

    test('only signed in, ACTIVE and within working hours', () {
      expect(gate(), isTrue);
      expect(gate(signedIn: false), isFalse);
      expect(gate(status: 'ON_LEAVE'), isFalse);
      expect(gate(now: DateTime(2026, 10, 7, 7, 59)), isFalse);
      expect(gate(now: DateTime(2026, 10, 7, 19, 0)), isFalse);
      expect(gate(now: DateTime(2026, 10, 7, 18, 59)), isTrue);
    });
  });

  group('ping decider', () {
    final t0 = DateTime.utc(2026, 10, 7, 6);
    const here = Fix(lat: 37.95, lng: 58.38, accuracyM: 5);
    const near = Fix(lat: 37.95, lng: 58.38015, accuracyM: 5); // ~13 m
    const moved = Fix(lat: 37.95, lng: 58.3805, accuracyM: 5); // ~44 m

    test('a 2-minute heartbeat and a 25 m movement filter', () {
      final d = PingDecider();
      expect(d.onFix(here, t0), hasLength(1));
      expect(d.onFix(near, t0.add(const Duration(seconds: 30))), isEmpty);
      expect(d.onFix(moved, t0.add(const Duration(seconds: 40))).single.trigger, 'HEARTBEAT');
      expect(d.onFix(moved, t0.add(const Duration(seconds: 100))), isEmpty);
      expect(d.onFix(moved, t0.add(const Duration(seconds: 161))), hasLength(1));
    });

    test("GEOFENCE_ENTER and GEOFENCE_EXIT for today's stops", () {
      final d = PingDecider(zones: const [Zone(id: 's1', lat: 37.95, lng: 58.39, radiusM: 100)]);
      expect(d.onFix(here, t0).map((p) => p.trigger), ['HEARTBEAT']);
      const inside = Fix(lat: 37.95, lng: 58.3895, accuracyM: 5);
      expect(d.onFix(inside, t0.add(const Duration(seconds: 10))).map((p) => p.trigger), ['GEOFENCE_ENTER']);
      expect(d.onFix(inside, t0.add(const Duration(seconds: 20))), isEmpty);
      expect(d.onFix(here, t0.add(const Duration(seconds: 30))).map((p) => p.trigger), ['GEOFENCE_EXIT']);
    });
  });

  test('pings are buffered and uploaded in batches of at most 200', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final outbox = OutboxRepository(db);
    final buffer = PingBuffer(db, outbox);
    final t0 = DateTime.utc(2026, 10, 7, 6);
    for (var i = 0; i < 450; i++) {
      await buffer.add(
        Ping(
          recordedAt: t0.add(Duration(minutes: i)),
          fix: const Fix(lat: 37.95, lng: 58.38, accuracyM: 5),
          trigger: 'HEARTBEAT',
          batteryPct: 80,
        ),
      );
    }
    await buffer.flush();
    final items = await db.select(db.outbox).get();
    expect(items.map((o) => o.kind).toSet(), {OutboxKind.pings});
    expect([for (final o in items) ((jsonDecode(o.payloadJson) as Map)['pings'] as List).length], [200, 200, 50]);
    expect(await db.select(db.pingsBuffer).get(), isEmpty);
    final first = ((jsonDecode(items.first.payloadJson) as Map)['pings'] as List).first as Map;
    expect(first['batteryPct'], 80);
    expect(first['trigger'], 'HEARTBEAT');
  });
}
