import 'dart:io';

import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/core/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1x1 PNG.
final _png = [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

void main() {
  testWidgets('a full-size photo that fails to load shows its preview instead of an empty box', (tester) async {
    late String preview;
    await tester.runAsync(() async {
      final dir = await Directory.systemTemp.createTemp('fallback');
      preview = (await File('${dir.path}/preview.png').writeAsBytes(_png)).path;
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: SizedBox(width: 100, height: 100, child: AppImage('/nowhere/full.jpg', fallback: preview)),
      ),
    );
    // Let the missing file fail to load.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    final files = tester.widgetList<Image>(find.byType(Image)).map((i) => (i.image as FileImage).file.path).toList();
    expect(files, contains(preview));
  });
}
