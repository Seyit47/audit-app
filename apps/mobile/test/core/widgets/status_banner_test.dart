import 'package:audit_mobile/core/widgets/status_banner.dart';
import 'package:audit_mobile/features/system/presentation/update_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the checking state', (tester) async {
    await tester.pumpApp(const StatusBanner.checking());
    expect(find.text('Подключение к серверу...'), findsOneWidget);
  });

  testWidgets('shows the connected state with the server version', (
    tester,
  ) async {
    await tester.pumpApp(const StatusBanner.connected(version: '1.2.3'));
    expect(find.text('Сервер подключён · v1.2.3'), findsOneWidget);
  });

  testWidgets('shows the unreachable state and calls retry', (tester) async {
    var retried = false;
    await tester.pumpApp(
      StatusBanner.unreachable(onRetry: () => retried = true),
    );
    expect(find.textContaining('Сервис временно недоступен'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Повторить'));
    expect(retried, isTrue);
  });

  testWidgets('update required screen explains the update', (tester) async {
    await tester.pumpApp(const UpdateRequiredScreen());
    expect(find.textContaining('Требуется обновление'), findsOneWidget);
  });
}
