import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../shop_details/presentation/shop_details_screen.dart' show call, openInMaps;
import '../../data/admin_api.dart';
import '../../../../core/widgets/skeleton.dart';

/// Admin mobile Agents (`265:27616`): KPI tiles, search, filters (B3), agent cards.
class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({super.key});

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  List<Json>? _agents;
  Json? _summary;
  List<Json> _positions = const [];
  List<Json> _regions = const [];
  bool _error = false;
  String _q = '';
  FilterValues _filters = const {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  var _seq = 0;

  Future<void> _load() async {
    final api = ref.read(adminApiProvider);
    final seq = ++_seq; // a slower, older search must not overwrite a newer one
    try {
      final results = await Future.wait<Object>([
        api.agents(q: _q, status: (_filters['status'] ?? const {}).firstOrNull, regionId: (_filters['region'] ?? const {}).firstOrNull),
        api.agentsSummary(),
        api.positions().catchError((_) => <Json>[]),
        api.regions().catchError((_) => <Json>[]),
      ]);
      if (!mounted || seq != _seq) return;
      setState(() {
        _agents = (results[0] as PageOf).items;
        _summary = results[1] as Json;
        _positions = results[2] as List<Json>;
        _regions = results[3] as List<Json>;
        _error = false;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final s = _summary;
    final lang = Localizations.localeOf(context).languageCode;
    String n(num? v) => NumberFormat.decimalPattern(lang).format(v ?? 0);
    String pct(num? v) => v == null ? '—' : NumberFormat('0.#', lang).format(v);
    final vs = s?['auditsVsPlanPct'] as num?;

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: l10n.agentsTitle,
              count: _agents?.length,
              action: HeaderButton(
                label: l10n.add,
                onPressed: () async {
                  if (await context.push<bool>('/admin/agents/new') == true) _load();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SearchField(
                hint: l10n.search,
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 350), () {
                    _q = v;
                    _load();
                  });
                },
                filtersLabel: l10n.filters,
                activeFilters: _filters.values.where((v) => v.isNotEmpty).length,
                onFilters: () async {
                  final next = await showFilterSheet(
                    context,
                    title: l10n.filters,
                    applyLabel: l10n.apply,
                    resetLabel: l10n.reset,
                    values: _filters,
                    sections: [
                      FilterSection(
                        key: 'status',
                        label: l10n.filterStatus,
                        options: [ChipOption('ACTIVE', l10n.statusACTIVE), ChipOption('ON_LEAVE', l10n.offShift), ChipOption('INACTIVE', l10n.statusINACTIVE)],
                      ),
                      FilterSection(
                        key: 'region',
                        label: l10n.filterRegion,
                        options: [for (final r in _regions) ChipOption(r['id'] as String, r['name'] as String)],
                      ),
                    ],
                  );
                  if (next != null) {
                    _filters = next;
                    _load();
                  }
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                  children: [
                    if (s != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              label: l10n.kpiStaff,
                              value: n(s['activeStaff'] as num?),
                              unit: l10n.people,
                              icon: 'stat-team',
                              iconSize: const Size(16.5, 12),
                              footer: l10n.onShiftOf(pct(s['activePct'] as num?), (s['totalStaff'] as int?) ?? 0),
                              footerIcon: 'stat-check',
                              footerIconSize: const Size(10.83, 10.83),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatTile(
                              label: l10n.kpiOnRoute,
                              value: n(s['onRoute'] as num?),
                              unit: l10n.online,
                              icon: 'stat-route',
                              iconSize: const Size(9.75, 16.12),
                              footer: l10n.ofPool(pct(s['onRoutePct'] as num?)),
                              footerIcon: 'stat-arrow-up',
                              footerIconSize: const Size(8.67, 8.67),
                              footerColor: c.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              label: l10n.kpiAudits,
                              value: n(s['audits'] as num?),
                              unit: l10n.sheets,
                              icon: 'stat-audits',
                              iconSize: const Size(15, 13.5),
                              iconBg: c.success10,
                              footer: vs == null ? null : l10n.vsPlan('${vs > 0 ? '+' : ''}$vs'),
                              footerIcon: 'stat-trend',
                              footerIconSize: const Size(10.83, 6.5),
                              footerColor: vs != null && vs < 0 ? c.error : c.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatTile(
                              label: l10n.kpiPhotos,
                              value: n(s['photos'] as num?),
                              unit: l10n.frames,
                              icon: 'stat-camera',
                              iconSize: const Size(15, 13.5),
                              footer: s['photosVerifiedPct'] == null ? null : l10n.validPhotos(pct(s['photosVerifiedPct'] as num?)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_error)
                      LoadErrorView(
                        onRetry: () {
                          setState(() => _error = false);
                          _load();
                        },
                      ),
                    if (_agents == null && !_error) const CardListSkeleton(),
                    if (_agents != null && _agents!.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(l10n.agentsEmpty, style: TextStyle(color: c.textSecondary)),
                        ),
                      ),
                    for (final a in _agents ?? const <Json>[]) ...[_card(context, l10n, a), const SizedBox(height: 16)],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l10n, Json a) {
    final position = _positions.where((p) => p['agentId'] == a['id']).firstOrNull;
    final at = a['lastActivityAt'] as String?;
    return ShopCard(
      title: a['fullName'] as String,
      titleTrailing: Tag(a['code'] as String),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            IconLine(icon: 'pin-small', text: l10n.locations((a['locations'] as int?) ?? 0)),
            const SizedBox(width: 12),
            IconLine(icon: 'camera-small', iconSize: const Size(12, 11), text: l10n.photosShort((a['photos'] as int?) ?? 0)),
          ],
        ),
      ),
      footer: IconLine(
        icon: 'clock',
        iconSize: const Size(13.33, 13.33),
        text: at == null ? l10n.noActivity : l10n.lastActivity(_when(context, l10n, DateTime.parse(at))),
      ),
      detailsLabel: l10n.details,
      onDetails: () => context.push('/admin/agents/${a['id']}'),
      callLabel: l10n.callAgent,
      onCall: () => call(a['phone'] as String),
      navigateLabel: l10n.navigate,
      onNavigate: position == null ? null : () => openInMaps((position['lat'] as num).toDouble(), (position['lng'] as num).toDouble(), a['fullName'] as String),
    );
  }

  String _when(BuildContext context, AppLocalizations l10n, DateTime at) =>
      DateUtils.isSameDay(at.toLocal(), DateTime.now()) ? l10n.lastVisitToday(hhmm(at)) : shortDateTime(context, at);
}
