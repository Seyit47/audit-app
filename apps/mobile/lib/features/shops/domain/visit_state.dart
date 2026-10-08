/// Visit state of a shop for the agent's day; mirrors the API's `visitState` (shops.service.ts).
/// The Shops chips (`83:16884`): Все / Запланирован / Просрочен / Пройден.
enum VisitState { scheduled, overdue, visited, notVisited }

class VisitInfo {
  const VisitInfo(this.state, {this.overdueDays = 0});

  final VisitState state;

  /// Whole days since the due date ("просрочен на 2 дня"); 0 unless overdue.
  final int overdueDays;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

VisitInfo visitStateOf({required DateTime? lastVisitAt, required DateTime? nextDueAt, required bool plannedToday, required DateTime now}) {
  final today = _day(now);
  final tomorrow = today.add(const Duration(days: 1));
  if (lastVisitAt != null && !lastVisitAt.toLocal().isBefore(today)) return const VisitInfo(VisitState.visited);
  if (nextDueAt != null && nextDueAt.toLocal().isBefore(today)) {
    return VisitInfo(VisitState.overdue, overdueDays: today.difference(_day(nextDueAt.toLocal())).inDays);
  }
  if (plannedToday || (nextDueAt != null && nextDueAt.toLocal().isBefore(tomorrow))) return const VisitInfo(VisitState.scheduled);
  return const VisitInfo(VisitState.notVisited);
}
