import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../router/app_router.dart';

/// The device position for distances and the map (foreground only; tracking is `tracker.dart`).
/// Emits the last known fix first, then updates every 10 m.
final positionProvider = StreamProvider<Position?>((ref) async* {
  if (!ref.watch(locationGrantedProvider)) {
    yield null;
    return;
  }
  yield await Geolocator.getLastKnownPosition();
  yield* Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10));
});

/// Meters from the device to a point, or null without a fix.
double? distanceTo(Position? p, double lat, double lng) =>
    p == null ? null : Geolocator.distanceBetween(p.latitude, p.longitude, lat, lng);
