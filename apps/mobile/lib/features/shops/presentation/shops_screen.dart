import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/location/position_provider.dart';

import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/district_tile.dart';
import '../../../core/widgets/filter_chips.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/shop_list_tile.dart';
import '../data/shops_local_repository.dart';
import '../domain/visit_state.dart';

/// Agent Shops (`83:16884` / `101:1985`) from the local mirror; pull-to-refresh runs a sync. It opens on the
/// districts of the agent's shops; choosing one (or searching) lists the shops.
class ShopsScreen extends ConsumerStatefulWidget {
  const ShopsScreen({super.key});

  @override
  ConsumerState<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends ConsumerState<ShopsScreen> {
  VisitState? _state;
  String _q = '';

  /// The chosen district: its id (null: the shops without one) and name; null shows the districts.
  ({String? id, String name})? _district;

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(positionProvider).value;
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final all = ref.watch(shopsProvider).value ?? const <ShopItem>[];
    final needle = _q.trim().toLowerCase();
    final district = _district;
    final showDistricts = district == null && needle.isEmpty;
    final base = all
        .where(
          (s) =>
              (district == null || s.shop.districtId == district.id) &&
              (needle.isEmpty || '${s.shop.name} ${s.shop.code} ${s.shop.address}'.toLowerCase().contains(needle)),
        )
        .toList();
    int count(VisitState s) => base.where((i) => i.visit.state == s).length;
    final shown = _state == null ? base : base.where((i) => i.visit.state == _state).toList();
    // Each district's shops, and today's visited and overdue ones (as the status chips count them).
    final districts = <String?, ({String name, int shops, int visited, int overdue})>{};
    for (final s in all) {
      final d = districts[s.shop.districtId];
      districts[s.shop.districtId] = (
        name: s.shop.districtName ?? l10n.noDistrict,
        shops: (d?.shops ?? 0) + 1,
        visited: (d?.visited ?? 0) + (s.visit.state == VisitState.visited ? 1 : 0),
        overdue: (d?.overdue ?? 0) + (s.visit.state == VisitState.overdue ? 1 : 0),
      );
    }
    // Named districts by name, then the shops without one.
    final districtList = districts.entries.toList()
      ..sort(
        (a, b) => a.key == null
            ? 1
            : b.key == null
            ? -1
            : a.value.name.compareTo(b.value.name),
      );

    return PopScope(
      canPop: district == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _district = null);
      },
      child: Scaffold(
        backgroundColor: c.mainBg,
        body: SafeArea(
          child: Column(
            children: [
              AppTopBar(
                title: district?.name ?? l10n.shopsTitle,
                count: district == null ? all.length : base.length,
                onBack: district == null ? null : () => setState(() => _district = null),
                action: HeaderButton(label: l10n.add, onPressed: () => context.push('/agent/shops/new')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    SearchField(hint: l10n.search, onChanged: (v) => setState(() => _q = v)),
                    if (!showDistricts) ...[
                      const SizedBox(height: 10),
                      FilterChips<VisitState?>(
                        selected: _state,
                        onSelected: (s) => setState(() => _state = s),
                        options: [
                          ChipOption(null, l10n.chipAll(base.length)),
                          ChipOption(VisitState.scheduled, l10n.chipScheduled(count(VisitState.scheduled))),
                          ChipOption(VisitState.overdue, l10n.chipOverdue(count(VisitState.overdue)), tone: ChipTone.error),
                          ChipOption(VisitState.visited, l10n.chipVisited(count(VisitState.visited))),
                          ChipOption(VisitState.notVisited, l10n.chipNotVisited(count(VisitState.notVisited))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator.adaptive(
                  onRefresh: () => ref.read(syncControllerProvider.notifier).syncNow(),
                  child: showDistricts && districtList.isNotEmpty
                      ? ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                          itemCount: districtList.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final d = districtList[i];
                            return DistrictTile(
                              name: d.value.name,
                              shops: d.value.shops,
                              visitedToday: d.value.visited,
                              overdue: d.value.overdue,
                              muted: d.key == null,
                              onTap: () => setState(() {
                                _district = (id: d.key, name: d.value.name);
                                _state = null;
                              }),
                            );
                          },
                        )
                      : shown.isEmpty
                      ? ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(48),
                              child: Center(
                                child: Text(l10n.shopsEmpty, style: TextStyle(color: c.textSecondary)),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final s = shown[i].shop;
                            // A shop the agent added waits for an admin's approval before it can be audited.
                            final pending = s.status != 'ACTIVE';
                            final meters = distanceTo(position, s.lat, s.lng);
                            return ShopListTile(
                              name: s.name,
                              distance: meters == null ? null : l10n.fromYou(distance(context, meters)),
                              address: s.address,
                              imageUrl: s.facadeUrl,
                              footerLabel: pending ? l10n.statusPENDING_REVIEW : l10n.lastVisit,
                              footerValue: pending
                                  ? ''
                                  : s.lastVisitAt == null
                                  ? l10n.never
                                  : shortDateTime(context, s.lastVisitAt!),
                              footerColor: pending ? c.textSecondary : null,
                              onTap: () => context.push('/agent/shops/${s.id}'),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
