import 'package:workmanager/workmanager.dart';

import '../auth/session.dart';
import '../auth/session_store.dart';
import '../db/app_database.dart';
import '../network/api_client.dart';
import 'outbox_repository.dart';
import 'pull_service.dart';
import 'sync_api.dart';
import 'sync_engine.dart';

const _task = 'audit-sync';

/// Background sync every 15 minutes while connected (Android workmanager).
Future<void> registerBackgroundSync() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _task,
    _task,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

Future<void> cancelBackgroundSync() => Workmanager().cancelByUniqueName(_task);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    final store = SessionStore();
    if ((await store.readUser())?.role != Role.agent) return true;

    final db = AppDatabase();
    try {
      final api = HttpSyncApi(ApiClient(tokens: store, onSessionExpired: () {}));
      final outbox = OutboxRepository(db);
      await SyncEngine(db: db, api: api, outbox: outbox).run();
      await PullService(db: db, api: api, outbox: outbox).pullShops();
      return true;
    } catch (_) {
      return false;
    } finally {
      await db.close();
    }
  });
}
