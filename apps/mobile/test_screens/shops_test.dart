import 'package:audit_mobile/features/shop_details/presentation/shop_details_screen.dart';
import 'package:audit_mobile/features/shops/presentation/shops_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

void main() {
  setUpAll(loadFonts);

  for (final dark in [false, true]) {
    testWidgets('shops ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(tester, 'shops', const ShopsScreen(), db: db, dark: dark, height: 890);
      await tester.runAsync(db.close);
    });

    testWidgets('shop details ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(
        tester,
        'shop-details',
        const ShopDetailsScreen(shopId: 's0'),
        db: db,
        dark: dark,
        height: 961,
      );
      await tester.runAsync(db.close);
    });
  }
}
