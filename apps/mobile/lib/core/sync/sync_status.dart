/// The two sync states designed in Figma (Home): "Данные синхронизированы" / "Синхронизация…".
enum SyncStatus { synced, syncing }

const freshPull = Duration(minutes: 15);

SyncStatus syncStatusOf({required int openItems, required bool running, required DateTime? lastPullAt, required DateTime now}) {
  final fresh = lastPullAt != null && now.difference(lastPullAt) < freshPull;
  return openItems == 0 && !running && fresh ? SyncStatus.synced : SyncStatus.syncing;
}
