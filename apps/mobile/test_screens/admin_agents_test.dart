import 'package:audit_mobile/features/admin/agent_form/presentation/agent_form_screen.dart';
import 'package:audit_mobile/features/admin/agents/presentation/agents_screen.dart';
import 'package:audit_mobile/features/admin/data/admin_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_admin_api.dart';
import 'harness.dart';

class _Api extends FakeAdminApi {
  @override
  Future<List<Json>> positions() async => [];
  @override
  Future<String> nextAgentCode() async => 'SL-107';
}

void main() {
  setUpAll(loadFonts);
  for (final dark in [false, true]) {
    testWidgets('agents ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await shoot(tester, 'agents', const AgentsScreen(), db: db, dark: dark, height: 1001, overrides: [adminApiProvider.overrideWithValue(_Api())]);
      await tester.runAsync(db.close);
    });
  }
  testWidgets('agent form', (tester) async {
    final db = memoryDb();
    await shoot(tester, 'agent-form', const AgentFormScreen(), db: db, height: 1000, overrides: [adminApiProvider.overrideWithValue(_Api())]);
    await tester.runAsync(db.close);
  });
}
