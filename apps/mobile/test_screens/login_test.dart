import 'package:audit_mobile/core/auth/session_provider.dart';
import 'package:audit_mobile/core/auth/session_store.dart';
import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/features/auth/presentation/login_screen.dart';
import 'package:audit_mobile/features/update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'harness.dart';

class _Store extends Mock implements SessionStore {}

void main() {
  setUpAll(loadFonts);
  testWidgets('login with a remembered sign-in', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = _Store();
    when(() => store.readTokens()).thenAnswer((_) async => null);
    when(() => store.readSavedLogin()).thenAnswer((_) async => const SavedLogin(method: 'phone', login: '+993 65 123456', password: 'Agent12345'));
    final db = memoryDb();
    await shoot(
      tester,
      'login',
      const LoginScreen(),
      db: db,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionStoreProvider.overrideWithValue(store),
        appVersionProvider.overrideWith((ref) async => ('1.0.52', 53)),
      ],
    );
    await tester.runAsync(db.close);
  });
}
