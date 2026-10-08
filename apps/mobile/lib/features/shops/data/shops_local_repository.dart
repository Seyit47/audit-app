import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';
import '../../route/data/route_local_repository.dart';
import '../domain/visit_state.dart';

/// A visit from the shop history: server visits (`latestVisits`) and audits not yet synced.
class ShopVisit {
  const ShopVisit({
    required this.id,
    required this.at,
    required this.missed,
    this.comment = '',
    this.hasViolation = false,
    this.withinRadius,
    this.lat,
    this.lng,
    this.accuracyM,
    this.photoUrls = const [],
    this.photoCount = 0,
    this.pending = false,
  });

  final String id;
  final DateTime at;
  final bool missed;
  final String comment;
  final bool hasViolation;
  final bool? withinRadius;
  final double? lat;
  final double? lng;
  final double? accuracyM;

  /// Network URLs or local file paths (`/…`) for unsynced photos.
  final List<String> photoUrls;
  final int photoCount;
  final bool pending;
}

class ShopItem {
  const ShopItem({required this.shop, required this.contacts, required this.visit});

  final Shop shop;
  final List<ShopContact> contacts;
  final VisitInfo visit;
}

/// The agent's shops from the local mirror (screens never call the API, contracts/sync.md).
class ShopsLocalRepository {
  ShopsLocalRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<ShopItem>> watchAll() {
    final query = _db.select(_db.shops)..orderBy([(s) => OrderingTerm(expression: s.name)]);
    return query.watch().asyncMap((shops) async {
      final planned = {for (final s in await _db.select(_db.routeStops).get()) s.shopId};
      final contacts = await _db.select(_db.shopContacts).get();
      return [
        for (final s in shops)
          ShopItem(
            shop: s,
            contacts: contacts.where((c) => c.shopId == s.id).toList()..sort((a, b) => a.position.compareTo(b.position)),
            visit: visitStateOf(lastVisitAt: s.lastVisitAt, nextDueAt: s.nextDueAt, plannedToday: planned.contains(s.id), now: _clock()),
          ),
      ];
    });
  }

  Stream<ShopItem?> watchOne(String id) => watchAll().map((all) {
    for (final item in all) {
      if (item.shop.id == id) return item;
    }
    return null;
  });

  /// History for Shop details: local unsynced audits first, then the server's latest visits.
  Stream<List<ShopVisit>> watchVisits(String shopId) {
    final shop = (_db.select(_db.shops)..where((s) => s.id.equals(shopId))).watchSingleOrNull();
    return shop.asyncMap((s) async {
      final server = s == null ? const <ShopVisit>[] : _serverVisits(s.latestVisitsJson);
      final known = {for (final v in server) v.id};
      final local =
          await (_db.select(_db.audits)
                ..where((a) => a.shopId.equals(shopId))
                ..orderBy([(a) => OrderingTerm.desc(a.finishedAtDevice)]))
              .get();
      final pending = <ShopVisit>[];
      for (final a in local.where((a) => !known.contains(a.id))) {
        final photos = await (_db.select(_db.photos)..where((p) => p.auditId.equals(a.id))).get();
        pending.add(
          ShopVisit(
            id: a.id,
            at: a.finishedAtDevice,
            missed: false,
            comment: a.comment,
            hasViolation: a.hasViolation,
            withinRadius: a.withinRadius,
            lat: a.lat,
            lng: a.lng,
            accuracyM: a.gpsAccuracyM,
            photoUrls: [for (final p in photos) p.previewUrl ?? p.localPath ?? ''],
            photoCount: photos.length,
            pending: !a.synced,
          ),
        );
      }
      return [...pending, ...server]..sort((x, y) => y.at.compareTo(x.at));
    });
  }

  /// Marks the shop visited after a local audit, so lists update before the next pull.
  Future<void> markVisited(String shopId, DateTime at) =>
      (_db.update(_db.shops)..where((s) => s.id.equals(shopId))).write(ShopsCompanion(lastVisitAt: Value(at)));

  List<ShopVisit> _serverVisits(String json) {
    final list = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    return [
      for (final v in list)
        ShopVisit(
          id: v['id'] as String,
          at: DateTime.parse(v['at'] as String),
          missed: v['type'] == 'MISSED',
          comment: (v['comment'] as String?) ?? '',
          hasViolation: (v['hasViolation'] as bool?) ?? false,
          withinRadius: v['withinRadius'] as bool?,
          lat: (v['lat'] as num?)?.toDouble(),
          lng: (v['lng'] as num?)?.toDouble(),
          accuracyM: (v['gpsAccuracyM'] as num?)?.toDouble(),
          photoUrls: [for (final p in (v['photos'] as List? ?? const []).cast<Map>()) (p['previewUrl400'] ?? p['url']) as String],
          photoCount: (v['photoCount'] as int?) ?? 0,
        ),
    ];
  }
}

final shopsLocalRepositoryProvider = Provider<ShopsLocalRepository>((ref) => ShopsLocalRepository(ref.watch(databaseProvider)));

final shopsProvider = StreamProvider<List<ShopItem>>((ref) {
  ref.watch(todayStopsProvider);
  return ref.watch(shopsLocalRepositoryProvider).watchAll();
});

final shopProvider = StreamProvider.family<ShopItem?, String>((ref, id) {
  ref.watch(todayStopsProvider);
  return ref.watch(shopsLocalRepositoryProvider).watchOne(id);
});

final shopVisitsProvider = StreamProvider.family<List<ShopVisit>, String>((ref, id) => ref.watch(shopsLocalRepositoryProvider).watchVisits(id));
