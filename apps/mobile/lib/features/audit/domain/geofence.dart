import 'dart:math' as math;

/// A GPS fix for the audit start check.
class Fix {
  const Fix({required this.lat, required this.lng, required this.accuracyM});

  final double lat;
  final double lng;
  final double accuracyM;
}

enum GeoStatus { locating, inside, outside, inaccurate, unavailable }

/// Haversine distance in meters, the same formula as the server (`apps/api/src/lib/geo.ts`).
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a = math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.sqrt(a));
}

/// The audit may start only inside the shop radius with a fix at least as accurate as required.
GeoStatus geofence({required Fix? fix, required double shopLat, required double shopLng, required int radiusM, required int minAccuracyM}) {
  if (fix == null) return GeoStatus.unavailable;
  if (fix.accuracyM > minAccuracyM) return GeoStatus.inaccurate;
  return distanceMeters(fix.lat, fix.lng, shopLat, shopLng) <= radiusM ? GeoStatus.inside : GeoStatus.outside;
}

/// The shop nearest to a fix, and whether the fix is inside its audit radius.
class NearestShop<T> {
  const NearestShop(this.shop, this.meters, {required this.inside});

  final T shop;
  final double meters;
  final bool inside;
}

/// "Начать аудит": the shop whose audit radius the agent stands in (the closest when radii overlap); otherwise
/// the nearest shop, outside. Null when there are no shops.
NearestShop<T>? nearestShop<T>(
  Iterable<T> shops,
  Fix fix, {
  required double Function(T) lat,
  required double Function(T) lng,
  required int Function(T) radiusM,
}) {
  NearestShop<T>? best;
  for (final s in shops) {
    final d = distanceMeters(fix.lat, fix.lng, lat(s), lng(s));
    final inside = d <= radiusM(s);
    // Inside any radius beats outside; then the closer shop.
    final better = best == null || (inside && !best.inside) || (inside == best.inside && d < best.meters);
    if (better) best = NearestShop(s, d, inside: inside);
  }
  return best;
}
