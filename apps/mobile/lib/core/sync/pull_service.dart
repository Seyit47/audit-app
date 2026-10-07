import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'outbox_repository.dart';
import 'sync_api.dart';

/// Brings server changes into the local mirrors with per-resource cursors (contracts/sync.md).
class PullService {
  PullService({required this._db, required this._api, required this._outbox, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final SyncApi _api;
  final OutboxRepository _outbox;
  final DateTime Function() _clock;

  static const lastPullCursor = 'lastPullAt';

  /// The pull order of contracts/sync.md: today's route, shops, then own photos.
  Future<void> pullAll() async {
    await pullMe();
    await pullRoute();
    await pullShops();
    await pullPhotos();
  }

  static const meCursor = 'me';

  /// Keeps `/me` (agent profile and company settings) for offline use.
  Future<void> pullMe() async => _setCursor(meCursor, jsonEncode(await _api.me()));

  /// Replaces the local route with today's; stops finished offline stay DONE until synced.
  Future<void> pullRoute() async {
    final route = await _api.routeToday();
    final keep = await _outbox.pendingStopIds();
    await _db.transaction(() async {
      final local = {for (final s in await _db.select(_db.routeStops).get()) s.id: s};
      await _db.delete(_db.routes).go();
      final id = route['id'] as String?;
      if (id == null) return;
      await _db.into(_db.routes).insert(RoutesCompanion.insert(
            id: id,
            date: DateTime.parse(route['date']! as String),
            updatedAt: DateTime.parse((route['updatedAt'] ?? route['date'])! as String),
          ));
      for (final stop in (route['stops'] as List? ?? const []).cast<Map>()) {
        final stopId = stop['id']! as String;
        final mine = keep.contains(stopId) ? local[stopId] : null;
        await _db.into(_db.routeStops).insert(RouteStopsCompanion.insert(
              id: stopId,
              routeId: id,
              shopId: stop['shopId']! as String,
              position: stop['position']! as int,
              plannedAt: DateTime.parse(stop['plannedAt']! as String),
              isAuditTask: stop['isAuditTask']! as bool,
              status: mine?.status ?? stop['status']! as String,
              auditId: Value(mine?.auditId ?? stop['auditId'] as String?),
            ));
      }
    });
  }

  /// Mirrors the agent's latest photos for the gallery, keeping local files of unsynced ones.
  Future<void> pullPhotos() async {
    final items = await _api.myPhotos();
    await _db.transaction(() async {
      for (final p in items) {
        final id = p['id']! as String;
        final existing = await (_db.select(_db.photos)..where((x) => x.id.equals(id))).getSingleOrNull();
        final remote = PhotosCompanion(
          url: Value(p['url'] as String?),
          previewUrl: Value((p['previewUrl400'] ?? p['url']) as String?),
          auditId: Value(p['auditId'] as String?),
          shopId: Value((p['shop'] as Map?)?['id'] as String?),
          status: const Value('READY'),
        );
        if (existing != null) {
          await (_db.update(_db.photos)..where((x) => x.id.equals(id))).write(remote);
        } else {
          await _db.into(_db.photos).insert(remote.copyWith(
                id: Value(id),
                kind: Value(p['kind']! as String),
                mime: const Value('image/jpeg'),
                sizeBytes: const Value(0),
                sha256: const Value(''),
                takenAt: Value(DateTime.parse(p['takenAt']! as String)),
                lat: Value((p['lat'] as num?)?.toDouble()),
                lng: Value((p['lng'] as num?)?.toDouble()),
              ));
        }
      }
    });
  }

  Future<void> pullShops() async {
    final page = await _api.shops(updatedAfter: await _cursor('shops'));
    final keep = await _outbox.pendingShopIds();
    await _db.transaction(() async {
      for (final record in page.items) {
        await _upsertShop(record.json);
      }
      final gone = page.tombstones.where((id) => !keep.contains(id)).toList();
      if (gone.isNotEmpty) await (_db.delete(_db.shops)..where((s) => s.id.isIn(gone))).go();
      if (page.cursor != null) await _setCursor('shops', page.cursor!);
      await _setCursor(lastPullCursor, _clock().toIso8601String());
    });
  }

  Future<DateTime?> lastPullAt() async {
    final value = await _cursor(lastPullCursor);
    return value == null ? null : DateTime.parse(value);
  }

  Future<void> _upsertShop(Map<String, Object?> json) async {
    final id = json['id']! as String;
    final facade = json['facade'] as Map?;
    await _db.into(_db.shops).insertOnConflictUpdate(ShopsCompanion.insert(
          id: id,
          code: json['code']! as String,
          name: json['name']! as String,
          type: json['type']! as String,
          address: json['address']! as String,
          addressDetail: Value(json['addressDetail'] as String?),
          regionId: Value(json['regionId'] as String?),
          regionName: Value((json['region'] as Map?)?['name'] as String?),
          lat: (json['lat']! as num).toDouble(),
          lng: (json['lng']! as num).toDouble(),
          auditRadiusM: json['auditRadiusM']! as int,
          ownerName: Value(json['ownerName'] as String?),
          facadeUrl: Value((facade?['previewUrl400'] ?? facade?['url']) as String?),
          status: json['status']! as String,
          lastVisitAt: Value(_date(json['lastVisitAt'])),
          nextDueAt: Value(_date(json['nextDueAt'])),
          latestVisitsJson: Value(jsonEncode(json['latestVisits'] ?? const [])),
          updatedAt: DateTime.parse(json['updatedAt']! as String),
        ));
    await (_db.delete(_db.shopContacts)..where((c) => c.shopId.equals(id))).go();
    for (final contact in (json['contacts'] as List? ?? const []).cast<Map>()) {
      await _db.into(_db.shopContacts).insert(ShopContactsCompanion.insert(
            id: contact['id'] as String,
            shopId: id,
            phone: contact['phone'] as String,
            label: Value(contact['label'] as String?),
            position: contact['position'] as int,
          ));
    }
  }

  DateTime? _date(Object? value) => value == null ? null : DateTime.parse(value as String);

  Future<String?> _cursor(String name) async =>
      (await (_db.select(_db.syncCursors)..where((c) => c.name.equals(name))).getSingleOrNull())?.value;

  Future<void> _setCursor(String name, String value) => _db
      .into(_db.syncCursors)
      .insertOnConflictUpdate(SyncCursorsCompanion.insert(name: name, value: value, updatedAt: _clock()));
}
