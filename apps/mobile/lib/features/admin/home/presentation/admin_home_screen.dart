import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/widgets/home_tiles.dart';
import '../../../home/presentation/home_scaffold.dart';

/// Admin Home (`246:23129`). Admins work online, so the pill always shows the synced state.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return HomeScaffold(
      syncing: false,
      tiles: [
        HomeActionTile(
          icon: 'home-map',
          iconSize: const Size(19.5, 19.5),
          iconGradient: HomeTileGradients.map,
          title: l10n.homeMap,
          subtitle: l10n.homeMapHint,
          onTap: () => context.push('/admin/map'),
        ),
        HomeActionTile(
          icon: 'home-shops',
          iconSize: const Size(21.77, 19.5),
          iconGradient: HomeTileGradients.shops,
          title: l10n.homeShops,
          subtitle: l10n.homeMyShopsHint,
          onTap: () => context.push('/admin/shops'),
        ),
        HomeActionTile(
          icon: 'home-gallery',
          iconSize: const Size(21.67, 21.67),
          iconGradient: HomeTileGradients.gallery,
          title: l10n.homeGallery,
          subtitle: l10n.homeGalleryHint,
          onTap: () => context.push('/admin/gallery'),
        ),
        HomeActionTile(
          icon: 'home-agents',
          iconSize: const Size(24, 24),
          iconGradient: HomeTileGradients.gallery,
          title: l10n.homeAgents,
          subtitle: l10n.homeAgentsHint,
          onTap: () => context.push('/admin/agents'),
        ),
        HomeActionTile(
          icon: 'home-products',
          iconSize: const Size(23, 23),
          iconGradient: HomeTileGradients.gallery,
          title: l10n.homeProducts,
          subtitle: l10n.homeProductsHint,
          onTap: () => context.push('/admin/products'),
        ),
      ],
    );
  }
}
