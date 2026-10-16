import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../router/app_router.dart';
import 'location_hub.dart';

/// The device's position for "N m from you": from the shared stream while a screen shows it.
final positionProvider = StreamProvider.autoDispose<Position?>((ref) async* {
  if (!ref.watch(locationGrantedProvider)) {
    yield null;
    return;
  }
  final hub = ref.watch(locationHubProvider);
  hub.acquire();
  ref.onDispose(hub.release);
  Position? known = hub.latest;
  if (known == null) {
    try {
      known = await Geolocator.getLastKnownPosition();
    } catch (_) {}
  }
  yield known;
  yield* hub.positions;
});

/// Meters from the device to a point, or null without a fix.
double? distanceTo(Position? p, double lat, double lng) => p == null ? null : Geolocator.distanceBetween(p.latitude, p.longitude, lat, lng);
