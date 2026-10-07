import 'package:audit_mobile/features/admin/data/admin_api.dart';
import 'package:audit_mobile/features/admin/shop_form/presentation/admin_shop_form_screen.dart';
import 'package:audit_mobile/features/admin/shops/presentation/admin_shops_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_admin_api.dart';
import 'harness.dart';

void main() {
  setUpAll(loadFonts);
  for (final dark in [false, true]) {
    testWidgets('admin shops ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await shoot(tester, 'admin-shops', const AdminShopsScreen(), db: db, dark: dark, height: 1051, overrides: [adminApiProvider.overrideWithValue(FakeAdminApi())]);
      await tester.runAsync(db.close);
    });
  }
  testWidgets('admin shop edit', (tester) async {
    final db = memoryDb();
    await shoot(tester, 'admin-shop-edit', const AdminShopFormScreen(shopId: 's0'), db: db, height: 1004, overrides: [adminApiProvider.overrideWithValue(FakeAdminApi())]);
    await tester.runAsync(db.close);
  });
}
