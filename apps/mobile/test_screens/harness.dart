import 'dart:io';
import 'dart:ui' as ui;

import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders screens at the Figma frame size (390 wide, 2x) with the real fonts and writes PNGs to
/// `$SCREENS_OUT` for the design pass (T128). Run: `flutter test test_screens/<file>`.
Future<void> loadFonts() async {
  const families = {
    'Inter': ['Inter-Regular', 'Inter-Medium', 'Inter-SemiBold', 'Inter-Bold', 'Inter-ExtraBold'],
    'SpaceGrotesk': ['SpaceGrotesk-400', 'SpaceGrotesk-500', 'SpaceGrotesk-600', 'SpaceGrotesk-700'],
  };
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
    }
    await loader.load();
  }
}

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

final _boundary = GlobalKey();

Future<void> shoot(
  WidgetTester tester,
  String name,
  Widget screen, {
  required AppDatabase db,
  List<Override> overrides = const [],
  bool dark = false,
  String locale = 'ru',
  double height = 844,
  /// Runs in real async against the providers before the first frame (start controllers, fill
  /// forms): drift work inside the widget test's fake async never completes.
  Future<void> Function(ProviderContainer container)? before,
}) async {
  tester.view.physicalSize = Size(390 * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db), ...overrides]);
  addTearDown(container.dispose);
  if (before != null) await tester.runAsync(() => before(container));
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(locale),
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  ));
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  await settle();
  final out = Platform.environment['SCREENS_OUT'] ?? 'build/screens';
  await tester.runAsync(() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$out/$name${dark ? '-dark' : ''}.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
