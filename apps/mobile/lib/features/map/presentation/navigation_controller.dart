import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/directions.dart';
import '../domain/route_progress.dart';

/// Directions to one shop, kept up to date as the agent moves.
class NavigationState {
  const NavigationState({
    required this.shopId,
    required this.target,
    required this.radiusM,
    this.route,
    this.progress,
    this.loading = false,
    this.straight = false,
    this.following = false,
    this.at,
  });

  final String shopId;
  final LatLngPoint target;
  final int radiusM;
  final Directions? route;
  final RouteProgress? progress;
  final bool loading;

  /// No road route (offline, routing down, or off the road network): a straight line points the way.
  final bool straight;

  /// The camera follows the agent ("Поехали"); the agent can still look around, which stops it.
  final bool following;
  final LatLngPoint? at;

  /// The line on the map: the road ahead, or straight to the shop.
  List<LatLngPoint> get line => progress?.remaining ?? (at == null ? const [] : [at!, target]);

  double? get remainingM => progress?.remainingM ?? (at == null ? null : metersBetween(at!, target));

  /// Driving time left, scaled from the route's time by the distance left.
  double? get remainingS {
    final r = route, left = progress?.remainingM;
    if (r == null || left == null || r.distanceM <= 0) return null;
    return r.durationS * left / r.distanceM;
  }

  bool get arrived => at != null && metersBetween(at!, target) <= radiusM;

  NavigationState copyWith({
    Directions? route,
    RouteProgress? progress,
    bool? loading,
    bool? straight,
    bool? following,
    LatLngPoint? at,
    bool clearRoute = false,
  }) => NavigationState(
    shopId: shopId,
    target: target,
    radiusM: radiusM,
    route: clearRoute ? null : route ?? this.route,
    progress: clearRoute ? null : progress ?? this.progress,
    loading: loading ?? this.loading,
    straight: straight ?? this.straight,
    following: following ?? this.following,
    at: at ?? this.at,
  );
}

/// Asks the server for a road route when a shop is chosen, then follows the agent along it: the part
/// behind is dropped, and a new route is asked for when the agent leaves this one (or, without one, a
/// minute later).
class NavigationController extends Notifier<NavigationState?> {
  NavigationController({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  DateTime? _askedAt;

  /// Off the route by more than this (or the fix's own accuracy, when worse): ask again.
  static const offRouteM = 40.0;
  static const _minAskGap = Duration(seconds: 15);
  static const _retryStraight = Duration(minutes: 1);

  @override
  NavigationState? build() => null;

  /// Directions to [shopId]; [at] is the agent's position when known.
  void start(String shopId, LatLngPoint target, int radiusM, LatLngPoint? at) {
    if (state?.shopId == shopId) return;
    _askedAt = null;
    state = NavigationState(shopId: shopId, target: target, radiusM: radiusM, at: at);
    if (at != null) _ask(at);
  }

  void stop() => state = null;

  void follow(bool on) {
    final s = state;
    if (s != null && s.following != on) state = s.copyWith(following: on);
  }

  /// A new fix of the agent's position.
  void moved(LatLngPoint at, {double accuracyM = 0}) {
    final s = state;
    if (s == null) return;
    final route = s.route;
    if (route == null) {
      state = s.copyWith(at: at);
      final since = _askedAt == null ? null : _clock().difference(_askedAt!);
      if (!s.loading && (since == null || since >= _retryStraight)) _ask(at);
      return;
    }
    final progress = progressAlong(route.points, at);
    state = s.copyWith(at: at, progress: progress);
    final since = _clock().difference(_askedAt!);
    if (!s.loading && !s.arrived && progress.offRouteM > (accuracyM > offRouteM ? accuracyM : offRouteM) && since >= _minAskGap) _ask(at);
  }

  Future<void> _ask(LatLngPoint from) async {
    final s = state;
    if (s == null) return;
    _askedAt = _clock();
    state = s.copyWith(loading: true);
    try {
      final route = await ref.read(directionsApiProvider).route(from, s.target);
      final now = state;
      if (now == null || now.shopId != s.shopId) return;
      state = now.copyWith(route: route, progress: progressAlong(route.points, now.at ?? from), loading: false, straight: false);
    } catch (_) {
      final now = state;
      if (now == null || now.shopId != s.shopId) return;
      // Keep a route already shown; otherwise point straight at the shop.
      state = now.route == null ? now.copyWith(loading: false, straight: true) : now.copyWith(loading: false);
    }
  }
}

final navigationProvider = NotifierProvider.autoDispose<NavigationController, NavigationState?>(NavigationController.new);
