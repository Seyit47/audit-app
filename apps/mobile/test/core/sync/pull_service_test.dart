import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/sync/outbox_repository.dart';
import 'package:audit_mobile/core/sync/pull_service.dart';
import 'package:audit_mobile/core/sync/sync_api.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sync_api.dart';

Map<String, Object?> shopJson(String id, {List<Map<String, Object?>> contacts = const []}) => {
  'id': id,
  'code': 'CL-$id',
  'name': 'Shop $id',
  'type': 'MARKET',
  'address': 'Street 1',
  'addressDetail': null,
  'regionId': 'r1',
  'region': {'id': 'r1', 'name': 'Region 1'},
  'lat': 37.95,
  'lng': 58.38,
  'auditRadiusM': 100,
  'ownerName': null,
  'facade': null,
  'status': 'ACTIVE',
  'lastVisitAt': null,
  'nextDueAt': '2026-10-07T00:00:00.000Z',
  'contacts': contacts,
  'latestVisits': const [],
  'updatedAt': '2026-10-06T08:00:00.000Z',
};

void main() {
  late AppDatabase db;
  late FakeApi api;
  late OutboxRepository outbox;
  late PullService pull;
  final now = DateTime.utc(2026, 10, 7, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    outbox = OutboxRepository(db, clock: () => now);
    pull = PullService(db: db, api: api, outbox: outbox, clock: () => now);
  });
  tearDown(() => db.close());

  test('shops and their contacts land in drift and the cursor advances', () async {
    api.shopsPage = ShopsPage(
      items: [
        ShopRecord(
          json: shopJson(
            's1',
            contacts: [
              {'id': 'c1', 'phone': '+99362112233', 'label': 'Владелец', 'position': 0},
            ],
          ),
        ),
        ShopRecord(json: shopJson('s2')),
      ],
      tombstones: const [],
      cursor: 'cursor-1',
    );
    await pull.pullAll();

    expect((await db.select(db.shops).get()).map((s) => s.id), unorderedEquals(['s1', 's2']));
    expect((await db.select(db.shopContacts).get()).single.phone, '+99362112233');

    api.shopsPage = const ShopsPage(items: [], tombstones: ['s2'], cursor: 'cursor-2');
    await pull.pullAll();
    expect(api.calls.where((c) => c.startsWith('shops:')), ['shops:null', 'shops:cursor-1']);
    expect((await db.select(db.shops).get()).map((s) => s.id), ['s1']);
  });

  test("today's route and its stops land in drift and replace the previous route", () async {
    api.route = {
      'id': 'r1',
      'date': '2026-10-07',
      'updatedAt': '2026-10-07T03:00:00.000Z',
      'stops': [
        {'id': 'st1', 'shopId': 's1', 'position': 0, 'plannedAt': '2026-10-07T04:00:00.000Z', 'isAuditTask': true, 'status': 'PLANNED', 'auditId': null},
        {'id': 'st2', 'shopId': 's2', 'position': 1, 'plannedAt': '2026-10-07T05:00:00.000Z', 'isAuditTask': false, 'status': 'DONE', 'auditId': 'a1'},
      ],
    };
    await pull.pullAll();
    final stops = await (db.select(db.routeStops)..orderBy([(s) => OrderingTerm(expression: s.position)])).get();
    expect(stops.map((s) => s.id), ['st1', 'st2']);
    expect(stops.last.status, 'DONE');

    api.route = {'id': null, 'date': '2026-10-08', 'stops': const []};
    await pull.pullAll();
    expect(await db.select(db.routes).get(), isEmpty);
    expect(await db.select(db.routeStops).get(), isEmpty);
  });

  test('a stop finished on the device stays DONE until the audit is synced', () async {
    api.route = {
      'id': 'r1',
      'date': '2026-10-07',
      'updatedAt': '2026-10-07T03:00:00.000Z',
      'stops': [
        {'id': 'st1', 'shopId': 's1', 'position': 0, 'plannedAt': '2026-10-07T04:00:00.000Z', 'isAuditTask': true, 'status': 'PLANNED', 'auditId': null},
      ],
    };
    await pull.pullAll();
    await outbox.enqueue(OutboxKind.auditCreate, {'id': 'a9', 'shopId': 's1', 'routeStopId': 'st1'});
    await (db.update(db.routeStops)..where((s) => s.id.equals('st1'))).write(const RouteStopsCompanion(status: Value('DONE')));
    await pull.pullAll();
    expect((await db.select(db.routeStops).getSingle()).status, 'DONE');
  });

  test('own photos are mirrored without losing the local file path', () async {
    await db
        .into(db.photos)
        .insert(
          PhotosCompanion.insert(
            id: 'p1',
            kind: 'AUDIT',
            mime: 'image/jpeg',
            sizeBytes: 10,
            sha256: 'x',
            takenAt: now,
            localPath: const Value('/files/p1.jpg'),
          ),
        );
    api.photos = [
      {
        'id': 'p1',
        'kind': 'AUDIT',
        'url': 'http://s3/p1',
        'previewUrl400': 'http://s3/p1-400',
        'takenAt': '2026-10-07T07:00:00.000Z',
        'auditId': 'a1',
        'shop': {'id': 's1'},
      },
      {
        'id': 'p2',
        'kind': 'AUDIT',
        'url': 'http://s3/p2',
        'previewUrl400': 'http://s3/p2-400',
        'takenAt': '2026-10-06T07:00:00.000Z',
        'auditId': 'a0',
        'shop': {'id': 's1'},
      },
    ];
    await pull.pullAll();
    final p1 = await (db.select(db.photos)..where((p) => p.id.equals('p1'))).getSingle();
    expect(p1.localPath, '/files/p1.jpg');
    expect(p1.previewUrl, 'http://s3/p1-400');
    expect(p1.status, 'READY');
    expect((await db.select(db.photos).get()).length, 2);
  });
}
