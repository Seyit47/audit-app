import 'package:audit_mobile/core/auth/session_provider.dart';
import 'package:audit_mobile/core/auth/session_store.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Store extends Mock implements SessionStore {}

void main() {
  late SharedPreferences prefs;
  late _Store store;

  Future<void> open(WidgetTester tester, {SavedLogin? saved}) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = _Store();
    when(() => store.readSavedLogin()).thenAnswer((_) async => saved);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs), sessionStoreProvider.overrideWithValue(store)],
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

  testWidgets('a remembered sign-in fills the form, with its method and the box ticked', (tester) async {
    await open(
      tester,
      saved: const SavedLogin(method: 'email', login: 'admin@audit.com', password: 'secret1'),
    );
    await tester.pump();
    expect(field(tester, 0).controller!.text, 'admin@audit.com');
    expect(field(tester, 1).controller!.text, 'secret1');
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Remember password'), findsOneWidget);

    await tester.tap(find.text('Remember password'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
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
