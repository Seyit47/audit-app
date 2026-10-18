import 'package:audit_mobile/features/map/domain/route_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // An L-shaped route in Ashgabat: ~111 m north, then ~88 m east.
  const route = [(37.950, 58.380), (37.951, 58.380), (37.951, 58.381)];

  test('metersBetween: 0.001° of latitude is about 111 m', () {
    expect(metersBetween((37.950, 58.380), (37.951, 58.380)), closeTo(111.2, 0.5));
  });

  test('on the route: the part behind is dropped and the rest measured', () {
    final p = progressAlong(route, (37.9505, 58.380));
    expect(p.offRouteM, lessThan(0.5));
    expect(p.remainingM, closeTo(55.6 + 87.8, 1));
    expect(p.remaining.first, (37.9505, 58.380));
    expect(p.remaining.last, route.last);
    expect(p.remaining, hasLength(4)); // the agent, the point beside them, the corner, the shop
  });

  test('beside the route: the distance off it, and the way back counted', () {
    final p = progressAlong(route, (37.951, 58.3795)); // ~44 m west of the corner
    expect(p.offRouteM, closeTo(43.9, 1));
    expect(p.remainingM, closeTo(43.9 + 87.8, 1.5));
  });

  test('past the end: nothing left but the way to the shop', () {
    final p = progressAlong(route, (37.951, 58.3812));
    expect(p.remaining.last, route.last);
    expect(p.remainingM, closeTo(17.6, 1));
  });
}
