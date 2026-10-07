import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../shop_details/presentation/shop_details_screen.dart' show call, openInMaps;
import '../../data/admin_api.dart';
import '../shop_labels.dart';

/// Admin mobile Shops (`246:23300`): pages of 20 loaded on scroll, search, sort, filters (B3).
class AdminShopsScreen extends ConsumerStatefulWidget {
  const AdminShopsScreen({super.key});

  @override
  ConsumerState<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends ConsumerState<AdminShopsScreen> {
  final _items = <Json>[];
  var _total = 0;
  var _page = 0;
  var _loading = false;
  var _done = false;
  var _error = false;
  var _desc = false;
  String _q = '';
  FilterValues _filters = const {};
  List<Json> _regions = const [];
  Timer? _debounce;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _load();
    });
    _reload();
    ref.read(adminApiProvider).regions().then((r) { if (mounted) setState(() => _regions = r); }, onError: (_) {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() { _items.clear(); _page = 0; _done = false; _error = false; });
    await _load();
  }

  Future<void> _load() async {
    if (_loading || _done) return;
    setState(() => _loading = true);
    try {
      final res = await ref.read(adminApiProvider).shops(
            page: _page + 1, q: _q, dir: _desc ? 'desc' : 'asc',
            status: (_filters['status'] ?? const {}).firstOrNull, regionId: (_filters['region'] ?? const {}).firstOrNull);
      if (!mounted) return;
      setState(() {
        _page++;
        _items.addAll(res.items);
        _total = res.total;
        _done = _items.length >= res.total || res.items.isEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.textSecondary);
    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(
            title: l10n.shopsTitle,
            count: _total,
            action: HeaderButton(label: l10n.add, onPressed: () async {
              if (await context.push<bool>('/admin/shops/new') == true) _reload();
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SearchField(
              hint: l10n.search,
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), () { _q = v; _reload(); });
              },
              filtersLabel: l10n.filters,
              activeFilters: _filters.values.where((v) => v.isNotEmpty).length,
              onFilters: () async {
                final next = await showFilterSheet(context, title: l10n.filters, applyLabel: l10n.apply, resetLabel: l10n.reset, values: _filters, sections: [
                  FilterSection(key: 'status', label: l10n.filterStatus, options: [
                    for (final s in const ['ACTIVE', 'PENDING_REVIEW', 'INACTIVE']) ChipOption(s, shopStatusLabel(l10n, s)),
                  ]),
                  FilterSection(key: 'region', label: l10n.filterRegion, options: [for (final r in _regions) ChipOption(r['id'] as String, r['name'] as String)]),
                ]);
                if (next != null) { _filters = next; _reload(); }
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _reload,
              child: ListView(controller: _scroll, padding: const EdgeInsets.fromLTRB(16, 0, 16, 48), children: [
                Row(children: [
                  Text(l10n.totalShops(_total), style: small),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { _desc = !_desc; _reload(); },
                    child: Row(children: [
                      Text(_desc ? l10n.sortZA : l10n.sortAZ, style: small.copyWith(fontWeight: FontWeight.w600, color: c.accent)),
                      const SizedBox(width: 4),
                      RotatedBox(quarterTurns: _desc ? 3 : 1, child: const AppIcon('chevron-down', width: 14, height: 14)),
                    ]),
                  ),
                ]),
                const SizedBox(height: 16),
                for (final s in _items) ...[_card(context, l10n, s), const SizedBox(height: 16)],
                if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
                if (_error) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.loadError, style: small))),
                if (!_loading && !_error && _items.isEmpty) Padding(padding: const EdgeInsets.all(48), child: Center(child: Text(l10n.shopsEmpty, style: small))),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l10n, Json s) {
    final c = context.colors;
    final status = s['status'] as String?;
    final last = (s['lastVisit'] as Map?)?['at'] as String?;
    final agent = (s['agent'] as Map?)?['fullName'] as String?;
    final phone = ((s['contacts'] as List?) ?? const []).cast<Map>().firstOrNull?['phone'] as String?;
    final right = status != 'ACTIVE' || last == null
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: status == 'ACTIVE' ? c.success : status == 'PENDING_REVIEW' ? c.accent : c.textSecondary)),
            const SizedBox(width: 4),
            Text(shopStatusLabel(l10n, status), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500,
                color: status == 'ACTIVE' ? c.success : status == 'PENDING_REVIEW' ? c.accent : c.textSecondary)),
          ])
        : Text(_lastVisit(context, l10n, DateTime.parse(last)), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.textSecondary));
    return ShopCard(
      header: Row(children: [
        Tag(shopTypeLabel(l10n, s['type'] as String?), strong: true),
        const SizedBox(width: 6),
        Tag(s['code'] as String),
        const Spacer(),
        right,
      ]),
      title: s['name'] as String,
      subtitle: IconLine(icon: 'pin-small', text: s['address'] as String),
      footer: Row(children: [
        Expanded(child: IconLine(icon: 'person-small', iconSize: const Size(10, 10), text: l10n.agentLabel, bold: agent ?? l10n.unassigned)),
        IconLine(icon: 'history', iconSize: const Size(11.25, 11.25), text: l10n.auditsTotal((s['auditCount'] as int?) ?? 0)),
      ]),
      detailsLabel: l10n.details,
      onDetails: () async {
        if (await context.push<bool>('/admin/shops/${s['id']}') == true) _reload();
      },
      callLabel: l10n.callShop,
      onCall: phone == null ? null : () => call(phone),
      navigateLabel: l10n.navigate,
      onNavigate: () => openInMaps((s['lat'] as num).toDouble(), (s['lng'] as num).toDouble(), s['name'] as String),
    );
  }

  String _lastVisit(BuildContext context, AppLocalizations l10n, DateTime at) =>
      DateUtils.isSameDay(at.toLocal(), DateTime.now()) ? l10n.lastVisitToday(hhmm(at)) : l10n.lastVisitShort(dayMonth(context, at));
}
