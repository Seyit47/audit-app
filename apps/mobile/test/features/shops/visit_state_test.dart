import 'package:audit_mobile/features/shops/domain/visit_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7, 11);

  VisitInfo of({DateTime? last, DateTime? due, bool planned = false}) =>
      visitStateOf(lastVisitAt: last, nextDueAt: due, plannedToday: planned, now: now);

  test('visited today wins over everything else', () {
    final info = of(last: DateTime(2026, 10, 7, 9), due: DateTime(2026, 10, 1), planned: true);
    expect(info.state, VisitState.visited);
  });

  test('overdue counts whole days since the due date', () {
    final info = of(last: DateTime(2026, 9, 28), due: DateTime(2026, 10, 5, 18));
    expect(info.state, VisitState.overdue);
    expect(info.overdueDays, 2);
  });

  test('scheduled when on today\'s route or due today', () {
    expect(of(planned: true).state, VisitState.scheduled);
    expect(of(due: DateTime(2026, 10, 7, 20)).state, VisitState.scheduled);
  });

  test('not visited otherwise', () {
    final info = of(last: DateTime(2026, 10, 3), due: DateTime(2026, 10, 10));
    expect(info.state, VisitState.notVisited);
    expect(info.overdueDays, 0);
  });
}
