import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/widgets/home_tiles.dart';
import '../../route/data/route_local_repository.dart';
import 'home_scaffold.dart';

/// Agent Home (`83:16786` / `101:1880`).
class AgentHomeScreen extends ConsumerWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return HomeScaffold(
      syncing: ref.watch(syncStatusProvider) == SyncStatus.syncing,
      tiles: [
        HomeHeroTile(
          badge: l10n.homePrimaryBadge,
          title: l10n.homeStartAudit,
          subtitle: l10n.homeStartAuditHint,
          onTap: () async {
            // The next stop of today's route; without one, the agent picks a shop.
            final stop = await ref.read(routeLocalRepositoryProvider).nextStop();
            if (!context.mounted) return;
            context.push(stop == null ? '/agent/shops' : '/agent/audit/${stop.shopId}');
          },
        ),
        HomeActionTile(
          icon: 'home-shops', iconSize: const Size(21.77, 19.5), iconGradient: HomeTileGradients.shops,
          title: l10n.homeMyShops, subtitle: l10n.homeMyShopsHint, onTap: () => context.push('/agent/shops'),
        ),
        HomeActionTile(
          icon: 'home-map', iconSize: const Size(19.5, 19.5), iconGradient: HomeTileGradients.map,
          title: l10n.homeMap, subtitle: l10n.homeMapHint, onTap: () => context.push('/agent/map'),
        ),
        HomeActionTile(
          icon: 'home-gallery', iconSize: const Size(21.67, 21.67), iconGradient: HomeTileGradients.gallery,
          title: l10n.homeGallery, subtitle: l10n.homeGalleryHint, onTap: () => context.push('/agent/gallery'),
        ),
      ],
    );
  }
}
