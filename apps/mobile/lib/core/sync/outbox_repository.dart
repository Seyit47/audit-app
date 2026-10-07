import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

/// The agent's pending writes. Done items are deleted, so "dependency satisfied" means the
/// dependency id is no longer in the table.
class OutboxRepository {
  OutboxRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<String> enqueue(OutboxKind kind, Map<String, Object?> payload, {String? id, List<String> dependsOn = const []}) async {
    final itemId = id ?? const Uuid().v7();
    await _db.into(_db.outbox).insert(OutboxCompanion.insert(
          id: itemId,
          kind: kind,
          payloadJson: jsonEncode(payload),
          dependsOn: Value(jsonEncode(dependsOn)),
          createdAt: _clock(),
        ));
    return itemId;
  }

  /// Open items (pending or failed) in FIFO order.
  Future<List<OutboxData>> open() => (_db.select(_db.outbox)
        ..where((o) => o.state.isNotValue(OutboxState.done.name))
        ..orderBy([(o) => OrderingTerm(expression: o.createdAt), (o) => OrderingTerm(expression: const CustomExpression<int>('rowid'))]))
      .get();

  Future<OutboxData?> byId(String id) => (_db.select(_db.outbox)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<int> openCount() async {
    final count = _db.outbox.id.count();
    final query = _db.selectOnly(_db.outbox)
      ..addColumns([count])
      ..where(_db.outbox.state.isNotValue(OutboxState.done.name));
    return (await query.getSingle()).read(count)!;
  }

  Stream<int> watchOpenCount() {
    final count = _db.outbox.id.count();
    final query = _db.selectOnly(_db.outbox)
      ..addColumns([count])
      ..where(_db.outbox.state.isNotValue(OutboxState.done.name));
    return query.watchSingle().map((row) => row.read(count)!);
  }

  Future<void> markDone(String id) => (_db.delete(_db.outbox)..where((o) => o.id.equals(id))).go();

  /// A retryable failure: try again at [next].
  Future<void> markRetry(OutboxData item, String error, DateTime next) =>
      (_db.update(_db.outbox)..where((o) => o.id.equals(item.id))).write(OutboxCompanion(
        attempts: Value(item.attempts + 1),
        lastError: Value(error),
        nextAttemptAt: Value(next),
        state: const Value(OutboxState.pending),
      ));

  /// A rejected item: kept and retried on every sync, never dropped.
  Future<void> markFailed(OutboxData item, String error) =>
      (_db.update(_db.outbox)..where((o) => o.id.equals(item.id))).write(OutboxCompanion(
        attempts: Value(item.attempts + 1),
        lastError: Value(error),
        nextAttemptAt: const Value(null),
        state: const Value(OutboxState.failed),
      ));

  /// Shops referenced by open items; the pull must not delete them.
  Future<Set<String>> pendingShopIds() async {
    final ids = <String>{};
    for (final item in await open()) {
      final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
      final id = item.kind == OutboxKind.shopCreate ? payload['id'] : payload['shopId'];
      if (id is String) ids.add(id);
    }
    return ids;
  }

  /// Route stops finished on the device whose audit is not synced yet; the pull keeps them DONE.
  Future<Set<String>> pendingStopIds() async {
    final ids = <String>{};
    for (final item in await open()) {
      if (item.kind != OutboxKind.auditCreate) continue;
      final stop = (jsonDecode(item.payloadJson) as Map<String, dynamic>)['routeStopId'];
      if (stop is String) ids.add(stop);
    }
    return ids;
  }
}

List<String> dependenciesOf(OutboxData item) => (jsonDecode(item.dependsOn) as List).cast<String>();
