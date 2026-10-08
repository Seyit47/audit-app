import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/location/position_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/map_view.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../../map/presentation/agent_map_screen.dart';
import '../../../shops/data/shops_local_repository.dart';
import '../../../shops/domain/visit_state.dart';
import '../../data/admin_api.dart';
import '../../shops/shop_labels.dart';
import '../../../../core/widgets/tap.dart';

enum _Filter { all, notVisited, visited, recent }

/// Admin mobile Map (`248:23963`, `248:24102`): all shops and agent positions from the API,
/// chips, filters (B3) and the shop sheet with "Подробнее".
class AdminMapScreen extends ConsumerStatefulWidget {
  const AdminMapScreen({super.key, this.focusShopId, this.focusAgentId});

  /// Opened from a shop: that shop is selected (its card open) and the map centred on it.
  final String? focusShopId;

  /// Opened from a salesman: the map is centred on their last position.
  final String? focusAgentId;

  @override
  ConsumerState<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends ConsumerState<AdminMapScreen> {
  final _map = AppMapController();
  List<Json> _shops = const [];
  List<Json> _positions = const [];
  List<Json> _regions = const [];
  List<Json> _agents = const [];
  _Filter _filter = _Filter.all;
  String _q = '';
  FilterValues _filters = const {};
  String? _selected;
  Json? _details;
  List<MapMarker> _markers = const [];
  String _markersKey = '';

  @override
  void initState() {
    super.initState();
    _load().then((_) => _focusTarget());
    if (widget.focusShopId != null) _select(widget.focusShopId!);
  }

  void _focusTarget() {
    if (!mounted) return;
    (double, double)? at(Json? j) => j == null ? null : ((j['lat'] as num).toDouble(), (j['lng'] as num).toDouble());
    final point = widget.focusShopId != null
        ? at(_shops.where((s) => s['id'] == widget.focusShopId).firstOrNull)
        : widget.focusAgentId != null
        ? at(_positions.where((p) => p['agentId'] == widget.focusAgentId).firstOrNull)
        : null;
    if (point != null) _map.focus(point.$1, point.$2);
  }

  Future<void> _load() async {
    final api = ref.read(adminApiProvider);
    try {
      final r = await Future.wait<Object>([
        api.mapShops(agentIds: (_filters['agent'] ?? const <String>{}).toList(), regionIds: (_filters['region'] ?? const <String>{}).toList()),
        api.positions().catchError((_) => <Json>[]),
        api.regions().catchError((_) => <Json>[]),
        api.agents().then((p) => p.items).catchError((_) => <Json>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _shops = r[0] as List<Json>;
        _positions = r[1] as List<Json>;
        _regions = r[2] as List<Json>;
        _agents = r[3] as List<Json>;
      });
    } catch (_) {}
  }

  Future<void> _select(String id) async {
    if (id.startsWith('agent:')) return;
    setState(() {
      _selected = id;
      _details = null;
    });
    try {
      final d = await ref.read(adminApiProvider).shop(id);
      if (mounted && _selected == id) setState(() => _details = d);
    } catch (_) {}
  }

  static bool _visited(Json s) => s['visitState'] == 'VISITED';
  static bool _recent(Json s) {
    final at = s['lastVisitAt'] as String?;
    return at != null && !_visited(s) && DateTime.now().difference(DateTime.parse(at)).inDays < 7;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final needle = _q.trim().toLowerCase();
    final base = _shops.where((s) => needle.isEmpty || '${s['name']} ${s['code']} ${s['address']}'.toLowerCase().contains(needle)).toList();
    final shown = switch (_filter) {
      _Filter.all => base,
      _Filter.notVisited => base.where((s) => !_visited(s)).toList(),
      _Filter.visited => base.where(_visited).toList(),
      _Filter.recent => base.where(_recent).toList(),
    };

    final key = '${shown.map((s) => '${s['id']}${s['visitState']}').join()}|$_selected|${_positions.length}|${c.accent}';
    if (key != _markersKey) {
      _markersKey = key;
      _markers = [
        for (final s in shown)
          MapMarker(
            id: s['id'] as String,
            lat: (s['lat'] as num).toDouble(),
            lng: (s['lng'] as num).toDouble(),
            imageUrl: s['thumbUrl'] as String?,
            color: s['id'] == _selected
                ? c.accent
                : _visited(s)
                ? c.lightGreen
                : s['visitState'] == 'ASSIGNED'
                ? c.textSecondary
                : c.error,
          ),
        for (final p in _positions)
          MapMarker(id: 'agent:${p['agentId']}', lat: (p['lat'] as num).toDouble(), lng: (p['lng'] as num).toDouble(), color: c.accent),
      ];
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapView(
              markers: _markers,
              controller: _map,
              onMarkerTap: _select,
              onMapTap: () => setState(() {
                _selected = null;
                _details = null;
              }),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      MapRoundButton(
                        onTap: () => context.pop(),
                        size: 44,
                        radius: 8,
                        child: AppIcon('back', width: 11.77, height: 20, color: c.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SearchField(
                          hint: l10n.mapSearch,
                          onChanged: (v) => setState(() => _q = v),
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
                                  key: 'agent',
                                  label: l10n.agent,
                                  multi: true,
                                  options: [for (final a in _agents) ChipOption(a['id'] as String, a['fullName'] as String)],
                                ),
                                FilterSection(
                                  key: 'region',
                                  label: l10n.filterRegion,
                                  multi: true,
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        MapChip(label: l10n.mapAll, selected: _filter == _Filter.all, onTap: () => setState(() => _filter = _Filter.all)),
                        MapChip(
                          label: l10n.mapNotVisited(base.where((s) => !_visited(s)).length),
                          dot: c.error,
                          selected: _filter == _Filter.notVisited,
                          onTap: () => setState(() => _filter = _Filter.notVisited),
                        ),
                        MapChip(
                          label: l10n.mapVisited(base.where(_visited).length),
                          dot: c.lightGreen,
                          selected: _filter == _Filter.visited,
                          onTap: () => setState(() => _filter = _Filter.visited),
                        ),
                        MapChip(
                          label: l10n.mapRecent,
                          dot: c.textSecondary,
                          selected: _filter == _Filter.recent,
                          onTap: () => setState(() => _filter = _Filter.recent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: _selected == null ? 120 : 330,
            child: Column(
              children: [
                MapRoundButton(
                  tooltip: l10n.myLocation,
                  size: 40,
                  radius: 999,
                  onTap: () {
                    final p = ref.read(positionProvider).value;
                    if (p != null) {
                      _map.moveTo(p.latitude, p.longitude);
                    } else {
                      _map.fit([for (final m in _markers) (m.lat, m.lng)]);
                    }
                  },
                  child: AppIcon('map-locate', width: 20, height: 20, color: c.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.cardBorder),
                    boxShadow: mapControlShadow,
                  ),
                  child: Column(
                    children: [
                      MapZoomButton(tooltip: l10n.zoomIn, icon: 'map-zoom-in', onTap: _map.zoomIn, divider: true),
                      MapZoomButton(tooltip: l10n.zoomOut, icon: 'map-zoom-out', onTap: _map.zoomOut),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_selected != null && _details != null) Positioned(left: 0, right: 0, bottom: 0, child: _sheet(context, l10n, _details!)),
        ],
      ),
    );
  }

  Widget _sheet(BuildContext context, AppLocalizations l10n, Json d) {
    final c = context.colors;
    final lastVisit = d['lastVisitAt'] as String?;
    final shop = Shop(
      id: d['id'] as String,
      code: d['code'] as String,
      name: d['name'] as String,
      type: d['type'] as String,
      address: d['address'] as String,
      lat: (d['lat'] as num).toDouble(),
      lng: (d['lng'] as num).toDouble(),
      auditRadiusM: (d['auditRadiusM'] as int?) ?? 100,
      status: d['status'] as String,
      latestVisitsJson: '[]',
      updatedAt: DateTime.now(),
      facadeUrl: ((d['facade'] as Map?)?['previewUrl400'] ?? (d['facade'] as Map?)?['url']) as String?,
      lastVisitAt: lastVisit == null ? null : DateTime.parse(lastVisit),
    );
    final agent = (d['agent'] as Map?)?['fullName'] as String?;
    final audits = ((d['kpis'] as Map?)?['totalAudits'] as int?) ?? 0;
    return ShopSheet(
      item: ShopItem(shop: shop, contacts: const [], visit: const VisitInfo(VisitState.notVisited)),
      meters: distanceTo(ref.watch(positionProvider).value, shop.lat, shop.lng),
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Tag(shopTypeLabel(l10n, shop.type), strong: true), const SizedBox(width: 6), Tag(shop.code)]),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: IconLine(icon: 'person-small', iconSize: const Size(10, 10), text: l10n.agentLabel, bold: agent ?? l10n.unassigned),
              ),
              IconLine(icon: 'history', iconSize: const Size(11.25, 11.25), text: l10n.auditsTotal(audits)),
            ],
          ),
        ],
      ),
      action: Material(
        color: c.accent,
        borderRadius: BorderRadius.circular(12),
        child: Pressable(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/admin/shops/${shop.id}'),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.details,
                  style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const AppIcon('arrow-right-white', width: 10, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
