import 'dart:async';

import 'package:audit_mobile/core/location/location_hub.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

/// The shared stream without GPS: readings are pushed by the test.
class _Hub extends LocationHub {
  final readings = StreamController<Position>.broadcast();
  var users = 0;

  @override
  Stream<Position> get positions => readings.stream;

  @override
  void acquire({bool background = false}) => users++;

  @override
  void release({bool background = false}) => users--;
}

Position _at(double accuracy) => Position(
  latitude: 37.95,
  longitude: 58.38,
  timestamp: DateTime.now(),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('each sharper reading as it comes; stops at a precise one and lets the GPS go', () async {
    final hub = _Hub();
    final fixes = <Fix?>[];
    final done = GeolocatorLocator(hub, refine: const Duration(seconds: 5)).watch().forEach(fixes.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    for (final a in [40.0, 60.0, 25.0, 9.0, 5.0]) {
      hub.readings.add(_at(a));
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    await done;
    expect(fixes.map((f) => f!.accuracyM), [40, 25, 9], reason: 'a worse reading is skipped; 9 m is precise enough');
    expect(fixes.every((f) => !f!.provisional), isTrue);
    expect(hub.users, 0);
  });

  test('no precise reading in time: settles on the best one', () async {
    final hub = _Hub();
    final fixes = <Fix?>[];
    final done = GeolocatorLocator(hub, refine: const Duration(milliseconds: 150)).watch().forEach(fixes.add);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    hub.readings.add(_at(35));
    await done;
    expect(fixes.single!.accuracyM, 35);
  });
}
