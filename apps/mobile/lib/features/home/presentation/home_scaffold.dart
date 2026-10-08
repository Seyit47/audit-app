import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/home_header.dart';
import '../../auth/data/sign_out_service.dart';
import '../../../core/widgets/adaptive.dart';

/// Layout shared by the agent and admin Home frames (`83:16786`, `101:1880`, `246:23129`):
/// glow background, avatar + theme + RU/EN header, tiles, sync pill at the bottom.
class HomeScaffold extends ConsumerWidget {
  const HomeScaffold({super.key, required this.tiles, required this.syncing});

  final List<Widget> tiles;
  final bool syncing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: HomeGlow()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        AppMenuButton<String>(
                          tooltip: l10n.account,
                          choices: [MenuChoice('signOut', l10n.signOut, destructive: true)],
                          onSelected: (_) => ref.read(signOutServiceProvider).signOut(),
                          child: const AppIcon('avatar', width: 36, height: 36),
                        ),
                        const Spacer(),
                        ThemeToggle(
                          tooltip: l10n.toggleTheme,
                          onPressed: () => ref.read(themeModeProvider.notifier).set(dark ? ThemeMode.light : ThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        LocaleToggle(value: locale.languageCode, onChanged: (code) => ref.read(localeProvider.notifier).set(Locale(code))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          for (final (i, tile) in tiles.indexed) ...[if (i > 0) const SizedBox(height: 16), tile],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SyncStatusBadge(label: syncing ? l10n.syncRunning : l10n.syncDone, syncing: syncing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon gradients of the Home tiles (`83:16834`, `83:16849`, `83:16864`).
abstract final class HomeTileGradients {
  static const shops = [Color(0xFF8138CA), Color(0xFF6366F1)];
  static const map = [Color(0xFF5538CA), Color(0xFF6366F1)];
  static const gallery = [Color(0xFF8B46E5), Color(0xFF6366F1)];
}
