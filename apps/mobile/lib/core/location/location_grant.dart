import 'package:geolocator/geolocator.dart';

/// What the agent app needs from the OS before it works: location "all the time" and precise. "Only while
/// using the app" is not enough: the route stops being recorded as soon as the screen is off, and the
/// admin sees a single point instead of a track.
enum LocationGrant {
  granted,

  /// Allowed only while the app is open.
  whileInUse,

  /// Allowed, but "approximate" (Android 12+): 1–3 km, useless for audits.
  approximate,
  denied,

  /// Refused for good: only the app's settings can change it.
  deniedForever,
}

LocationGrant grantOf(LocationPermission permission, {required bool approximate}) {
  return switch (permission) {
    LocationPermission.deniedForever => LocationGrant.deniedForever,
    LocationPermission.denied || LocationPermission.unableToDetermine => LocationGrant.denied,
    LocationPermission.whileInUse || LocationPermission.always when approximate => LocationGrant.approximate,
    LocationPermission.whileInUse => LocationGrant.whileInUse,
    LocationPermission.always => LocationGrant.granted,
  };
}

/// The current grant, without asking for anything.
Future<LocationGrant> readLocationGrant() async {
  final permission = await Geolocator.checkPermission();
  final allowed = permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  return grantOf(permission, approximate: allowed && await isApproximate());
}

/// Whether location is granted only approximately (Android 12+ "Approximate"): audits need precise.
Future<bool> isApproximate() async {
  try {
    return await Geolocator.getLocationAccuracy() == LocationAccuracyStatus.reduced;
  } catch (_) {
    return false;
  }
}
