import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/location/position_provider.dart';
import 'package:audit_mobile/core/settings/remote_config.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/features/shop_details/presentation/shop_details_screen.dart';
import 'package:audit_mobile/features/shops/data/shops_local_repository.dart';
import 'package:audit_mobile/features/shops/domain/visit_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

const shopLat = 37.95;
const shopLng = 58.38;

Position _at(double lng, {double accuracy = 8}) => Position(
  latitude: shopLat,
  longitude: lng,
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
  Future<void> open(WidgetTester tester, Position? position) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final shop = Shop(
      id: 's1',
      code: 'CL-1',
      name: 'Bahar',
      type: 'MARKET',
      address: 'Street',
      lat: shopLat,
      lng: shopLng,
      auditRadiusM: 100,
      status: 'ACTIVE',
      latestVisitsJson: '[]',
      updatedAt: DateTime(2026, 10, 17),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shopProvider.overrideWith((ref, id) => Stream.value(ShopItem(shop: shop, contacts: const [], visit: const VisitInfo(VisitState.notVisited)))),
          shopVisitsProvider.overrideWith((ref, id) => Stream.value(const <ShopVisit>[])),
          positionProvider.overrideWith((ref) => Stream.value(position)),
          remoteConfigProvider.overrideWith((ref) => Stream.value(const RemoteConfig())),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: const ShopDetailsScreen(shopId: 's1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool auditEnabled(WidgetTester tester) {
    final button = find.ancestor(of: find.text('Audit'), matching: find.byWidgetPredicate((w) => w.runtimeType.toString() == '_ActionButton'));
    return (tester.widget(button) as dynamic).onTap != null;
  }

  testWidgets('inside the radius: Audit opens', (tester) async {
    await open(tester, _at(shopLng + 0.0005)); // ~44 m
    expect(auditEnabled(tester), isTrue);
    expect(find.textContaining('only within'), findsNothing);
  });

  testWidgets('outside the radius: Audit is disabled and says why', (tester) async {
    await open(tester, _at(shopLng + 0.01)); // ~880 m
    expect(auditEnabled(tester), isFalse);
    expect(find.text('An audit is possible only within 100 m of the shop'), findsOneWidget);
  });

  testWidgets('a rough position does not count', (tester) async {
    await open(tester, _at(shopLng, accuracy: 120));
    expect(auditEnabled(tester), isFalse);
    expect(find.text('Weak GPS signal (accuracy 120 m)'), findsOneWidget);
  });
}
