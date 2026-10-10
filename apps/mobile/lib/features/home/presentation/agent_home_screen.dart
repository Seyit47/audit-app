import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/widgets/home_tiles.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/format/formatters.dart';
import '../../../core/settings/remote_config.dart';
import '../../audit/domain/geofence.dart';
import '../../audit/presentation/audit_controller.dart';
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
        HomeHeroTile(badge: l10n.homePrimaryBadge, title: l10n.homeStartAudit, subtitle: l10n.homeStartAuditHint, onTap: () => _startAudit(context, ref)),
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

  /// "Начать аудит": audits happen only inside a shop's radius, so the shop is the one the agent stands in.
  static Future<void> _startAudit(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    void say(String text) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
    messenger.showSnackBar(SnackBar(content: Text(l10n.locating), duration: const Duration(seconds: 30)));

    final db = ref.read(databaseProvider);
    final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
    final (fix, shops) = await (ref.read(locatorProvider).current(), (db.select(db.shops)..where((s) => s.status.equals('ACTIVE'))).get()).wait;
    if (!context.mounted) return;
    if (fix == null) return say(l10n.geoUnavailable);
    if (fix.accuracyM > config.minGpsAccuracyM) return say(l10n.geoInaccurate(fix.accuracyM.round()));
    final hit = nearestShop(shops, fix, lat: (s) => s.lat, lng: (s) => s.lng, radiusM: (s) => s.auditRadiusM);
    if (hit == null) return say(l10n.shopsEmpty);
    if (!hit.inside) return say(l10n.notInShopRadius(hit.shop.name, distance(context, hit.meters)));
    messenger.hideCurrentSnackBar();
    context.push('/agent/audit/${hit.shop.id}');
  }
}
