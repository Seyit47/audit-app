import 'package:audit_mobile/features/map/presentation/agent_map_screen.dart' show ShopSheet;
import 'package:audit_mobile/features/shops/data/shops_local_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

void main() {
  setUpAll(loadFonts);

  for (final dark in [false, true]) {
    testWidgets('map sheet ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      final shops = await tester.runAsync(() => ShopsLocalRepository(db).watchAll().first);
      await shoot(tester, 'map-sheet', Scaffold(backgroundColor: const Color(0xFFEAF1EC), body: Align(alignment: Alignment.bottomCenter, child: ShopSheet(item: shops!.first, meters: 1200))), db: db, dark: dark);
      await tester.runAsync(db.close);
    });
  }

}
