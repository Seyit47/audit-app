import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/location/position_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/bottom_sheet_card.dart';
import '../../../core/widgets/filter_chips.dart';
import '../../../core/widgets/filter_sheet.dart';
import '../../../core/widgets/map_view.dart';
import '../../../core/widgets/search_field.dart';
import '../../shops/data/shops_local_repository.dart';
import '../../shops/domain/visit_state.dart';
import '../../../core/widgets/tap.dart';

enum _MapFilter { all, notVisited, visited, recent }

/// Agent Map (`83:17636`, `83:17775` / `106:5485`, `106:5609`): the day's shops from the local
/// mirror, pins by state, and the shop sheet with the geofence check before "Начать Аудит".
class AgentMapScreen extends ConsumerStatefulWidget {
  const AgentMapScreen({super.key});

  @override
  ConsumerState<AgentMapScreen> createState() => _AgentMapScreenState();
}

class _AgentMapScreenState extends ConsumerState<AgentMapScreen> {
  final _map = AppMapController();
  _MapFilter _filter = _MapFilter.all;
  String _q = '';
  FilterValues _filters = const {};
  String? _selected;
  List<MapMarker> _markers = const [];
  List<Object?> _markersKey = const [];

  static bool _recent(ShopItem s) =>
      s.shop.lastVisitAt != null && DateTime.now().difference(s.shop.lastVisitAt!).inDays < 7 && s.visit.state != VisitState.visited;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final all = ref.watch(shopsProvider).value ?? const <ShopItem>[];
    final position = ref.watch(positionProvider).value;
    final regions = _filters['region'] ?? const <String>{};
    final needle = _q.trim().toLowerCase();
    final base = all.where((s) =>
        (regions.isEmpty || regions.contains(s.shop.regionName)) &&
        (needle.isEmpty || '${s.shop.name} ${s.shop.ownerName ?? ''} ${s.shop.address}'.toLowerCase().contains(needle))).toList();
    final shown = switch (_filter) {
      _MapFilter.all => base,
      _MapFilter.notVisited => base.where((s) => s.visit.state != VisitState.visited).toList(),
      _MapFilter.visited => base.where((s) => s.visit.state == VisitState.visited).toList(),
      _MapFilter.recent => base.where(_recent).toList(),
    };
    final selected = all.where((s) => s.shop.id == _selected).firstOrNull;

    // Rebuild the pin list only when what it shows changes, so the map keeps its symbols.
    final key = [for (final s in shown) '${s.shop.id}:${s.visit.state}:${s.shop.facadeUrl}', _selected, c.accent];
    if (!_listEquals(key, _markersKey)) {
      _markersKey = key;
      _markers = [
        for (final s in shown)
          MapMarker(
            id: s.shop.id, lat: s.shop.lat, lng: s.shop.lng, imageUrl: s.shop.facadeUrl,
            color: s.shop.id == _selected ? c.accent : switch (s.visit.state) {
              VisitState.visited => c.lightGreen,
              VisitState.overdue || VisitState.scheduled => c.error,
              VisitState.notVisited => c.textSecondary,
            },
          ),
      ];
    }
    final regionNames = {for (final s in all) ?s.shop.regionName}.toList()..sort();

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: AppMapView(
            markers: _markers,
            controller: _map,
            onMarkerTap: (id) => setState(() => _selected = id),
            onMapTap: () => setState(() => _selected = null),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(children: [
              Row(children: [
                MapRoundButton(onTap: () => context.pop(), size: 44, radius: 8, child: AppIcon('back', width: 11.77, height: 20, color: c.textPrimary)),
                const SizedBox(width: 8),
                Expanded(
                  child: SearchField(
                    hint: l10n.mapSearch,
                    onChanged: (v) => setState(() => _q = v),
                    filtersLabel: l10n.filters,
                    activeFilters: regions.length,
                    onFilters: () async {
                      final next = await showFilterSheet(context,
                          title: l10n.filters, applyLabel: l10n.apply, resetLabel: l10n.reset, values: _filters,
                          sections: [FilterSection(key: 'region', label: l10n.filterRegion, multi: true, options: [for (final r in regionNames) ChipOption(r, r)])]);
                      if (next != null) setState(() => _filters = next);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(children: [
                  MapChip(label: l10n.mapAll, selected: _filter == _MapFilter.all, onTap: () => setState(() => _filter = _MapFilter.all)),
                  MapChip(label: l10n.mapNotVisited(base.where((s) => s.visit.state != VisitState.visited).length), dot: c.error, selected: _filter == _MapFilter.notVisited, onTap: () => setState(() => _filter = _MapFilter.notVisited)),
                  MapChip(label: l10n.mapVisited(base.where((s) => s.visit.state == VisitState.visited).length), dot: c.lightGreen, selected: _filter == _MapFilter.visited, onTap: () => setState(() => _filter = _MapFilter.visited)),
                  MapChip(label: l10n.mapRecent, dot: c.textSecondary, selected: _filter == _MapFilter.recent, onTap: () => setState(() => _filter = _MapFilter.recent)),
                ]),
              ),
            ]),
          ),
        ),
        Positioned(
          right: 16,
          bottom: selected == null ? 120 : 300,
          child: Column(children: [
            MapRoundButton(
              tooltip: l10n.myLocation, size: 40, radius: 999,
              onTap: () { if (position != null) _map.moveTo(position.latitude, position.longitude); },
              child: AppIcon('map-locate', width: 20, height: 20, color: c.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.cardBorder), boxShadow: mapControlShadow),
              child: Column(children: [
                MapZoomButton(tooltip: l10n.zoomIn, icon: 'map-zoom-in', onTap: _map.zoomIn, divider: true),
                MapZoomButton(tooltip: l10n.zoomOut, icon: 'map-zoom-out', onTap: _map.zoomOut),
              ]),
            ),
          ]),
        ),
        if (selected != null)
          Positioned(left: 0, right: 0, bottom: 0, child: ShopSheet(item: selected, meters: distanceTo(position, selected.shop.lat, selected.shop.lng))),
      ]),
    );
  }

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

const mapControlShadow = [
  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
];

/// The shop sheet of `83:17775` (83:17917).
class ShopSheet extends StatelessWidget {
  const ShopSheet({super.key, required this.item, required this.meters, this.action, this.extra});

  final ShopItem item;
  final double? meters;
  /// Replaces "Начать Аудит" (the admin map shows "Подробнее").
  final Widget? action;
  /// Admin map (`248:24102`): type/code tags and the agent line under the header.
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final s = item.shop;
    final inside = meters != null && meters! <= s.auditRadiusM;
    final text = TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 1.5, color: c.textPrimary);
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, color: c.accent);
    return BottomSheetCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            AppImage(s.facadeUrl, width: 70, height: 70, radius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(s.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(children: [
                  AppIcon('geo-target', width: 13.69, height: 13.69, color: c.success),
                  const SizedBox(width: 4),
                  Text(coords(s.lat, s.lng), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w500, color: c.success)),
                  if (meters != null) ...[
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(fontSize: 12, color: Color(0xFFC7C4D8))),
                    const SizedBox(width: 8),
                    Flexible(child: Text(l10n.fromYou(distance(context, meters!)), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, color: c.textSecondary))),
                  ],
                ]),
              ]),
            ),
          ]),
        ),
        if (extra != null) ...[extra!, const SizedBox(height: 10)],
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: c.infoBg, border: Border.all(color: c.infoBorder), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Text(l10n.lastVisit, style: small),
            const Spacer(),
            Text(s.lastVisitAt == null ? l10n.never : shortDateTime(context, s.lastVisitAt!), style: small),
          ]),
        ),
        const SizedBox(height: 10),
        if (action != null)
          action!
        else ...[
          if (!inside) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: c.alertBg, border: Border.all(color: c.alertBorder), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                AppIcon('alert-triangle', width: 12.75, height: 11.98, color: c.error),
                const SizedBox(width: 6),
                Expanded(child: Text(meters == null ? l10n.locating : l10n.auditOnlyOnSite, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.error))),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          Opacity(
            opacity: inside ? 1 : 0.5,
            child: Material(
              color: c.accent,
              borderRadius: BorderRadius.circular(12),
              child: Pressable(
                borderRadius: BorderRadius.circular(12),
                onTap: inside ? () => context.push('/agent/audit/${s.id}') : null,
                child: SizedBox(
                  height: 40,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const AppIcon('play-small', width: 9.17, height: 11.67),
                    const SizedBox(width: 8),
                    Text(l10n.startAudit, style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

/// The filter pills of the map top bar (`83:17754`): white, 28 px, a colored dot.
class MapChip extends StatelessWidget {
  const MapChip({super.key, required this.label, required this.selected, required this.onTap, this.dot});

  final String label;
  final bool selected;
  final Color? dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AnimatedChip(
        onTap: onTap,
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: selected && dot == null ? 12 : 14),
        decoration: BoxDecoration(
          color: selected ? c.accent : c.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? Colors.transparent : c.cardBorder),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot != null) ...[Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)), const SizedBox(width: 6)],
          Text(label, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : c.textSecondary)),
        ]),
      ),
    );
  }
}

class MapRoundButton extends StatelessWidget {
  const MapRoundButton({super.key, required this.child, required this.onTap, required this.size, required this.radius, this.tooltip});

  final Widget child;
  final VoidCallback onTap;
  final double size;
  final double radius;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(radius), border: Border.all(color: c.cardBorder), boxShadow: mapControlShadow),
      child: Material(type: MaterialType.transparency, child: Pressable(borderRadius: BorderRadius.circular(radius), onTap: onTap, child: Center(child: child))),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class MapZoomButton extends StatelessWidget {
  const MapZoomButton({super.key, required this.tooltip, required this.icon, required this.onTap, this.divider = false});

  final String tooltip;
  final String icon;
  final Future<void> Function() onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(border: divider ? Border(bottom: BorderSide(color: c.grey3)) : null),
          child: AppIcon(icon, width: 20, height: 20, color: c.textSecondary),
        ),
      ),
    );
  }
}
