import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/audit_history_item.dart';
import '../../../../core/widgets/map_view.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../shop_details/presentation/shop_details_screen.dart' show call, openInMaps;
import '../../data/admin_api.dart';
import '../../shops/shop_labels.dart';
import '../../../../core/widgets/tap.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/adaptive.dart';

class _Data {
  const _Data(this.shop, this.visits, this.photos, this.agentOnline);

  final Json shop;
  final List<Json> visits;
  final List<Json> photos;
  final bool agentOnline;
}

final _shopDataProvider = FutureProvider.autoDispose.family<_Data, String>((ref, id) async {
  final api = ref.watch(adminApiProvider);
  final shop = await api.shop(id);
  final agentId = (shop['agent'] as Map?)?['id'];
  final results = await Future.wait([
    api.shopVisits(id),
    api.photos(shopId: id, limit: 3).then((r) => [for (final i in r['items'] as List) (i as Map).cast<String, dynamic>()]),
    agentId == null ? Future.value(<Json>[]) : api.positions().catchError((_) => <Json>[]),
  ]);
  final positions = results[2];
  final online = positions.any((p) => p['agentId'] == agentId && DateTime.now().difference(DateTime.parse(p['recordedAt'] as String)).inMinutes < 45);
  return _Data(shop, results[0], results[1], online);
});

/// Admin mobile Shop details (`248:24538`).
class AdminShopDetailsScreen extends ConsumerWidget {
  const AdminShopDetailsScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final data = ref.watch(_shopDataProvider(shopId));
    final s = data.value?.shop;

    Widget iconButton(String icon, Size size, String tip, VoidCallback onTap) =>
        IconButton(tooltip: tip, onPressed: onTap, icon: AppIcon(icon, width: size.width, height: size.height, color: c.textSecondary));

    final header = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: c.mainBg.withValues(alpha: 0.8), boxShadow: const [BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 8)]),
      child: Row(children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
          icon: AppIcon('arrow-back', width: 16, height: 16, color: c.textPrimary),
        ),
        const SizedBox(width: 4),
        Text(l10n.shopDetailsTitle, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600, color: c.textPrimary)),
        const Spacer(),
        if (s != null)
          AppMenuButton<String>(
            tooltip: l10n.actions,
            choices: [MenuChoice('edit', l10n.editShop), MenuChoice('share', l10n.share)],
            onSelected: (v) => v == 'edit' ? _edit(context, ref) : _share(s),
            child: Padding(padding: const EdgeInsets.all(12), child: AppIcon('kebab', width: 3.67, height: 14.67, color: c.textSecondary)),
          ),
        Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
            child: const AppIcon('avatar-small', width: 12, height: 12)),
      ]),
    );

    if (s == null) {
      return Scaffold(
        backgroundColor: c.mainBg,
        body: SafeArea(child: Column(children: [
          header,
          Expanded(child: data.hasError ? Center(child: LoadErrorView(onRetry: () => ref.invalidate(_shopDataProvider(shopId)))) : const SingleChildScrollView(padding: EdgeInsets.all(16), physics: NeverScrollableScrollPhysics(), child: CardListSkeleton(count: 4, lines: 3))),
        ])),
      );
    }

    final d = data.value!;
    final kpis = (s['kpis'] as Map?) ?? const {};
    final agent = (s['agent'] as Map?)?.cast<String, dynamic>();
    final contacts = ((s['contacts'] as List?) ?? const []).cast<Map>();
    final contact = contacts.firstOrNull;
    final lastAudit = kpis['lastAuditAt'] as String?;
    final lat = (s['lat'] as num).toDouble();
    final lng = (s['lng'] as num).toDouble();
    final card = BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.cardBorder),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)]);
    final caption = TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.textSecondary);
    final value = TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: c.textPrimary);
    final overline = TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.w500, color: c.textSecondary);

    Widget metric(String icon, Size size, Color tint, String label, String text) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: c.secondaryBg, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: tint.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: AppIcon(icon, width: size.width, height: size.height)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: caption),
                  Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: value),
                ]),
              ),
            ]),
          ),
        );

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          header,
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () => ref.refresh(_shopDataProvider(shopId).future),
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: card,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [Tag(shopTypeLabel(l10n, s['type'] as String?), strong: true), const SizedBox(width: 6), Tag(s['code'] as String)]),
                          const SizedBox(height: 4),
                          Text(s['name'] as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 24, height: 1.25, fontWeight: FontWeight.w700, color: c.textPrimary)),
                        ]),
                      ),
                      iconButton('share', const Size(15, 16.67), l10n.share, () => _share(s)),
                      iconButton('edit', const Size(15, 15), l10n.editShop, () => _edit(context, ref)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      metric('kpi-audits', const Size(16.5, 15.75), c.accent, l10n.totalAudits, l10n.auditsCount((kpis['totalAudits'] as int?) ?? 0)),
                      const SizedBox(width: 8),
                      metric('kpi-last-visit', const Size(13.5, 13.5), const Color(0xFF005CBA), l10n.lastVisitTitle,
                          lastAudit == null ? l10n.never : shortDateTime(context, DateTime.parse(lastAudit))),
                    ]),
                    if (contact != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: c.secondaryBg, borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFD7E3FF), shape: BoxShape.circle),
                              child: const AppIcon('contact-admin-accent', width: 15, height: 15)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text((contact['label'] as String?) ?? l10n.contactPerson, style: caption),
                              Text((s['ownerName'] as String?) ?? (contact['phone'] as String), maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: value.copyWith(fontSize: 13, height: 1.5)),
                            ]),
                          ),
                          _pill(context, 'phone-accent', contact['phone'] as String, () => call(contact['phone'] as String)),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: card,
                  child: Column(children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: c.darkAccent, borderRadius: BorderRadius.circular(6)),
                          child: AppIcon('location', width: 12, height: 15, color: c.textSecondary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.addressRegion.toUpperCase(), style: overline),
                          Text(s['address'] as String, style: value.copyWith(fontSize: 16, height: 1.5)),
                          Text([s['addressDetail'], (s['region'] as Map?)?['name']].whereType<String>().join(' • '), style: caption.copyWith(fontSize: 12, fontWeight: FontWeight.w400)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      const AppIcon('person-tile', width: 28, height: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.responsibleAgent.toUpperCase(), style: overline),
                          Text((agent?['fullName'] as String?) ?? l10n.unassigned, style: value.copyWith(fontSize: 16, height: 1.5)),
                          if (agent != null)
                            Row(children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: d.agentOnline ? c.success : c.textSecondary, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(d.agentOnline ? l10n.onShift : l10n.offShift, style: caption.copyWith(fontSize: 12, color: d.agentOnline ? c.accent : c.textSecondary)),
                            ]),
                        ]),
                      ),
                      if (agent?['phone'] != null) _pill(context, 'phone-small', l10n.contact, () => call(agent!['phone'] as String), filled: true),
                    ]),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: card,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Text(l10n.photoReports, style: value),
                      const SizedBox(width: 8),
                      Tag('${(kpis['auditPhotos'] as int?) ?? d.photos.length}'),
                      const Spacer(),
                      TextLink(
                        onTap: () => context.push('/admin/gallery?shopId=$shopId'),
                        child: Row(children: [
                          Text(l10n.openGallery, style: AppTextStyles.label.copyWith(color: c.accent)),
                          const SizedBox(width: 4),
                          const AppIcon('chevron-right-accent', width: 4.93, height: 8),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 112,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: d.photos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final p = d.photos[i];
                          return InkOverlay(radius: 8, 
                            onTap: () => context.push('/admin/gallery/${p['id']}'),
                            child: AppImage((p['previewUrl400'] ?? p['url']) as String?, width: 112, height: 112),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: card,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(child: Text(l10n.geolocation, style: value.copyWith(height: 24 / 14))),
                      Text('${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E', style: TextStyle(fontFamily: AppTextStyles.mono, fontSize: 12, color: c.textSecondary)),
                    ]),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(children: [
                          Positioned.fill(
                            child: AppMapView(
                              controller: AppMapController(),
                              initial: (lat, lng),
                              // Tapping the preview opens the full map on this shop.
                              onMapTap: () => context.push('/admin/map?shop=$shopId'),
                              onMarkerTap: (_) => context.push('/admin/map?shop=$shopId'),
                              markers: [MapMarker(id: shopId, lat: lat, lng: lng, color: c.accent, imageUrl: (s['facade'] as Map?)?['previewUrl400'] as String?)],
                            ),
                          ),
                          Positioned(
                            right: 8, bottom: 8,
                            child: _pill(context, 'navigate-small', l10n.navigate, () => openInMaps(lat, lng, s['name'] as String), elevated: true),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
                Text(l10n.auditHistory, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
                Text(l10n.auditHistoryCount(d.visits.length), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary)),
                const SizedBox(height: 12),
                for (final v in d.visits) ...[
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: _visit(context, l10n, v)),
                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _visit(BuildContext context, AppLocalizations l10n, Json v) {
    final c = context.colors;
    final at = DateTime.parse(v['at'] as String);
    if (v['type'] == 'MISSED') return AuditHistoryItem(date: longDateTime(context, at), status: l10n.visitMissed, statusColor: c.error);
    final lat = (v['lat'] as num?)?.toDouble();
    final lng = (v['lng'] as num?)?.toDouble();
    final meters = (v['gpsAccuracyM'] as num?)?.round();
    final within = (v['withinRadius'] as bool?) ?? true;
    final comment = (v['comment'] as String?) ?? '';
    final photos = [for (final p in (v['photos'] as List? ?? const []).cast<Map>()) (p['previewUrl400'] ?? p['url']) as String];
    return AuditHistoryItem(
      date: longDateTime(context, at),
      coords: lat == null || lng == null ? null : coords(lat, lng),
      note: comment.isEmpty ? null : ViolationNote(text: comment, violationLabel: v['hasViolation'] == true ? l10n.violationRecorded : null),
      photos: photos,
      photoTotal: (v['photoCount'] as int?) ?? photos.length,
      photosLabel: l10n.photoMaterials((v['photoCount'] as int?) ?? photos.length),
      moreLabel: l10n.morePhotos,
      seeAllLabel: l10n.seeAll,
      onSeeAll: () => context.push('/admin/gallery?shopId=$shopId'),
      accuracy: meters == null ? null : within ? l10n.accuracyInside(meters) : l10n.accuracyOutside(meters),
      accuracyOk: within,
    );
  }

  Widget _pill(BuildContext context, String icon, String label, VoidCallback onTap, {bool filled = false, bool elevated = false}) {
    final c = context.colors;
    return Material(
      color: filled ? c.darkAccent : c.card,
      borderRadius: BorderRadius.circular(8),
      elevation: elevated ? 2 : 0.5,
      child: Pressable(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AppIcon(icon, width: 12, height: 12),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.label.copyWith(color: c.accent)),
          ]),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    if (await context.push<bool>('/admin/shops/$shopId/edit') == true) ref.invalidate(_shopDataProvider(shopId));
  }

  void _share(Json s) => SharePlus.instance.share(ShareParams(
        text: '${s['name']}\n${s['address']}\nhttps://maps.google.com/?q=${s['lat']},${s['lng']}',
      ));
}
