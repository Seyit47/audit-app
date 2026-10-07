import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../core/widgets/shop_card.dart';
import '../../data/admin_api.dart';
import '../../../../core/widgets/skeleton.dart';

/// Mobile admin Products (approved exception A7): `GET /products` as cards styled from `246:23300`.
class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  List<Json>? _items;
  int _total = 0;
  bool _error = false;
  String _q = '';
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
    final seq = ++_seq; // a slower, older search must not overwrite a newer one
    try {
      final page = await ref.read(adminApiProvider).products(q: _q);
      if (mounted && seq == _seq) setState(() { _items = page.items; _total = page.total; _error = false; });
    } catch (_) {
      if (mounted && seq == _seq) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    String status(String? s) => switch (s) { 'ACTIVE' => l10n.statusACTIVE, 'DRAFT' => l10n.statusDRAFT, _ => l10n.statusINACTIVE };
    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(
            title: l10n.productsTitle,
            count: _total,
            action: HeaderButton(label: l10n.add, onPressed: () async {
              if (await context.push<bool>('/admin/products/new') == true) _load();
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SearchField(hint: l10n.search, onChanged: (v) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 350), () { _q = v; _load(); });
            }),
          ),
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 48), children: [
                if (_error) LoadErrorView(onRetry: () { setState(() => _error = false); _load(); }),
                if (_items == null && !_error) const CardListSkeleton(count: 5),
                if (_items != null && _items!.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.productsEmpty, style: TextStyle(color: c.textSecondary)))),
                for (final p in _items ?? const <Json>[]) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.cardBorder),
                        boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)]),
                    child: Row(children: [
                      AppImage(((p['image'] as Map?)?['previewUrl400'] ?? (p['image'] as Map?)?['url']) as String?, width: 64, height: 64, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Tag(((p['category'] as Map?)?['name'] as String?) ?? '—', strong: true),
                            const SizedBox(width: 6),
                            Tag(p['sku'] as String),
                            const Spacer(),
                            Text(status(p['status'] as String?), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500,
                                color: p['status'] == 'ACTIVE' ? c.success : c.textSecondary)),
                          ]),
                          const SizedBox(height: 4),
                          Text(p['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: c.textPrimary)),
                          Row(children: [
                            Text(l10n.price('${p['retailPrice']}'), style: AppTextStyles.label.copyWith(color: c.accent)),
                            const SizedBox(width: 12),
                            Text(l10n.locationsShort((p['locations'] as int?) ?? 0), style: AppTextStyles.caption.copyWith(color: c.textSecondary)),
                            const SizedBox(width: 12),
                            Text(l10n.coverage('${p['coveragePct'] ?? 0}'), style: AppTextStyles.caption.copyWith(color: c.textSecondary)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
