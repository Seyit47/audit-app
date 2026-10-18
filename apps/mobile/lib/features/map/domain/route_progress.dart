import 'dart:math' as math;

/// A point as `(lat, lng)`.
typedef LatLngPoint = (double, double);

/// Where the agent is along a route to a shop.
class RouteProgress {
  const RouteProgress({required this.remaining, required this.remainingM, required this.offRouteM});

  /// The route still ahead, starting where the agent is.
  final List<LatLngPoint> remaining;
  final double remainingM;

  /// How far the agent is from the route (a new route is asked for when it grows).
  final double offRouteM;
}

const _earthM = 6371008.8;

/// Meters between two points (haversine).
double metersBetween(LatLngPoint a, LatLngPoint b) {
  final dLat = _rad(b.$1 - a.$1), dLng = _rad(b.$2 - a.$2);
  final h = math.pow(math.sin(dLat / 2), 2) + math.cos(_rad(a.$1)) * math.cos(_rad(b.$1)) * math.pow(math.sin(dLng / 2), 2);
  return 2 * _earthM * math.asin(math.min(1, math.sqrt(h)));
}

double _rad(double d) => d * math.pi / 180;

/// The agent's place on [route]: the nearest point of the nearest segment (on a flat local projection,
/// exact enough at street scale), and the route from there on.
RouteProgress progressAlong(List<LatLngPoint> route, LatLngPoint at) {
  if (route.length < 2) return RouteProgress(remaining: [at, ...route], remainingM: route.isEmpty ? 0 : metersBetween(at, route.last), offRouteM: 0);
  final kx = math.cos(_rad(at.$1));
  (double, double) xy(LatLngPoint p) => ((p.$2 - at.$2) * kx, p.$1 - at.$1);
  var best = double.infinity;
  var bestIndex = 0;
  var bestPoint = route.first;
  for (var i = 0; i < route.length - 1; i++) {
    final a = xy(route[i]), b = xy(route[i + 1]);
    final dx = b.$1 - a.$1, dy = b.$2 - a.$2;
    final len2 = dx * dx + dy * dy;
    // The agent is the origin: project it onto the segment.
    final t = len2 == 0 ? 0.0 : (-(a.$1 * dx + a.$2 * dy) / len2).clamp(0.0, 1.0);
    final px = a.$1 + t * dx, py = a.$2 + t * dy;
    final d = px * px + py * py;
    if (d < best) {
      best = d;
      bestIndex = i;
      bestPoint = (route[i].$1 + t * (route[i + 1].$1 - route[i].$1), route[i].$2 + t * (route[i + 1].$2 - route[i].$2));
    }
  }
  final ahead = [bestPoint, ...route.skip(bestIndex + 1)];
  var meters = 0.0;
  for (var i = 0; i < ahead.length - 1; i++) {
    meters += metersBetween(ahead[i], ahead[i + 1]);
  }
  final off = metersBetween(at, bestPoint);
  return RouteProgress(remaining: [at, ...ahead], remainingM: meters + off, offRouteM: off);
}
