import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/features/update/app_update.dart';
import 'package:audit_mobile/features/update/updates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Service extends UpdateService {
  _Service(this.result) : super(() => 'http://server');
  UpdateCheck result;

  @override
  Future<UpdateCheck> checkNow() async => result;
}

void main() {
  testWidgets('shows the installed version; the check says up to date or unreachable', (tester) async {
    final service = _Service(const UpdateCheck(UpdateCheckStatus.upToDate));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [updateServiceProvider.overrideWithValue(service), appVersionProvider.overrideWith((ref) async => ('1.0.30', 31))],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: const UpdatesScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Version 1.0.30 (31)'), findsOneWidget);

    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(find.text('You have the latest version'), findsOneWidget);

    service.result = const UpdateCheck(UpdateCheckStatus.unreachable);
    await tester.tap(find.text('Check for updates'));
    await tester.pump();
    expect(find.textContaining("Couldn't reach the server"), findsOneWidget);
  });
}
