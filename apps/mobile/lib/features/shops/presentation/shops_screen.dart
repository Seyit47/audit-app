import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/filter_chips.dart';
import '../../../core/widgets/filter_sheet.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/shop_list_tile.dart';
import '../data/shops_local_repository.dart';
import '../domain/visit_state.dart';

/// Agent Shops (`83:16884` / `101:1985`) from the local mirror; pull-to-refresh runs a sync.
class ShopsScreen extends ConsumerStatefulWidget {
  const ShopsScreen({super.key});

  @override
  ConsumerState<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends ConsumerState<ShopsScreen> {
  VisitState? _state;
  String _q = '';
  FilterValues _filters = const {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final all = ref.watch(shopsProvider).value ?? const <ShopItem>[];
    final regions = _filters['region'] ?? const <String>{};
    final needle = _q.trim().toLowerCase();
    final base = all
        .where(
          (s) =>
              (regions.isEmpty || regions.contains(s.shop.regionName)) &&
              (needle.isEmpty || '${s.shop.name} ${s.shop.code} ${s.shop.address}'.toLowerCase().contains(needle)),
        )
        .toList();
    int count(VisitState s) => base.where((i) => i.visit.state == s).length;
    final shown = _state == null ? base : base.where((i) => i.visit.state == _state).toList();
    final regionNames = {for (final s in all) ?s.shop.regionName}.toList()..sort();

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: l10n.shopsTitle,
              count: all.length,
              action: HeaderButton(label: l10n.add, onPressed: () => context.push('/agent/shops/new')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SearchField(
                    hint: l10n.search,
                    onChanged: (v) => setState(() => _q = v),
                    filtersLabel: l10n.filters,
                    activeFilters: regions.length,
                    onFilters: () async {
                      final next = await showFilterSheet(
                        context,
                        title: l10n.filters,
                        applyLabel: l10n.apply,
                        resetLabel: l10n.reset,
                        values: _filters,
                        sections: [
                          FilterSection(key: 'region', label: l10n.filterRegion, multi: true, options: [for (final r in regionNames) ChipOption(r, r)]),
                        ],
                      );
                      if (next != null) setState(() => _filters = next);
                    },
                  ),
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
              ),
            ),
            Expanded(
              child: RefreshIndicator.adaptive(
                onRefresh: () => ref.read(syncControllerProvider.notifier).syncNow(),
                child: shown.isEmpty
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
                          return ShopListTile(
                            name: s.name,
                            address: s.address,
                            imageUrl: s.facadeUrl,
                            footerLabel: l10n.lastVisit,
                            footerValue: s.lastVisitAt == null ? l10n.never : shortDateTime(context, s.lastVisitAt!),
                            onTap: () => context.push('/agent/shops/${s.id}'),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
