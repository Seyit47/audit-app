import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/l10n.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Uses the device language when supported, otherwise Russian.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  return supported.firstWhere(
    (locale) => locale.languageCode == device?.languageCode,
    orElse: () => const Locale('ru'),
  );
}

class AuditApp extends ConsumerWidget {
  const AuditApp({super.key, this.locale});

  /// Forces a locale (tests); otherwise the device locale is used.
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: locale,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
