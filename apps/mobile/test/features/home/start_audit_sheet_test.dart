import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/settings/remote_config.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/core/widgets/buttons.dart';
import 'package:audit_mobile/core/widgets/photo_capture.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:audit_mobile/features/home/presentation/start_audit_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Locator implements Locator {
  _Locator(this.fix);
  final Fix? fix;

  @override
  Future<Fix?> current() async => fix;
}

const shopLat = 37.95;
const shopLng = 58.38;

void main() {
  late AppDatabase db;

  // Real async: drift doesn't finish its queries under the widget test's fake clock.
  Future<void> seed(WidgetTester tester) => tester.runAsync(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.shops)
        .insert(
          ShopsCompanion.insert(
            id: 's1',
            code: 'CL-1',
            name: 'Bahar',
            type: 'MARKET',
            address: 'Street',
            lat: shopLat,
            lng: shopLng,
            auditRadiusM: 100,
            status: 'ACTIVE',
            updatedAt: DateTime.utc(2026, 10, 7),
          ),
        );
  });

  /// Opens the sheet from a button and returns what it popped with.
  Future<String? Function()> open(WidgetTester tester, Fix? fix) async {
    String? popped;
    await seed(tester);
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locatorProvider.overrideWithValue(_Locator(fix)),
          remoteConfigProvider.overrideWith((ref) => Stream.value(const RemoteConfig())),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) => TextButton(onPressed: () async => popped = await showStartAuditSheet(context), child: const Text('go')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Determining location...'), findsOneWidget);
    // The radar runs at least 1.2 s; then the result animates in.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    return () => popped;
  }

  testWidgets('inside the radius: Start pops with the shop', (tester) async {
    final popped = await open(tester, const Fix(lat: shopLat, lng: shopLng + 0.0005, accuracyM: 8));
    expect(find.text("You're within Bahar's radius"), findsOneWidget);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Start audit'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(popped(), 's1');
  });

  testWidgets('outside the radius: says how far the nearest shop is and offers a recheck', (tester) async {
    final popped = await open(tester, const Fix(lat: shopLat, lng: shopLng + 0.01, accuracyM: 8));
    expect(find.textContaining("You're not within a shop's radius. Nearest: Bahar"), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(popped(), isNull);
  });

  testWidgets('no fix: location unavailable', (tester) async {
    await open(tester, null);
    expect(find.text('Location unavailable'), findsOneWidget);
  });
}
