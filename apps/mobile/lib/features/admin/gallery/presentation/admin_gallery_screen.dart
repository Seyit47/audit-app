import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/filter_sheet.dart';
import '../../../../core/widgets/photo_grid.dart';
import '../../../gallery/presentation/photo_detail_view.dart';
import '../../data/admin_api.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../../core/widgets/tap.dart';

GridPhoto _grid(Json p) =>
    GridPhoto(id: p['id'] as String, image: (p['previewUrl400'] ?? p['url']) as String?, takenAt: DateTime.parse(p['takenAt'] as String));

/// Admin mobile Gallery (`248:24311`): all photos from the API, newest first, loaded by cursor.
class AdminGalleryScreen extends ConsumerStatefulWidget {
  const AdminGalleryScreen({super.key, this.shopId, this.agentId});

  final String? shopId;
  final String? agentId;

  @override
  ConsumerState<AdminGalleryScreen> createState() => _AdminGalleryScreenState();
}

class _AdminGalleryScreenState extends ConsumerState<AdminGalleryScreen> {
  final _items = <Json>[];
  String? _cursor;
  bool _done = false, _loading = false, _error = false;
  int? _total;
  FilterValues _filters = const {};
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _load();
    });
    _reload();
    ref.read(adminApiProvider).photoSummary().then((s) {
      if (mounted) setState(() => _total = s['total'] as int?);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  var _seq = 0;

  Future<void> _reload() async {
    _seq++; // abandons any page still loading for the previous filters
    setState(() {
      _items.clear();
      _cursor = null;
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
    final days = int.tryParse((_filters['date'] ?? const {}).firstOrNull ?? '');
    final from = days == null ? null : DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: days - 1)).toUtc().toIso8601String();
    try {
      final res = await ref.read(adminApiProvider).photos(shopId: widget.shopId, agentId: widget.agentId, from: from, cursor: _cursor);
      if (!mounted || seq != _seq) return;
      setState(() {
        _items.addAll([for (final i in res['items'] as List) (i as Map).cast<String, dynamic>()]);
        _cursor = res['nextCursor'] as String?;
        _done = _cursor == null;
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
    final filtered = widget.shopId != null || widget.agentId != null || _filters.values.any((v) => v.isNotEmpty);
    final count = filtered ? _items.length : (_total ?? _items.length);
    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scroll,
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
                            Text(
                              l10n.photoCount(count),
                              style: AppTextStyles.title.copyWith(height: 32 / 24, letterSpacing: -0.6, color: c.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: l10n.filterParams,
                        child: Material(
                          color: c.accent6,
                          borderRadius: BorderRadius.circular(8),
                          child: Pressable(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
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
                                ],
                              );
                              if (next != null) {
                                _filters = next;
                                _reload();
                              }
                            },
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: Center(child: AppIcon('filters-dark', width: 15, height: 15, color: c.textSecondary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_items.isEmpty && _loading)
                // First load: a grid of placeholder tiles in the photo grid's own layout.
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  sliver: SliverList.list(
                    children: [
                      const Bone(width: 120, height: 18),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 4,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [for (var i = 0; i < 12; i++) const Bone(radius: 0)],
                      ),
                    ],
                  ),
                )
              else if (_items.isEmpty && _error)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: LoadErrorView(onRetry: _reload)),
                )
              else if (_items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(l10n.noPhotos, style: TextStyle(color: c.textSecondary)),
                  ),
                )
              else
                PhotoDayGrid(photos: [for (final p in _items) _grid(p)], todayLabel: l10n.todayDate, onTap: (p) => context.push('/admin/gallery/${p.id}')),
              if (_loading && _items.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

final _photoProvider = FutureProvider.autoDispose.family<Json, String>((ref, id) => ref.watch(adminApiProvider).photo(id));

/// Admin mobile Photo detail (`248:24402`) from `GET /photos/:id`.
class AdminPhotoDetailScreen extends ConsumerWidget {
  const AdminPhotoDetailScreen({super.key, required this.photoId});

  final String photoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(_photoProvider(photoId)).value;
    if (p == null)
      return Scaffold(
        backgroundColor: context.colors.card,
        body: const SafeArea(child: AppTopBar()),
      );
    final shop = (p['shop'] as Map?)?.cast<String, dynamic>();
    final audit = (p['audit'] as Map?)?.cast<String, dynamic>();
    final related = [for (final r in (p['related'] as List? ?? const []).cast<Map>()) _grid(r.cast<String, dynamic>())];
    return PhotoDetailView(
      photoId: photoId,
      related: related.any((r) => r.id == photoId) ? related : [_grid(p), ...related],
      shopName: shop?['name'] as String?,
      shopAddress: shop?['address'] as String?,
      shopImage: ((shop?['facade'] as Map?)?['previewUrl400']) as String?,
      lat: (shop?['lat'] as num?)?.toDouble(),
      lng: (shop?['lng'] as num?)?.toDouble(),
      comment: (audit?['comment'] as String?) ?? '',
      hasViolation: audit?['hasViolation'] == true,
    );
  }
}
