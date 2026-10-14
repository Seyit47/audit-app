import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  Future<void> open(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: const LoginScreen(),
        ),
      ),
    );
  }

  TextField field(WidgetTester tester, int i) => tester.widgetList<TextField>(find.byType(TextField)).elementAt(i);

  testWidgets('phone by default, formatted while typing', (tester) async {
    await open(tester);
    expect(find.textContaining('Phone number', findRichText: true), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '65123456');
    expect(field(tester, 0).controller!.text, '+993 65 123456');
  });

  testWidgets('email: the error waits until the field is left; the choice is remembered', (tester) async {
    await open(tester);
    await tester.tap(find.text('Email').first);
    await tester.pump();
    expect(prefs.getString('login_method'), 'email');

    await tester.enterText(find.byType(TextField).first, 'admin@audit');
    await tester.pump();
    expect(find.text('Enter an email like name@company.com'), findsNothing, reason: 'still typing');

    await tester.tap(find.byType(TextField).last); // move to the password
    await tester.pump();
    expect(find.text('Enter an email like name@company.com'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'admin@audit.com');
    await tester.pump();
    expect(find.text('Enter an email like name@company.com'), findsNothing);
  });

  testWidgets('the eye shows and hides the password', (tester) async {
    await open(tester);
    expect(field(tester, 1).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field(tester, 1).obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(field(tester, 1).obscureText, isTrue);
  });
}
