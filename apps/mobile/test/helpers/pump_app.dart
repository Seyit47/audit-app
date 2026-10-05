import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audit_mobile/core/l10n/l10n.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app's localization, theme and provider setup.
  Future<void> pumpApp(
    Widget widget, {
    List overrides = const [],
    Locale locale = const Locale('ru'),
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: [...overrides],
        child: MaterialApp(
          locale: locale,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
