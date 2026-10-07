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
    // Keeps the agent's sync triggers (once a session exists) and location tracking within working hours
    // (T102) alive. Listened, not watched: their state changes must not rebuild the whole app.
    ref.listen(syncControllerProvider, (_, _) {});
    ref.listen(trackerProvider, (_, _) {});
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      // Switches at once, like a native theme change; the default 200 ms cross-fade rebuilt every widget
      // on every frame.
      themeAnimationStyle: AnimationStyle.noAnimation,
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
