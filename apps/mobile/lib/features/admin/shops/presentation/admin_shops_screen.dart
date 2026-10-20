import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/format/formatters.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/adaptive.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/district_tile.dart';
import '../../../../core/widgets/form_field.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../shop_details/presentation/shop_details_screen.dart' show call;
import '../../data/admin_api.dart';
import '../shop_labels.dart';
import '../../../../core/widgets/tap.dart';
import '../../../../core/widgets/skeleton.dart';

/// Admin mobile Shops (`246:23300`): opens on the districts (added, renamed and deleted here); a district,
/// or a search, lists its shops in pages of 20 loaded on scroll, with sort and filters (B3).
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
  List<Json>? _districts;
  var _districtsError = false;

  /// The chosen district: its id (null: the shops without one) and name; null shows the districts.
  ({String? id, String name})? _district;
  Timer? _debounce;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _load();
    });
    _loadDistricts();
  }

  bool get _showDistricts => _district == null && _q.trim().isEmpty;

  Future<void> _loadDistricts() async {
    setState(() => _districtsError = false);
    try {
      final d = await ref.read(adminApiProvider).districts();
      if (mounted) setState(() => _districts = d);
    } catch (_) {
      if (mounted) setState(() => _districtsError = true);
    }
  }

  void _open(({String? id, String name})? district) {
    setState(() => _district = district);
    if (district == null) {
      _loadDistricts();
    } else {
      _reload();
    }
  }

  /// Add (no [current]) or rename a district; returns once saved or dismissed.
  Future<void> _editDistrict({Json? current}) async {
    final l10n = AppLocalizations.of(context);
    final name = TextEditingController(text: current?['name'] as String?);
    final entered = await showAppDialog<String>(
      context: context,
      title: Text(current == null ? l10n.addDistrict : l10n.renameDistrict),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AppTextInput(controller: name, autofocus: true, hint: l10n.districtName, onSubmitted: (v) => Navigator.pop(context, v)),
      ),
      actions: (dialog) => [
        AppDialogAction(label: l10n.cancel, onPressed: () => Navigator.pop(dialog)),
        AppDialogAction(label: l10n.save, primary: true, onPressed: () => Navigator.pop(dialog, name.text)),
      ],
    );
    name.dispose();
    if (entered == null || entered.trim().isEmpty || !mounted) return;
    final api = ref.read(adminApiProvider);
    await _districtAction(() => current == null ? api.addDistrict(entered.trim()) : api.renameDistrict(current['id'] as String, entered.trim()));
  }

  /// Long press on a district card: rename, or delete an empty one.
  Future<void> _districtMenu(Json d) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(d['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            ListTile(leading: const Icon(Icons.edit_outlined), title: Text(l10n.renameDistrict), onTap: () => Navigator.pop(sheet, 'rename')),
            if (d['shops'] == 0)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(sheet).colorScheme.error),
                title: Text(l10n.deleteDistrict, style: TextStyle(color: Theme.of(sheet).colorScheme.error)),
                onTap: () => Navigator.pop(sheet, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (choice == 'rename') return _editDistrict(current: d);
    if (choice == 'delete') return _districtAction(() => ref.read(adminApiProvider).deleteDistrict(d['id'] as String));
  }

  Future<void> _districtAction(Future<Object?> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.code == 'CONFLICT' ? l10n.districtInUse : l10n.saveFailed)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
    await _loadDistricts();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  var _seq = 0;

  Future<void> _reload() async {
    _seq++; // abandons any page still loading for the previous query
    setState(() {
      _items.clear();
      _page = 0;
      _done = false;
      _error = false;
      _loading = false;
    });
    await _load();
  }

  Future<void> _load() async {
    if (_loading || _done) return;
    final seq = _seq;
    setState(() => _loading = true);
    try {
      final res = await ref
          .read(adminApiProvider)
          .shops(
            page: _page + 1,
            q: _q,
            dir: _desc ? 'desc' : 'asc',
            status: (_filters['status'] ?? const {}).firstOrNull,
            districtId: _district == null ? null : _district!.id ?? 'none',
          );
      if (!mounted || seq != _seq) return;
      setState(() {
        _page++;
        _items.addAll(res.items);
        _total = res.total;
        _done = _items.length >= res.total || res.items.isEmpty;
      });
    } catch (_) {
      if (mounted && seq == _seq) setState(() => _error = true);
    } finally {
      if (mounted && seq == _seq) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: c.textSecondary);
    final district = _district;
    final districts = _districts ?? const <Json>[];
    return PopScope(
      canPop: district == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _open(null);
      },
      child: Scaffold(
        backgroundColor: c.mainBg,
        body: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: district?.name ?? l10n.shopsTitle,
                count: _showDistricts ? districts.fold<int>(0, (n, d) => n + ((d['shops'] as int?) ?? 0)) : _total,
                onBack: district == null ? null : () => _open(null),
                // On the districts: a new district; in a district: a new shop there.
                action: HeaderButton(
                  // On the districts: a new district; in a district: a new shop there.
                  label: _showDistricts ? l10n.district : l10n.add,
                  onPressed: () async {
                    if (_showDistricts) return _editDistrict();
                    final path = district?.id == null ? '/admin/shops/new' : '/admin/shops/new?districtId=${district!.id}';
                    if (await context.push<bool>(path) == true) _reload();
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
                      setState(() => _q = v);
                      if (!_showDistricts) _reload();
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
                          options: [
                            for (final s in const ['ACTIVE', 'PENDING_REVIEW', 'INACTIVE']) ChipOption(s, shopStatusLabel(l10n, s)),
                          ],
                        ),
                      ],
                    );
                    if (next != null) {
                      _filters = next;
                      if (!_showDistricts) _reload();
                    }
                  },
                ),
              ),
              Expanded(
                child: _showDistricts
                    ? RefreshIndicator.adaptive(
                        onRefresh: _loadDistricts,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                          children: [
                            if (_districts == null && !_districtsError) const CardListSkeleton(lines: 1),
                            if (_districtsError) LoadErrorView(onRetry: _loadDistricts),
                            if (_districts != null && districts.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(48),
                                child: Center(child: Text(l10n.districtsEmpty, style: small)),
                              ),
                            for (final d in districts) ...[
                              DistrictTile(
                                name: (d['name'] as String?) ?? l10n.noDistrict,
                                shops: (d['shops'] as int?) ?? 0,
                                visitedToday: (d['visitedToday'] as int?) ?? 0,
                                overdue: (d['overdue'] as int?) ?? 0,
                                muted: d['id'] == null,
                                onTap: () => _open((id: d['id'] as String?, name: (d['name'] as String?) ?? l10n.noDistrict)),
                                // Long press: the same rename / delete as the menu.
                                onLongPress: d['id'] == null ? null : () => _districtMenu(d),
                                trailing: d['id'] == null
                                    ? null
                                    : AppMenuButton<String>(
                                        tooltip: d['name'] as String,
                                        cancelLabel: l10n.cancel,
                                        choices: [
                                          MenuChoice('rename', l10n.renameDistrict),
                                          // The server refuses while the district has shops; the button says so up front.
                                          if (d['shops'] == 0) MenuChoice('delete', l10n.deleteDistrict, destructive: true),
                                        ],
                                        onSelected: (v) => v == 'rename'
                                            ? _editDistrict(current: d)
                                            : _districtAction(() => ref.read(adminApiProvider).deleteDistrict(d['id'] as String)),
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: Center(child: AppIcon('kebab', width: 4, height: 16, color: c.textSecondary)),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: _reload,
                        child: ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                          children: [
                            Row(
                              children: [
                                Text(l10n.totalShops(_total), style: small),
                                const Spacer(),
                                TextLink(
                                  onTap: () {
                                    _desc = !_desc;
                                    _reload();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        _desc ? l10n.sortZA : l10n.sortAZ,
                                        style: small.copyWith(fontWeight: FontWeight.w600, color: c.accent),
                                      ),
                                      const SizedBox(width: 4),
                                      AnimatedRotation(
                                        turns: _desc ? 0.75 : 0.25,
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeOutCubic,
                                        child: const AppIcon('chevron-down', width: 14, height: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            for (final s in _items) ...[_card(context, l10n, s), const SizedBox(height: 16)],
                            // First page: card placeholders; further pages: the usual spinner under the list.
                            if (_loading && _items.isEmpty) const CardListSkeleton(lines: 3),
                            if (_loading && _items.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator.adaptive()),
                              ),
                            if (_error) LoadErrorView(onRetry: _reload),
                            if (!_loading && !_error && _items.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(48),
                                child: Center(child: Text(l10n.shopsEmpty, style: small)),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, AppLocalizations l10n, Json s) {
    final c = context.colors;
    final status = s['status'] as String?;
    final last = (s['lastVisit'] as Map?)?['at'] as String?;
    final agents = [for (final a in ((s['agents'] as List?) ?? const []).cast<Map>()) a['fullName'] as String];
    final agent = agents.isEmpty ? ((s['agent'] as Map?)?['fullName'] as String?) : agents.join(', ');
    final phone = ((s['contacts'] as List?) ?? const []).cast<Map>().firstOrNull?['phone'] as String?;
    final right = status != 'ACTIVE' || last == null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 'ACTIVE'
                      ? c.success
                      : status == 'PENDING_REVIEW'
                      ? c.accent
                      : c.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                shopStatusLabel(l10n, status),
                style: TextStyle(
                  fontFamily: AppTextStyles.family,
                  fontSize: 11,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: status == 'ACTIVE'
                      ? c.success
                      : status == 'PENDING_REVIEW'
                      ? c.accent
                      : c.textSecondary,
                ),
              ),
            ],
          )
        : Text(
            _lastVisit(context, l10n, DateTime.parse(last)),
            style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.textSecondary),
          );
    return ShopCard(
      header: Row(
        children: [Tag(shopTypeLabel(l10n, s['type'] as String?), strong: true), const SizedBox(width: 6), Tag(s['code'] as String), const Spacer(), right],
      ),
      title: s['name'] as String,
      image: ((s['facade'] as Map?)?['previewUrl400'] ?? (s['facade'] as Map?)?['url']) as String?,
      subtitle: IconLine(icon: 'pin-small', text: s['address'] as String),
      footer: Row(
        children: [
          Expanded(
            child: IconLine(icon: 'person-small', iconSize: const Size(10, 10), text: l10n.agentLabel, bold: agent ?? l10n.unassigned),
          ),
          IconLine(icon: 'history', iconSize: const Size(11.25, 11.25), text: l10n.auditsTotal((s['auditCount'] as int?) ?? 0)),
        ],
      ),
      detailsLabel: l10n.details,
      onDetails: () async {
        if (await context.push<bool>('/admin/shops/${s['id']}') == true) _reload();
      },
      callLabel: l10n.callShop,
      onCall: phone == null ? null : () => call(phone),
      navigateLabel: l10n.navigate,
      // Our map, on this shop (not Yandex / Google).
      onNavigate: () => context.push('/admin/map?shop=${s['id']}'),
    );
  }

  String _lastVisit(BuildContext context, AppLocalizations l10n, DateTime at) =>
      DateUtils.isSameDay(at.toLocal(), DateTime.now()) ? l10n.lastVisitToday(hhmm(at)) : l10n.lastVisitShort(dayMonth(context, at));
}
