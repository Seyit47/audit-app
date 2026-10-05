import 'package:audit_mobile/app.dart';
import 'package:audit_mobile/features/session/domain/role.dart';
import 'package:audit_mobile/features/session/domain/session.dart';
import 'package:audit_mobile/features/session/presentation/session_provider.dart';
import 'package:audit_mobile/features/system/domain/compatibility.dart';
import 'package:audit_mobile/features/system/domain/version_info.dart';
import 'package:audit_mobile/features/system/presentation/compatibility_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedIn extends SessionNotifier {
  _SignedIn(this.session);
  final Session session;
  @override
  Session? build() => session;
}

class _Compatible extends CompatibilityNotifier {
  @override
  Future<Compatibility> build() async => const Compatible(
    VersionInfo(
      serverVersion: '1.0.0',
      minMobileVersion: '0.1.0',
      minAdminWebVersion: '0.1.0',
      environment: 'development',
    ),
  );
}

Future<void> pumpAppAs(WidgetTester tester, Role role) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith(
          () => _SignedIn(Session(userId: 'dev', role: role)),
        ),
        compatibilityProvider.overrideWith(_Compatible.new),
      ],
      child: const AuditApp(locale: Locale('ru')),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> navLabels(WidgetTester tester) => tester
    .widgetList<NavigationDestination>(find.byType(NavigationDestination))
    .map((d) => d.label)
    .toList();

void main() {
  testWidgets('agent sees exactly the agent tabs and role', (tester) async {
    await pumpAppAs(tester, Role.agent);
    expect(navLabels(tester), ['Главная', 'Магазины', 'Карта', 'Галерея']);
    expect(find.text('Агент'), findsOneWidget);
  });

  testWidgets('admin sees exactly the admin tabs and role', (tester) async {
    await pumpAppAs(tester, Role.admin);
    expect(navLabels(tester), [
      'Главная',
      'Магазины',
      'Агенты',
      'Карта',
      'Галерея',
    ]);
    expect(find.text('Администратор'), findsOneWidget);
  });
}
