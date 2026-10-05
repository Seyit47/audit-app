import 'package:audit_mobile/app.dart';
import 'package:audit_mobile/core/theme/app_colors.dart';
import 'package:audit_mobile/features/system/domain/compatibility.dart';
import 'package:audit_mobile/features/system/presentation/compatibility_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Unreachable extends CompatibilityNotifier {
  @override
  Future<Compatibility> build() async => const Unreachable();
}

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [compatibilityProvider.overrideWith(_Unreachable.new)],
      child: const AuditApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('falls back to Russian for an unsupported device locale', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(tester);
    expect(find.text('Выберите роль (режим разработки)'), findsOneWidget);
  });

  testWidgets('uses English when the device is English', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await pumpApp(tester);
    expect(find.text('Choose a role (development mode)'), findsOneWidget);
  });

  testWidgets('follows the system dark mode', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    final background =
        scaffold.backgroundColor ??
        Theme.of(tester.element(find.byType(Scaffold).first))
            .scaffoldBackgroundColor;
    expect(background, AppColors.dark.background);
  });
}
