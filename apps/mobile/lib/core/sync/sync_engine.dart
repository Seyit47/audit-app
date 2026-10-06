import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../network/api_exception.dart';
import 'outbox_repository.dart';
import 'sync_api.dart';

/// Drains the outbox (contracts/sync.md). After each success it starts again from the head, so
/// items waiting on a dependency go right after it. Each item is tried at most once per run.
class SyncEngine {
  SyncEngine({
    required this._db,
    required this._api,
    required this._outbox,
    DateTime Function()? clock,
    double Function()? jitter,
  })  : _clock = clock ?? DateTime.now,
        _jitter = jitter ?? (() => 0.8 + Random().nextDouble() * 0.4);

  final AppDatabase _db;
  final SyncApi _api;
  final OutboxRepository _outbox;
  final DateTime Function() _clock;
  final double Function() _jitter;

  static const _first = Duration(seconds: 5);
  static const _max = Duration(minutes: 10);

  /// 5 s, 10 s, 20 s, … capped at 10 min (before jitter).
  static Duration backoff(int attempts) {
    final ms = _first.inMilliseconds * pow(2, min(attempts - 1, 20));
    return Duration(milliseconds: min(ms.toInt(), _max.inMilliseconds));
  }

  Future<void> run() async {
    final tried = <String>{};
    while (true) {
      final next = await _nextReady(tried);
      if (next == null) return;
      tried.add(next.id);
      try {
        await _send(next);
        await _outbox.markDone(next.id);
      } on ApiException catch (e) {
        final error = '${e.code}: ${e.message}';
        if (e.isRetryable) {
          final delay = backoff(next.attempts + 1) * _jitter();
          await _outbox.markRetry(next, error, _clock().add(delay));
        } else {
          await _outbox.markFailed(next, error);
        }
      }
    }
  }

  Future<OutboxData?> _nextReady(Set<String> tried) async {
    final open = await _outbox.open();
    final openIds = {for (final o in open) o.id};
    final now = _clock();
    for (final item in open) {
      if (tried.contains(item.id)) continue;
      if (item.nextAttemptAt != null && item.nextAttemptAt!.isAfter(now)) continue;
      if (dependenciesOf(item).any(openIds.contains)) continue;
      return item;
    }
    return null;
  }

  Future<void> _send(OutboxData item) async {
    final payload = jsonDecode(item.payloadJson) as Map<String, Object?>;
    switch (item.kind) {
      case OutboxKind.photo:
        final localPath = payload.remove('localPath')! as String;
        final target = await _api.createUpload(payload);
        if (!target.ready) {
          await _api.putFile(target, localPath, payload['mime']! as String);
          await _api.completeUpload(payload['id']! as String);
        }
        await (_db.update(_db.photos)..where((p) => p.id.equals(payload['id']! as String)))
            .write(PhotosCompanion(status: const Value('READY'), readyAt: Value(_clock())));
      case OutboxKind.shopCreate:
        await _api.createShop(payload);
      case OutboxKind.auditCreate:
        await _api.createAudit(payload);
        await (_db.update(_db.audits)..where((a) => a.id.equals(payload['id']! as String)))
            .write(const AuditsCompanion(synced: Value(true)));
      case OutboxKind.pings:
        await _api.sendPings((payload['pings']! as List).cast<Map<String, Object?>>());
    }
  }
}
