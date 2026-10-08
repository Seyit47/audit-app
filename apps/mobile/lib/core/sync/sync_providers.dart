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

  /// Starts a sync, or joins the one already running.
  Future<void> syncNow() => _current ??= _run().whenComplete(() => _current = null);

  /// Sends the outbox only (the tracker's pings, so the admin map is current); joins a running sync.
  Future<void> pushNow() => _current ??= _push().whenComplete(() => _current = null);

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

/// "Данные синхронизированы" / "Синхронизация…" on Home and the audit screen.
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final sync = ref.watch(syncControllerProvider);
  return syncStatusOf(openItems: ref.watch(_openItemsProvider).value ?? 0, running: sync.running, lastPullAt: sync.lastPullAt, now: DateTime.now());
});
