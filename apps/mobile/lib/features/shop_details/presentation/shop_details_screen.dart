import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/location/position_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/audit_history_item.dart';
import '../../shops/data/shops_local_repository.dart';
import '../../shops/domain/visit_state.dart';

/// Opens the phone's maps app at the shop (research R-12: no in-app navigation).
Future<void> openInMaps(double lat, double lng, String label) =>
    launchUrl(Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label)})'), mode: LaunchMode.externalApplication);

Future<void> call(String phone) => launchUrl(Uri(scheme: 'tel', path: phone));

/// Shop details (`83:17057` / `106:4035`) from the local mirror.
class ShopDetailsScreen extends ConsumerStatefulWidget {
  const ShopDetailsScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  bool _oldestFirst = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final item = ref.watch(shopProvider(widget.shopId));
    final visits = ref.watch(shopVisitsProvider(widget.shopId)).value ?? const <ShopVisit>[];
    final position = ref.watch(positionProvider).value;
    final shop = item.value?.shop;

    if (shop == null) {
      return Scaffold(
        backgroundColor: c.card,
        body: SafeArea(child: Column(children: [
          const AppTopBar(),
          if (!item.isLoading) Expanded(child: Center(child: Text(l10n.shopNotFound, style: TextStyle(color: c.textSecondary)))),
        ])),
      );
    }
    final info = item.value!.visit;
    final contact = item.value!.contacts.firstOrNull;
    final meters = distanceTo(position, shop.lat, shop.lng);
    final ordered = _oldestFirst ? visits.reversed.toList() : visits;
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary, fontWeight: FontWeight.w500);

    return Scaffold(
      backgroundColor: c.card,
      body: SafeArea(
        child: Column(children: [
          const AppTopBar(),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    AppImage(shop.facadeUrl, width: 70, height: 70, radius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(shop.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, height: 1.5, color: c.textPrimary)),
                        const SizedBox(height: 2),
                        Text(shop.address, style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: c.textPrimary)),
                        const SizedBox(height: 4),
                        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            AppIcon('geo-target', width: 13.69, height: 13.69, color: c.success),
                            const SizedBox(width: 4),
                            Text(coords(shop.lat, shop.lng), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500, color: c.success)),
                          ]),
                          if (meters != null) ...[
                            const Text('•', style: TextStyle(fontSize: 12, color: Color(0xFFC7C4D8))),
                            Text(l10n.fromYou(distance(context, meters)), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, color: c.textSecondary)),
                          ],
                        ]),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Divider(height: 1, thickness: 1, color: c.accent6),
                  const SizedBox(height: 12),
                  if (contact != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Container(
                          width: 32, height: 32, alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFD7E3FF), shape: BoxShape.circle),
                          child: const AppIcon('contact-admin', width: 15, height: 15),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(contact.label ?? l10n.contactPerson, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.textSecondary)),
                            Text(shop.ownerName ?? contact.phone, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
                          ]),
                        ),
                        Material(
                          color: c.card,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 0.5,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => call(contact.phone),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(children: [
                                AppIcon('phone', width: 12, height: 12, color: c.accent),
                                const SizedBox(width: 6),
                                Text(contact.phone, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: c.accent)),
                              ]),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                    child: Column(children: [
                      Row(children: [
                        Text(l10n.lastVisit, style: small),
                        const Spacer(),
                        Text(_lastVisit(context, l10n, shop.lastVisitAt), style: small.copyWith(fontWeight: FontWeight.w400, color: c.textPrimary)),
                      ]),
                      const SizedBox(height: 3.5),
                      Row(children: [
                        Text(l10n.nextVisit, style: small.copyWith(color: info.state == VisitState.overdue ? c.error : c.textSecondary)),
                        const Spacer(),
                        if (info.state == VisitState.overdue) ...[
                          AppIcon('warning-circle', width: 11.67, height: 11.67, color: c.error),
                          const SizedBox(width: 4),
                          Text(l10n.nextVisitOverdue(info.overdueDays), style: small.copyWith(fontWeight: FontWeight.w700, color: c.error)),
                        ] else
                          Text(_nextVisit(context, l10n, shop.nextDueAt), style: small.copyWith(fontWeight: FontWeight.w400, color: c.textPrimary)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: _ActionButton(
                        label: l10n.mapButton, icon: const AppIcon('pin', width: 10, height: 14), filled: false,
                        onTap: () => openInMaps(shop.lat, shop.lng, shop.name),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.auditButton, icon: const AppIcon('play', width: 9.17, height: 11.67), filled: true,
                        onTap: () => context.push('/agent/audit/${shop.id}'),
                      ),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.auditHistory, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      Text(l10n.auditHistoryCount(visits.length), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary)),
                    ]),
                  ),
                  Tooltip(
                    message: _oldestFirst ? l10n.sortOldest : l10n.sortNewest,
                    child: Material(
                      color: c.accent6,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _oldestFirst = !_oldestFirst),
                        child: SizedBox(width: 32, height: 32, child: Center(child: AppIcon('sort', width: 13.5, height: 9, color: c.textSecondary))),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              ColoredBox(
                color: c.mainBg,
                child: ordered.isEmpty
                    ? Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.noAudits, style: TextStyle(color: c.textSecondary))))
                    : Column(children: [
                        for (final (i, v) in ordered.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _visit(context, l10n, v),
                        ],
                        const SizedBox(height: 24),
                      ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _visit(BuildContext context, AppLocalizations l10n, ShopVisit v) {
    final c = context.colors;
    if (v.missed) return AuditHistoryItem(date: longDateTime(context, v.at), status: l10n.visitMissed, statusColor: c.error);
    final meters = v.accuracyM?.round();
    return AuditHistoryItem(
      date: longDateTime(context, v.at),
      coords: v.lat == null ? null : coords(v.lat!, v.lng!),
      status: v.pending ? l10n.pendingSync : null,
      statusColor: c.accent,
      note: v.comment.isEmpty ? null : ViolationNote(text: v.comment, violationLabel: v.hasViolation ? l10n.violationRecorded : null),
      photos: v.photoUrls,
      photoTotal: v.photoCount,
      photosLabel: l10n.photoMaterials(v.photoCount),
      moreLabel: (n) => l10n.morePhotos(n),
      seeAllLabel: l10n.seeAll,
      onSeeAll: () => context.push('/agent/gallery?shopId=${widget.shopId}'),
      accuracy: meters == null ? null : (v.withinRadius ?? true) ? l10n.accuracyInside(meters) : l10n.accuracyOutside(meters),
      accuracyOk: v.withinRadius ?? true,
    );
  }

  String _lastVisit(BuildContext context, AppLocalizations l10n, DateTime? at) {
    if (at == null) return l10n.never;
    final days = DateUtils.dateOnly(DateTime.now()).difference(DateUtils.dateOnly(at.toLocal())).inDays;
    return days == 0 ? l10n.lastVisitToday(hhmm(at)) : l10n.lastVisitDays(dayMonth(context, at), days);
  }

  String _nextVisit(BuildContext context, AppLocalizations l10n, DateTime? at) {
    if (at == null) return l10n.never;
    return DateUtils.isSameDay(at.toLocal(), DateTime.now()) ? l10n.nextVisitToday : dayMonth(context, at);
  }
}

/// "Карта" (secondary) and "Аудит" (accent) buttons of `83:17124`.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.filled, required this.onTap});

  final String label;
  final Widget icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: filled ? c.accent : c.accent6,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (filled) icon else ColorFiltered(colorFilter: ColorFilter.mode(c.textPrimary, BlendMode.srcIn), child: icon),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: filled ? 15 : 14, height: filled ? 1.5 : 20 / 14, fontWeight: FontWeight.w600, color: filled ? Colors.white : c.textPrimary)),
          ]),
        ),
      ),
    );
  }
}
