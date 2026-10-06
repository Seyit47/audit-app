import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/network/api_exception.dart';
import 'package:audit_mobile/core/sync/outbox_repository.dart';
import 'package:audit_mobile/core/sync/pull_service.dart';
import 'package:audit_mobile/core/sync/sync_api.dart';
import 'package:audit_mobile/core/sync/sync_engine.dart';
import 'package:audit_mobile/core/sync/sync_status.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records calls in order. `fail` maps a call name to the error it throws (once per entry).
class FakeApi implements SyncApi {
  final calls = <String>[];
  final fail = <String, List<ApiException>>{};
  var shopsPage = const ShopsPage(items: [], tombstones: [], cursor: 'c1');

  Future<void> _record(String call) async {
    calls.add(call);
    final queue = fail[call];
    if (queue != null && queue.isNotEmpty) throw queue.removeAt(0);
  }

  @override
  Future<UploadTarget> createUpload(Map<String, Object?> body) async {
    await _record('createUpload:${body['id']}');
    return const UploadTarget(ready: false, url: 'http://s3/put', headers: {});
  }

  @override
  Future<void> putFile(UploadTarget target, String path, String mime) => _record('put:$path');

  @override
  Future<void> completeUpload(String id) => _record('complete:$id');

  @override
  Future<void> createShop(Map<String, Object?> body) => _record('createShop:${body['id']}');

  @override
  Future<void> createAudit(Map<String, Object?> body) => _record('createAudit:${body['id']}');

  @override
  Future<void> sendPings(List<Map<String, Object?>> pings) => _record('pings:${pings.length}');

  @override
  Future<ShopsPage> shops({String? updatedAfter}) async {
    calls.add('shops:$updatedAfter');
    return shopsPage;
  }
}

ApiException network() => ApiException(code: 'NETWORK', message: 'offline');
ApiException server() => ApiException(code: 'INTERNAL', message: 'boom', status: 500);
ApiException invalid() => ApiException(code: 'VALIDATION', message: 'bad', status: 422);

void main() {
  late AppDatabase db;
  late FakeApi api;
  late OutboxRepository outbox;
  late SyncEngine engine;
  var now = DateTime.utc(2026, 10, 6, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeApi();
    outbox = OutboxRepository(db, clock: () => now);
    engine = SyncEngine(db: db, api: api, outbox: outbox, clock: () => now, jitter: () => 1.0);
  });
  tearDown(() => db.close());

  Future<void> photo(String id) => outbox.enqueue(OutboxKind.photo, {
        'id': id, 'kind': 'AUDIT', 'mime': 'image/jpeg', 'sizeBytes': 10, 'sha256': 'a' * 64,
        'takenAt': now.toIso8601String(), 'localPath': '/p/$id.jpg',
      }, id: 'ph-$id');

  test('runs FIFO and waits for dependencies (photos before the audit and shop)', () async {
    await outbox.enqueue(OutboxKind.auditCreate, {'id': 'a1', 'photoIds': ['p1', 'p2']}, id: 'au-a1', dependsOn: ['ph-p1', 'ph-p2']);
    await photo('p1');
    await photo('p2');
    await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1', 'facadePhotoId': 'p3'}, id: 'sh-s1', dependsOn: ['ph-p3']);
    await photo('p3');

    await engine.run();

    expect(api.calls, [
      'createUpload:p1', 'put:/p/p1.jpg', 'complete:p1',
      'createUpload:p2', 'put:/p/p2.jpg', 'complete:p2',
      'createAudit:a1',
      'createUpload:p3', 'put:/p/p3.jpg', 'complete:p3',
      'createShop:s1',
    ]);
    expect(await outbox.openCount(), 0);
  });

  test('network errors and 5xx back off; dependents wait', () async {
    await photo('p1');
    await outbox.enqueue(OutboxKind.auditCreate, {'id': 'a1', 'photoIds': ['p1']}, id: 'au-a1', dependsOn: ['ph-p1']);
    api.fail['createUpload:p1'] = [network(), server()];

    await engine.run();
    expect(api.calls, ['createUpload:p1']);
    var item = await outbox.byId('ph-p1');
    expect(item!.attempts, 1);
    expect(item.nextAttemptAt!.toUtc(), now.add(const Duration(seconds: 5)));

    // Not due yet: nothing is sent.
    api.calls.clear();
    await engine.run();
    expect(api.calls, isEmpty);

    now = now.add(const Duration(seconds: 5));
    await engine.run();
    item = await outbox.byId('ph-p1');
    expect(item!.attempts, 2);
    expect(item.nextAttemptAt!.toUtc(), now.add(const Duration(seconds: 10)));

    now = now.add(const Duration(seconds: 10));
    api.calls.clear();
    await engine.run();
    expect(api.calls.last, 'createAudit:a1');
    expect(await outbox.openCount(), 0);
  });

  test('backoff is capped at 10 minutes', () {
    expect(SyncEngine.backoff(1), const Duration(seconds: 5));
    expect(SyncEngine.backoff(30), const Duration(minutes: 10));
  });

  test('a repeated create (server returns the existing record) counts as success', () async {
    await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1'}, id: 'sh-s1');
    await engine.run();
    // The same id again, as after a lost response.
    await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1'}, id: 'sh-s1-retry');
    await engine.run();
    expect(api.calls, ['createShop:s1', 'createShop:s1']);
    expect(await outbox.openCount(), 0);
  });

  test('other 4xx mark the item FAILED, keep it, and retry it on the next sync', () async {
    await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1'}, id: 'sh-s1');
    api.fail['createShop:s1'] = [invalid()];

    await engine.run();
    final item = await outbox.byId('sh-s1');
    expect(item!.state, OutboxState.failed);
    expect(item.lastError, contains('VALIDATION'));
    expect(syncStatusOf(openItems: await outbox.openCount(), running: false, lastPullAt: now, now: now), SyncStatus.syncing);

    await engine.run();
    expect(api.calls, ['createShop:s1', 'createShop:s1']);
    expect(await outbox.openCount(), 0);
    expect(syncStatusOf(openItems: 0, running: false, lastPullAt: now, now: now), SyncStatus.synced);
  });

  test('status is syncing when the last pull is older than 15 minutes', () {
    expect(syncStatusOf(openItems: 0, running: false, lastPullAt: now.subtract(const Duration(minutes: 16)), now: now), SyncStatus.syncing);
    expect(syncStatusOf(openItems: 0, running: true, lastPullAt: now, now: now), SyncStatus.syncing);
  });

  test('the pull applies tombstones but keeps shops with pending outbox items', () async {
    Future<void> shop(String id) => db.into(db.shops).insert(ShopsCompanion.insert(
          id: id, code: 'CL-$id', name: id, type: 'OTHER', address: 'a', lat: 0, lng: 0,
          auditRadiusM: 100, status: 'ACTIVE', updatedAt: now,
        ));
    await shop('gone');
    await shop('busy');
    await outbox.enqueue(OutboxKind.auditCreate, {'id': 'a1', 'shopId': 'busy', 'photoIds': <String>[]}, id: 'au-a1');
    api.fail['createAudit:a1'] = [network()];
    await engine.run(); // leaves the audit pending

    api.shopsPage = ShopsPage(
      items: [ShopRecord(json: {
        'id': 'new', 'code': 'CL-1', 'name': 'New', 'type': 'OTHER', 'address': 'x', 'lat': 1.0, 'lng': 2.0,
        'auditRadiusM': 100, 'status': 'ACTIVE', 'updatedAt': now.toIso8601String(), 'contacts': <Object>[],
      })],
      tombstones: const ['gone', 'busy'],
      cursor: 'c2',
    );
    await PullService(db: db, api: api, outbox: outbox, clock: () => now).pullShops();

    final ids = (await db.select(db.shops).get()).map((s) => s.id).toSet();
    expect(ids, {'busy', 'new'});
    expect(api.calls.last, 'shops:null');
    await PullService(db: db, api: api, outbox: outbox, clock: () => now).pullShops();
    expect(api.calls.last, 'shops:c2');
  });
}
