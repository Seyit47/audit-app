import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/location/tracker.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/sync/sync_providers.dart';
import 'core/theme/app_theme.dart';

class AuditApp extends ConsumerWidget {
  const AuditApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the agent's sync triggers once a session exists.
    ref.watch(syncControllerProvider);
    // Location tracking for agents within working hours (T102).
    ref.watch(trackerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
