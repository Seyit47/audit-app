import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../auth/session_provider.dart';
import '../db/database_provider.dart';
import '../network/api_exception.dart';
import 'outbox_repository.dart';
import 'pull_service.dart';
import 'sync_api.dart';
import 'sync_engine.dart';
import 'sync_status.dart';

final outboxProvider = Provider<OutboxRepository>((ref) => OutboxRepository(ref.watch(databaseProvider)));

final syncApiProvider = Provider<SyncApi>((ref) => HttpSyncApi(ref.watch(apiClientProvider)));

final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(db: ref.watch(databaseProvider), api: ref.watch(syncApiProvider), outbox: ref.watch(outboxProvider)),
);

final pullServiceProvider = Provider<PullService>(
  (ref) => PullService(db: ref.watch(databaseProvider), api: ref.watch(syncApiProvider), outbox: ref.watch(outboxProvider)),
);

class SyncState {
  const SyncState({this.running = false, this.lastPullAt});

  final bool running;
  final DateTime? lastPullAt;
}

/// Runs push then pull for the Agent role. Triggers: app start, resume, regained connectivity,
/// a 15-minute timer while open (workmanager covers the background), and [syncNow] on demand.
final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);

class SyncController extends Notifier<SyncState> {
  Future<void>? _current;

  /// Something was queued while a sync ran: send once more when it ends instead of waiting for the next trigger.
  bool _again = false;

  @override
  SyncState build() {
    final user = ref.watch(sessionProvider).value;
    if (user?.role != Role.agent) return const SyncState();

    final connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) syncNow();
    });
    final lifecycle = AppLifecycleListener(onResume: syncNow);
    final timer = Timer.periodic(freshPull, (_) => syncNow());
    ref.onDispose(() {
      connectivity.cancel();
      lifecycle.dispose();
      timer.cancel();
    });

    Future.microtask(syncNow);
    return const SyncState();
  }

  /// Sends the outbox, then pulls; joins a running sync (which then sends once more).
  Future<void> syncNow() => _start(_run);

  /// Sends the outbox only: after an audit, a new shop or the tracker's pings, so the admin sees them at once.
  Future<void> pushNow() => _start(_push);

  Future<void> _start(Future<void> Function() job) {
    if (_current case final running?) {
      _again = true;
      return running;
    }
    return _current = () async {
      try {
        await job();
        while (_again) {
          _again = false;
          await _push();
        }
      } finally {
        _current = null;
      }
    }();
  }

  Future<void> _push() async {
    try {
      await ref.read(syncEngineProvider).run();
    } on ApiException catch (e) {
      if (!e.isRetryable) rethrow;
    }
  }

  Future<void> _run() async {
    final pull = ref.read(pullServiceProvider);
    state = SyncState(running: true, lastPullAt: state.lastPullAt);
    try {
      await ref.read(syncEngineProvider).run();
      await pull.pullAll();
    } on ApiException catch (e) {
      // Offline or a server outage: the outbox keeps everything; the next trigger retries.
      if (!e.isRetryable) rethrow;
    } finally {
      state = SyncState(lastPullAt: await pull.lastPullAt());
    }
  }
}

final _openItemsProvider = StreamProvider<int>((ref) => ref.watch(outboxProvider).watchOpenCount());

/// Audits, shops and photos not yet on the server (location pings left out: they come and go every couple of minutes).
final syncPendingProvider = StreamProvider<int>((ref) => ref.watch(outboxProvider).watchOpenCount(includePings: false));

/// "Данные синхронизированы" / "Синхронизация…" on Home and the audit screen.
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final sync = ref.watch(syncControllerProvider);
  return syncStatusOf(openItems: ref.watch(_openItemsProvider).value ?? 0, running: sync.running, lastPullAt: sync.lastPullAt, now: DateTime.now());
});
