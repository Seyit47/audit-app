import 'dart:io';
import 'dart:ui' as ui;

import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/core/widgets/adaptive.dart';
import 'package:audit_mobile/core/widgets/app_top_bar.dart';
import 'package:audit_mobile/core/widgets/buttons.dart';
import 'package:audit_mobile/core/widgets/filter_chips.dart';
import 'package:audit_mobile/core/widgets/form_field.dart';
import 'package:audit_mobile/core/widgets/home_header.dart';
import 'package:audit_mobile/core/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

/// A sheet of the shared controls on each platform and theme, at 2x, to check radii, sizes and
/// centering: `flutter test test_screens/components_test.dart`.
void main() {
  setUpAll(loadFonts);
  final boundary = GlobalKey();

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final dark in [false, true]) {
      testWidgets('components ${platform.name} ${dark ? 'dark' : 'light'}', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 760 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        final theme = (dark ? AppTheme.dark() : AppTheme.light()).copyWith(platform: platform);
        Widget row(String label, Widget child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [SizedBox(width: 92, child: Text(label, style: const TextStyle(fontSize: 10))), Expanded(child: Align(alignment: Alignment.centerLeft, child: child))]),
            );
        await tester.pumpWidget(RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: const Locale('ru'),
            supportedLocales: const [Locale('ru'), Locale('en')],
            localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const AppTopBar(title: 'Клиенты', count: 12, action: HeaderButton(label: 'Добавить', onPressed: _noop)),
                  row('header', Row(children: [const ThemeToggle(onPressed: _noop, tooltip: 'theme'), const SizedBox(width: 8), LocaleToggle(value: 'ru', onChanged: (_) {})])),
                  row('lang en', LocaleToggle(value: 'en', onChanged: (_) {})),
                  row('primary', const SizedBox(width: 260, child: PrimaryButton(label: 'Сохранить', onPressed: _noop))),
                  row('loading', const SizedBox(width: 260, child: PrimaryButton(label: 'Сохранить', onPressed: _noop, loading: true))),
                  row('disabled', const SizedBox(width: 260, child: PrimaryButton(label: 'Сохранить', onPressed: null))),
                  row('secondary', const SizedBox(width: 260, child: SecondaryButton(label: 'Отмена', onPressed: _noop))),
                  row('chips', FilterChips<String>(options: const [ChipOption('all', 'Все'), ChipOption('a', 'Активные'), ChipOption('v', 'Нарушения', tone: ChipTone.error)], selected: 'all', onSelected: (_) {})),
                  row('search', SizedBox(width: 270, child: SearchField(hint: 'Поиск', onChanged: (_) {}, onFilters: _noop, activeFilters: 2))),
                  row('input', const SizedBox(width: 270, child: AppTextInput(hint: 'Название'))),
                  row('select', SizedBox(width: 270, child: AppSelect<String>(value: 'a', hint: 'Регион', items: const [('a', 'Region 1'), ('b', 'Region 2')], onChanged: (_) {}))),
                ]),
              ),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 400));
        final out = Platform.environment['SCREENS_OUT'] ?? 'build/screens';
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$out/components-${platform.name}${dark ? '-dark' : ''}.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      });
    }
  }
}

void _noop() {}
