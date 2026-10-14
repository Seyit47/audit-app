import '../db/app_database.dart';
import 'outbox_repository.dart';

/// What the agent sees as one thing to sync: an audit or a new shop with its photos
/// (a photo without its record stands alone). Location pings are left out.
class OutboxGroup {
  const OutboxGroup({this.record, this.photos = const []});

  final OutboxData? record;
  final List<OutboxData> photos;

  List<OutboxData> get items => [?record, ...photos];
  Iterable<String> get ids => items.map((i) => i.id);

  /// Stopped by the agent: every item paused.
  bool get paused => items.every((i) => i.state == OutboxState.paused);

  /// The last error of any item, e.g. a server rejection or no connection.
  String? get error => items.map((i) => i.lastError).nonNulls.firstOrNull;
}

List<OutboxGroup> groupOutbox(List<OutboxData> open) {
  final byId = {for (final o in open) o.id: o};
  final grouped = <String>{};
  final groups = <OutboxGroup>[];
  for (final o in open) {
    if (o.kind != OutboxKind.auditCreate && o.kind != OutboxKind.shopCreate) continue;
    final photos = [
      for (final d in dependenciesOf(o))
        if (byId[d] case final p? when p.kind == OutboxKind.photo) p,
    ];
    grouped.addAll(photos.map((p) => p.id));
    groups.add(OutboxGroup(record: o, photos: photos));
  }
  for (final o in open) {
    if (o.kind == OutboxKind.photo && !grouped.contains(o.id)) groups.add(OutboxGroup(photos: [o]));
  }
  return groups;
}
