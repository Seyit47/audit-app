import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/location/location_hub.dart';
import '../../../core/location/position_provider.dart';
import '../../../core/settings/remote_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/tap.dart';
import '../../shops/data/shops_local_repository.dart' show ShopItem;
import '../domain/geofence.dart';
import 'audit_controller.dart';

/// Whether the agent can start an audit of [shop] where they are now: the same check as the audit screen
/// (inside the radius, on a position at least as precise as the company requires, an active shop).
GeoStatus auditGate(WidgetRef ref, ShopItem item) {
  final shop = item.shop;
  if (shop.status != 'ACTIVE') return GeoStatus.notActive;
  final p = ref.watch(positionProvider).value;
  final minAccuracyM = (ref.watch(remoteConfigProvider).value ?? const RemoteConfig()).minGpsAccuracyM;
  return geofence(fix: _fix(p), shopLat: shop.lat, shopLng: shop.lng, radiusM: shop.auditRadiusM, minAccuracyM: minAccuracyM);
}

Fix? _fix(Position? p) => p == null ? null : Fix(lat: p.latitude, lng: p.longitude, accuracyM: p.accuracy);

/// Why the audit button is hidden: no position yet (and why: location off, no permission, approximate
/// only), a rough position, or too far from the shop. With no position, "Проверить заново" starts location
/// again and checks the phone's settings.
class AuditGateNotice extends ConsumerWidget {
  const AuditGateNotice({super.key, required this.status, required this.radiusM});

  final GeoStatus status;
  final int radiusM;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final accuracy = ref.watch(positionProvider).value?.accuracy;
    final noPosition = status == GeoStatus.unavailable || status == GeoStatus.locating;
    final problem = noPosition ? ref.watch(locationProblemProvider).value : null;
    final text = switch (status) {
      GeoStatus.inaccurate => l10n.geoInaccurate((accuracy ?? 0).round()),
      GeoStatus.outside => l10n.auditOnlyInRadius(radiusM),
      // Location off, no permission or approximate only: say what to do; otherwise it is still looking.
      _ => problem == null || problem == LocationProblem.noSignal ? l10n.locating : locationProblemText(l10n, problem),
    };
    final style = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500, color: c.error);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.alertBg,
        border: Border.all(color: c.alertBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: AppIcon('alert-triangle', width: 12.75, height: 11.98, color: c.error),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: style)),
          if (noPosition || status == GeoStatus.inaccurate) ...[
            const SizedBox(width: 8),
            TextLink(
              onTap: () {
                ref.read(locationHubProvider).restart();
                ref.invalidate(locationProblemProvider);
              },
              child: Text(
                l10n.recheck,
                style: style.copyWith(fontWeight: FontWeight.w700, color: c.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
