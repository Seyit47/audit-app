import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/map_view.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../shop_details/presentation/shop_details_screen.dart' show call;
import '../../data/admin_api.dart';
import '../../../../core/widgets/tap.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/adaptive.dart';

class _Data {
  const _Data(this.agent, this.timeline, this.track, this.visits, this.photos);

  final Json agent;
  final List<Json> timeline;
  final Json track;
  final Json visits;
  final Json photos;
}

final _agentDataProvider = FutureProvider.autoDispose.family<_Data, String>((ref, id) async {
  final api = ref.watch(adminApiProvider);
  final r = await Future.wait<Object>([api.agent(id), api.timeline(id), api.track(id), api.agentVisits(id), api.photos(agentId: id, limit: 5)]);
  return _Data(r[0] as Json, r[1] as List<Json>, r[2] as Json, r[3] as Json, r[4] as Json);
});

/// Admin mobile Agent details (`273:153`).
class AgentDetailsScreen extends ConsumerStatefulWidget {
  const AgentDetailsScreen({super.key, required this.agentId});

  final String agentId;

  @override
  ConsumerState<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends ConsumerState<AgentDetailsScreen> {
  bool _timelineOpen = true;
  bool _exporting = false;
  final _map = AppMapController();

  Future<void> _export(String type) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _exporting = true);
    try {
      final url = await ref.read(adminApiProvider).exportReport(widget.agentId, type);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final data = ref.watch(_agentDataProvider(widget.agentId));
    final exportButton = AppMenuButton<String>(
      enabled: !_exporting,
      tooltip: l10n.exportPdfXls,
      onSelected: _export,
      choices: [MenuChoice('AGENT_REPORT_PDF', l10n.exportPdf), MenuChoice('AGENT_REPORT_XLSX', l10n.exportXls)],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: c.darkAccent, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_exporting)
              const SizedBox(width: 12, height: 12, child: CircularProgressIndicator.adaptive(strokeWidth: 2))
            else
              const AppIcon('export-share', width: 10.67, height: 14),
            const SizedBox(width: 6),
            Text(l10n.exportPdfXls, style: AppTextStyles.label.copyWith(color: c.accent)),
          ],
        ),
      ),
    );

    final d = data.value;
    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.agentDetailsTitle, action: d == null ? null : exportButton),
            Expanded(
              child: d == null
                  ? (data.hasError
                        ? Center(child: LoadErrorView(onRetry: () => ref.invalidate(_agentDataProvider(widget.agentId))))
                        : const SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            physics: NeverScrollableScrollPhysics(),
                            child: CardListSkeleton(count: 4, lines: 3),
                          ))
                  : RefreshIndicator.adaptive(
                      onRefresh: () => ref.refresh(_agentDataProvider(widget.agentId).future),
                      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: _content(context, l10n, d)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _card(AppColors c) => BoxDecoration(
    color: c.card,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: c.cardBorder),
    boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
  );

  List<Widget> _content(BuildContext context, AppLocalizations l10n, _Data d) {
    final c = context.colors;
    final a = d.agent;
    final lang = Localizations.localeOf(context).languageCode;
    final kpis = (a['kpis'] as Map?) ?? const {};
    final position = (a['position'] as Map?)?.cast<String, dynamic>();
    final online = a['online'] == true;
    final assigned = (kpis['assignedShops'] as int?) ?? 0;
    final visited = (kpis['visitedShops'] as int?) ?? 0;
    final body = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, color: c.textSecondary);
    final title = TextStyle(fontFamily: AppTextStyles.family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: c.textPrimary);
    final photos = [for (final p in (d.photos['items'] as List? ?? const []).cast<Map>()) p.cast<String, dynamic>()];
    final totalPhotos = (kpis['photos'] as int?) ?? photos.length;
    final visits = [for (final v in (d.visits['items'] as List? ?? const []).cast<Map>()) v.cast<String, dynamic>()];
    final checkpoints = [for (final p in (d.track['checkpoints'] as List? ?? const []).cast<Map>()) p.cast<String, dynamic>()];
    final current = (d.track['current'] as Map?)?.cast<String, dynamic>();

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: _card(c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(a['fullName'] as String, overflow: TextOverflow.ellipsis, style: title.copyWith(fontSize: 18)),
                          ),
                          const SizedBox(width: 8),
                          Tag(a['code'] as String),
                        ],
                      ),
                      Text(formatPhoneLine(a['phone'] as String), style: body.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                Material(
                  color: c.darkAccent,
                  borderRadius: BorderRadius.circular(12),
                  child: Pressable(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => call(a['phone'] as String),
                    child: const SizedBox(width: 40, height: 40, child: Center(child: AppIcon('phone-square', width: 12.75, height: 12.75))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IconLine(icon: 'sector', iconSize: const Size(14.13, 14.1), text: l10n.sectorLabel, bold: (a['region'] as Map?)?['name'] as String?),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: c.secondaryBg, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: online ? c.success : c.textSecondary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      online && position != null ? l10n.onlineGps(((position['accuracyM'] as num?) ?? 0).round()) : l10n.offlineSince,
                      style: body.copyWith(fontWeight: FontWeight.w500, color: online ? c.success : c.textSecondary),
                    ),
                  ),
                  if (position != null) Text(l10n.updatedAgo(_ago(lang, DateTime.parse(position['recordedAt'] as String))), style: body.copyWith(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: StatTile(
              label: l10n.kpiAllAudits,
              value: '${(d.visits['totals'] as Map?)?['completed'] ?? kpis['audits'] ?? 0}',
              unit: l10n.checklists,
              icon: 'ad-audits',
              iconSize: const Size(12.75, 14.17),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatTile(label: l10n.kpiShopPlan, value: '$assigned', unit: l10n.outlets, icon: 'ad-shops', iconSize: const Size(14.23, 12.75)),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: StatTile(
              label: l10n.kpiVisited,
              value: '$visited',
              unit: l10n.ofOutlets(assigned, assigned == 0 ? '0' : '${(visited * 100 / assigned).round()}'),
              icon: 'ad-visited',
              iconSize: const Size(9.21, 15.23),
              iconBg: c.success10,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatTile(
              label: l10n.kpiPhotosAll,
              value: '$totalPhotos',
              unit: l10n.frames,
              icon: 'ad-photos',
              iconSize: const Size(14.17, 14.17),
              iconBg: c.secondaryBg,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const AppIcon('route-nav', width: 12, height: 14.25),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.routeTracking, style: title.copyWith(fontSize: 14))),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AppMapView(
                  controller: _map,
                  fitPadding: const EdgeInsets.all(32),
                  markers: [
                    for (final p in checkpoints)
                      MapMarker(
                        id: p['id'] as String,
                        lat: (p['lat'] as num).toDouble(),
                        lng: (p['lng'] as num).toDouble(),
                        color: switch (p['status']) {
                          'DONE' => c.success,
                          'MISSED' => c.error,
                          'IN_PROGRESS' => c.accent,
                          _ => c.textSecondary,
                        },
                      ),
                    if (current != null)
                      MapMarker(id: 'current', lat: (current['lat'] as num).toDouble(), lng: (current['lng'] as num).toDouble(), color: c.accent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.secondaryBg.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextLink(
                    onTap: () => setState(() => _timelineOpen = !_timelineOpen),
                    child: Row(
                      children: [
                        Text(l10n.checkpointHistory, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
                        const SizedBox(width: 8),
                        Tag(l10n.pointsCount(d.timeline.length)),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _timelineOpen ? 0.75 : 0.25,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: AppIcon('chevron-down', width: 14, height: 14, color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Expands and collapses smoothly instead of popping in.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: !_timelineOpen
                        ? const SizedBox(width: double.infinity)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Divider(height: 1, color: c.border),
                              for (final st in d.timeline) _checkpoint(context, l10n, st),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: _card(c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppIcon('camera-small', width: 14, height: 13, color: c.accent),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.photoReports, style: title.copyWith(fontSize: 14))),
                TextLink(
                  onTap: () => context.push('/admin/gallery?agentId=${widget.agentId}'),
                  child: Row(
                    children: [
                      Text(l10n.openGallery, style: AppTextStyles.label.copyWith(color: c.accent)),
                      const SizedBox(width: 4),
                      const AppIcon('chevron-right-accent', width: 4.93, height: 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final p in photos)
                  InkOverlay(
                    radius: 8,
                    onTap: () => context.push('/admin/gallery/${p['id']}'),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImage((p['previewUrl400'] ?? p['url']) as String?, radius: 8),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              hhmm(DateTime.parse(p['takenAt'] as String)),
                              style: const TextStyle(fontFamily: AppTextStyles.mono, fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (totalPhotos > photos.length)
                  Material(
                    color: c.darkAccent,
                    borderRadius: BorderRadius.circular(8),
                    child: Pressable(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.push('/admin/gallery?agentId=${widget.agentId}'),
                      child: Center(
                        child: Text(l10n.morePhotosOpen(totalPhotos - photos.length), style: AppTextStyles.label.copyWith(color: c.accent)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(child: Text(l10n.visitHistory, style: title)),
          Text(l10n.updatedAt(hhmm(DateTime.now())), style: body),
        ],
      ),
      const SizedBox(height: 12),
      for (final v in visits) ...[_visit(context, l10n, v), const SizedBox(height: 12)],
    ];
  }

  Widget _checkpoint(BuildContext context, AppLocalizations l10n, Json st) {
    final c = context.colors;
    final status = st['status'] as String;
    final color = switch (status) {
      'DONE' => c.success,
      'MISSED' => c.error,
      'IN_PROGRESS' => c.accent,
      _ => c.textSecondary,
    };
    final label = switch (status) {
      'DONE' => l10n.stopDONE,
      'MISSED' => l10n.stopMISSED,
      'IN_PROGRESS' => l10n.stopIN_PROGRESS,
      _ => l10n.stopPLANNED,
    };
    final audit = (st['audit'] as Map?)?.cast<String, dynamic>();
    final detail = audit != null
        ? '${hhmm(DateTime.parse(audit['startedAt'] as String))} — ${hhmm(DateTime.parse(audit['finishedAt'] as String))} • ${l10n.photoCount((st['photoCount'] as int?) ?? 0)}'
        : status == 'IN_PROGRESS'
        ? l10n.syncingData
        : l10n.plannedVisit;
    final active = status == 'IN_PROGRESS';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: active ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: active ? BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hhmm(DateTime.parse(st['plannedAt'] as String))} — ${(st['shop'] as Map)['name']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.family,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: active ? c.accent : c.textPrimary,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontFamily: AppTextStyles.family,
                    fontSize: 11,
                    height: 1.5,
                    color: status == 'MISSED'
                        ? c.error
                        : active
                        ? c.accent
                        : c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            label,
            style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _visit(BuildContext context, AppLocalizations l10n, Json v) {
    final c = context.colors;
    final missed = v['type'] == 'MISSED';
    final shop = (v['shop'] as Map).cast<String, dynamic>();
    final at = DateTime.parse(v['at'] as String);
    final when = missed ? _day(context, l10n, at) : '${_day(context, l10n, DateTime.parse(v['startedAt'] as String))} — ${hhmm(at)}';
    final photos = [for (final p in (v['photos'] as List? ?? const []).cast<Map>()) (p['previewUrl400'] ?? p['url']) as String];
    final comment = (v['comment'] as String?) ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(c),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIcon('clock', width: 13.33, height: 13.33, color: missed ? c.error : c.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: when,
                    children: [
                      if (!missed)
                        TextSpan(
                          text: ' ${l10n.durationMin((v['durationMin'] as int?) ?? 0)}',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: AppTextStyles.family,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: missed ? c.error : c.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: missed ? c.errorBg : c.success10, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  missed ? l10n.visitMissed : l10n.statusDone,
                  style: TextStyle(
                    fontFamily: AppTextStyles.family,
                    fontSize: 11,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: missed ? c.error : c.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppImage(photos.firstOrNull, width: 48, height: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 15, height: 1.4, fontWeight: FontWeight.w700, color: c.textPrimary),
                    ),
                    Text(
                      '${shop['address']} • ${shop['code']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.4, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.secondaryBg, borderRadius: BorderRadius.circular(12)),
              child: Text(
                '«$comment»',
                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 13, height: 1.5, color: c.textPrimary),
              ),
            ),
          ],
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (final (i, url) in photos.take(5).indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: AspectRatio(aspectRatio: 1, child: AppImage(url))),
                ],
                for (var i = photos.length; i < 5; i++) ...[const SizedBox(width: 8), const Expanded(child: SizedBox())],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _day(BuildContext context, AppLocalizations l10n, DateTime d) =>
      DateUtils.isSameDay(d.toLocal(), DateTime.now()) ? l10n.lastVisitToday(hhmm(d)) : shortDateTime(context, d);

  static String _ago(String lang, DateTime at) {
    final mins = DateTime.now().difference(at).inMinutes;
    if (mins < 60) return switch (lang) { 'ru' => '$mins мин. назад', 'tk' => '$mins min öň', _ => '$mins min ago' };
    return DateFormat('d MMM HH:mm', lang).format(at.toLocal());
  }
}

/// "+993 65 112233" spacing for the profile line.
String formatPhoneLine(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('993')) return '+993 ${digits.substring(3, 5)} ${digits.substring(5)}';
  return phone;
}
