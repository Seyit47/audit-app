import 'package:audit_mobile/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

void main() {
  setUpAll(loadFonts);
  testWidgets('logo mark', (tester) async {
    final db = memoryDb();
    await shoot(
      tester,
      'logo',
      const Scaffold(body: Center(child: AppIcon('logo', width: 160, height: 160))),
      db: db,
      height: 400,
    );
    await tester.runAsync(db.close);
  });
}
