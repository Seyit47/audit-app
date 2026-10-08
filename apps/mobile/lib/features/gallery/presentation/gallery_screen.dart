import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/location/position_provider.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/filter_chips.dart';
import '../../../core/widgets/filter_sheet.dart';
import '../../../core/widgets/photo_grid.dart';
import '../data/gallery_repository.dart';
import 'photo_detail_view.dart';
import '../../../core/widgets/form_field.dart';
import '../../../core/widgets/tap.dart';

/// Agent Gallery (`83:17954` / `106:6558`) from the local photos; [shopId] narrows it to a shop.
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key, this.shopId});

  final String? shopId;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool _searching = false;
  String _q = '';
  late FilterValues _filters = {
    if (widget.shopId != null) 'shop': {widget.shopId!},
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final all = ref.watch(galleryProvider).value ?? const <GalleryPhoto>[];
    final syncing = ref.watch(syncStatusProvider) == SyncStatus.syncing;
    final shops = _filters['shop'] ?? const <String>{};
    final days = int.tryParse((_filters['date'] ?? const <String>{}).firstOrNull ?? '');
    final since = days == null ? null : DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: days - 1));
    final needle = _q.trim().toLowerCase();
    final shown = all
        .where(
          (p) =>
              (shops.isEmpty || shops.contains(p.photo.shopId)) &&
              (since == null || !p.photo.takenAt.toLocal().isBefore(since)) &&
              (needle.isEmpty || (p.shop?.name.toLowerCase().contains(needle) ?? false)),
        )
        .toList();
    final shopOptions = {
      for (final p in all)
        if (p.shop != null) p.shop!.id: p.shop!.name,
    };

    Widget square(String icon, String tip, VoidCallback onTap, {bool on = false}) => Tooltip(
      message: tip,
      child: Material(
        color: on ? c.accent.withValues(alpha: 0.15) : c.accent6,
        borderRadius: BorderRadius.circular(8),
        child: Pressable(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(child: AppIcon(icon, width: 15, height: 15, color: c.textSecondary)),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: AppTopBar(title: l10n.galleryTitle)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.galleryLibrary.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppTextStyles.family,
                              fontSize: 12,
                              height: 16 / 12,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.photoCount(shown.length),
                                style: AppTextStyles.title.copyWith(height: 32 / 24, letterSpacing: -0.6, color: c.textPrimary),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: syncing ? c.accent : c.success, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  syncing ? l10n.syncRunning : l10n.cloudUpToDate,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.label.copyWith(color: syncing ? c.accent : c.success),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    square(
                      'search-accent',
                      l10n.quickSearch,
                      () => setState(() {
                        _searching = !_searching;
                        if (!_searching) _q = '';
                      }),
                      on: _searching,
                    ),
                    const SizedBox(width: 6),
                    square('filters-dark', l10n.filterParams, () async {
                      final next = await showFilterSheet(
                        context,
                        title: l10n.filterParams,
                        applyLabel: l10n.apply,
                        resetLabel: l10n.reset,
                        values: _filters,
                        sections: [
                          FilterSection(
                            key: 'date',
                            label: l10n.filterDate,
                            options: [ChipOption('1', l10n.dateToday), ChipOption('7', l10n.date7), ChipOption('30', l10n.date30)],
                          ),
                          FilterSection(
                            key: 'shop',
                            label: l10n.filterShop,
                            multi: true,
                            options: [for (final e in shopOptions.entries) ChipOption(e.key, e.value)],
                          ),
                        ],
                      );
                      if (next != null) setState(() => _filters = next);
                    }, on: _filters.values.any((v) => v.isNotEmpty)),
                  ],
                ),
              ),
            ),
            if (_searching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: AppTextInput(
                    autofocus: true,
                    hint: l10n.searchShop,
                    textInputAction: TextInputAction.search,
                    onChanged: (v) => setState(() => _q = v),
                  ),
                ),
              ),
            if (shown.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(l10n.noPhotos, style: TextStyle(color: c.textSecondary)),
                ),
              )
            else
              PhotoDayGrid(
                photos: [for (final p in shown) GridPhoto(id: p.photo.id, image: p.image, full: p.full, takenAt: p.photo.takenAt)],
                todayLabel: l10n.todayDate,
                onTap: (p) => context.push('/agent/gallery/${p.id}'),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Agent photo detail (`83:18045` / `106:6710`).
class AgentPhotoDetailScreen extends ConsumerWidget {
  const AgentPhotoDetailScreen({super.key, required this.photoId});

  final String photoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(photoDetailsProvider(photoId)).value;
    if (d == null) {
      return Scaffold(
        backgroundColor: context.colors.card,
        body: const SafeArea(child: AppTopBar()),
      );
    }
    final shop = d.shop;
    return PhotoDetailView(
      photoId: photoId,
      related: [for (final p in d.related) GridPhoto(id: p.photo.id, image: p.image, full: p.full, takenAt: p.photo.takenAt)],
      shopName: shop?.name,
      shopAddress: shop?.address,
      shopImage: shop?.facadeUrl,
      lat: shop?.lat,
      lng: shop?.lng,
      meters: shop == null ? null : distanceTo(ref.watch(positionProvider).value, shop.lat, shop.lng),
      comment: d.comment,
      hasViolation: d.hasViolation,
    );
  }
}
