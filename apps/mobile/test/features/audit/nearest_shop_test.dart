import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:flutter_test/flutter_test.dart';

typedef S = ({String id, double lat, double lng, int r});

NearestShop<S>? find(List<S> shops, Fix fix) => nearestShop<S>(shops, fix, lat: (s) => s.lat, lng: (s) => s.lng, radiusM: (s) => s.r);

void main() {
  const here = Fix(lat: 37.95, lng: 58.38, accuracyM: 5);
  // ~0.0009° of latitude ≈ 100 m.
  test('picks the shop whose radius the agent is in', () {
    final r = find([(id: 'far', lat: 37.96, lng: 58.38, r: 100), (id: 'here', lat: 37.9503, lng: 58.38, r: 100)], here)!;
    expect([r.shop.id, r.inside], ['here', true]);
  });

  test('inside a wider radius wins over a closer shop the agent is outside of', () {
    final r = find([(id: 'close', lat: 37.9502, lng: 58.38, r: 10), (id: 'wide', lat: 37.9512, lng: 58.38, r: 200)], here)!;
    expect(r.shop.id, 'wide');
  });

  test('outside every radius: the nearest shop, flagged outside', () {
    final r = find([(id: 'a', lat: 37.96, lng: 58.38, r: 100), (id: 'b', lat: 37.97, lng: 58.38, r: 100)], here)!;
    expect([r.shop.id, r.inside], ['a', false]);
    expect(r.meters, closeTo(1112, 5));
  });

  test('no shops', () => expect(find(const [], here), isNull));
}
