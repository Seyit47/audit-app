import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/database_provider.dart';

/// Today's route as synced to the device (`/routes/today`), read by Home, Shops and the audit.
class RouteLocalRepository {
  RouteLocalRepository(this._db);

  final AppDatabase _db;

  Stream<List<RouteStop>> watchStops() => (_db.select(_db.routeStops)..orderBy([(s) => OrderingTerm(expression: s.position)])).watch();

  /// The first stop not yet done or missed: what "Начать аудит" opens.
  Future<RouteStop?> nextStop() =>
      (_db.select(_db.routeStops)
            ..where((s) => s.status.isIn(const ['PLANNED', 'IN_PROGRESS']))
            ..orderBy([(s) => OrderingTerm(expression: s.position)])
            ..limit(1))
          .getSingleOrNull();

  /// Today's open stop for a shop, if it is on the route.
  Future<RouteStop?> stopForShop(String shopId) =>
      (_db.select(_db.routeStops)
            ..where((s) => s.shopId.equals(shopId) & s.status.isIn(const ['PLANNED', 'IN_PROGRESS']))
            ..limit(1))
          .getSingleOrNull();

  Future<void> setStatus(String stopId, String status, {String? auditId}) => (_db.update(
    _db.routeStops,
  )..where((s) => s.id.equals(stopId))).write(RouteStopsCompanion(status: Value(status), auditId: auditId == null ? const Value.absent() : Value(auditId)));
}

final routeLocalRepositoryProvider = Provider<RouteLocalRepository>((ref) => RouteLocalRepository(ref.watch(databaseProvider)));

final todayStopsProvider = StreamProvider<List<RouteStop>>((ref) => ref.watch(routeLocalRepositoryProvider).watchStops());
