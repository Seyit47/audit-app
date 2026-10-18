// Screen renders run outside test/, where the analyzer does not treat them as tests.
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:audit_mobile/core/location/position_provider.dart';
import 'package:audit_mobile/core/widgets/map_view.dart';
import 'package:audit_mobile/features/map/data/directions.dart';
import 'package:audit_mobile/features/map/domain/route_progress.dart';
import 'package:audit_mobile/features/map/presentation/agent_map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audit_mobile/features/shops/data/shops_local_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

void main() {
  setUpAll(loadFonts);
  mapWithDirections();

  for (final dark in [false, true]) {
    testWidgets('map sheet ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      final shops = await tester.runAsync(() => ShopsLocalRepository(db).watchAll().first);
      await shoot(
        tester,
        'map-sheet',
        Scaffold(
          backgroundColor: const Color(0xFFEAF1EC),
          body: Align(
            alignment: Alignment.bottomCenter,
            child: ShopSheet(item: shops!.first, meters: 1200),
          ),
        ),
        db: db,
        dark: dark,
      );
      await tester.runAsync(db.close);
    });
  }
}

class _Directions implements DirectionsApi {
  @override
  Future<Directions> route(LatLngPoint from, LatLngPoint to) async => Directions(points: [from, to], distanceM: 1850, durationS: 330);
}

void mapWithDirections() {
  testWidgets('map with directions', (tester) async {
    AppMapView.nativeMap = false;
    addTearDown(() => AppMapView.nativeMap = true);
    final db = memoryDb();
    await tester.runAsync(() => seed(db));
    final here = Position(
      latitude: 37.94,
      longitude: 58.37,
      timestamp: DateTime(2026, 10, 18),
      accuracy: 6,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    await shoot(
      tester,
      'map-directions',
      const AgentMapScreen(focusShopId: 's0'),
      db: db,
      overrides: [directionsApiProvider.overrideWithValue(_Directions()), positionProvider.overrideWith((ref) => Stream.value(here))],
    );
    await tester.runAsync(db.close);
  });
}
