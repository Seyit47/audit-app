import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/widgets/home_tiles.dart';
import 'home_scaffold.dart';

/// Agent Home (`83:16786` / `101:1880`) without the "Начать аудит" tile (asked for): an audit starts from the
/// shop's screen or the map, where the shop is already chosen.
class AgentHomeScreen extends ConsumerWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return HomeScaffold(
      syncing: ref.watch(syncStatusProvider) == SyncStatus.syncing,
      pending: ref.watch(syncPendingProvider).value ?? 0,
      onSync: () => context.push('/agent/sync'),
      tiles: [
        HomeActionTile(
          icon: 'home-shops',
          iconSize: const Size(21.77, 19.5),
          iconGradient: HomeTileGradients.shops,
          title: l10n.homeMyShops,
          subtitle: l10n.homeMyShopsHint,
          onTap: () => context.push('/agent/shops'),
        ),
        HomeActionTile(
          icon: 'home-map',
          iconSize: const Size(19.5, 19.5),
          iconGradient: HomeTileGradients.map,
          title: l10n.homeMap,
          subtitle: l10n.homeMapHint,
          onTap: () => context.push('/agent/map'),
        ),
        HomeActionTile(
          icon: 'home-gallery',
          iconSize: const Size(21.67, 21.67),
          iconGradient: HomeTileGradients.gallery,
          title: l10n.homeGallery,
          subtitle: l10n.homeGalleryHint,
          onTap: () => context.push('/agent/gallery'),
        ),
      ],
    );
  }
}
