import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/widgets/form_field.dart';
import '../../../../core/widgets/photo_target.dart';
import '../../data/admin_api.dart';
import '../../../../core/widgets/adaptive.dart';

/// Mobile Add product (approved exception A7): the fields of Figma `495:2311` with the mobile
/// form components. Uploads the PRODUCT image, then `POST /products`.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _sku = TextEditingController();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _stock = TextEditingController(text: '0');
  final _minStock = TextEditingController(text: '0');
  String? _categoryId;
  String _status = 'ACTIVE';
  bool _stockTracked = false;
  String? _image;
  List<Json> _categories = const [];
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(adminApiProvider).productCategories().then((c) { if (mounted) setState(() => _categories = c); }, onError: (_) {});
  }

  @override
  void dispose() {
    for (final c in [_sku, _name, _brand, _price, _description, _stock, _minStock]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _valid => _sku.text.trim().isNotEmpty && _name.text.trim().isNotEmpty && _categoryId != null && (double.tryParse(_price.text.replaceAll(',', '.')) ?? -1) >= 0;

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 2000);
    if (x != null && mounted) setState(() => _image = x.path);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() { _saving = true; _error = null; });
    final api = ref.read(adminApiProvider);
    try {
      final imageId = _image == null ? null : await api.upload(File(_image!), 'PRODUCT');
      await api.createProduct({
        'sku': _sku.text.trim(),
        'name': _name.text.trim(),
        'categoryId': _categoryId,
        'brand': _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        'retailPrice': double.parse(_price.text.replaceAll(',', '.')),
        'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
        'imageId': imageId,
        'status': _status,
        'stockTracked': _stockTracked,
        'stockQty': int.tryParse(_stock.text) ?? 0,
        'minStockAlert': int.tryParse(_minStock.text) ?? 0,
      });
      if (mounted) context.pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.status == 409 ? l10n.skuConflict : l10n.saveFailed; });
    } catch (_) {
      if (mounted) setState(() { _saving = false; _error = l10n.saveFailed; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    void touch(String _) => setState(() {});
    const gap = SizedBox(height: 22);

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(title: l10n.addProductTitle),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
              Text(l10n.productImage, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
              const SizedBox(height: 6),
              if (_image == null)
                PhotoEmptyTarget(
                  title: l10n.productImage, hint: l10n.productImageHint, buttonLabel: l10n.takePhoto,
                  onTake: () => _pick(ImageSource.camera), galleryLabel: l10n.openGallery, onGallery: () => _pick(ImageSource.gallery),
                )
              else
                Stack(children: [
                  AppImage(_image, height: 176, width: double.infinity),
                  Positioned(right: 8, top: 8, child: IconButton.filledTonal(onPressed: () => setState(() => _image = null), icon: const Icon(Icons.close), tooltip: l10n.removePhoto)),
                ]),
              gap,
              AppFormField(label: l10n.sku, required: true, valid: _sku.text.trim().isNotEmpty, child: AppTextInput(controller: _sku, onChanged: touch)),
              gap,
              AppFormField(label: l10n.productName, required: true, valid: _name.text.trim().isNotEmpty, child: AppTextInput(controller: _name, onChanged: touch)),
              gap,
              AppFormField(
                label: l10n.category, required: true, valid: _categoryId != null,
                child: AppSelect<String>(value: _categoryId, hint: l10n.selectCategory, items: [for (final cat in _categories) (cat['id'] as String, cat['name'] as String)], onChanged: (v) => setState(() => _categoryId = v)),
              ),
              gap,
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: AppFormField(label: l10n.brand, child: AppTextInput(controller: _brand, onChanged: touch))),
                const SizedBox(width: 12),
                Expanded(child: AppFormField(label: l10n.retailPrice, required: true,
                    child: AppTextInput(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: touch, suffix: const Padding(padding: EdgeInsets.all(12), child: Text('TMT'))))),
              ]),
              gap,
              AppFormField(
                label: l10n.description,
                child: AppTextInput(controller: _description, minLines: 3, maxLines: 5),
              ),
              gap,
              AppFormField(
                label: l10n.productStatus,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChips<String>(selected: _status, onSelected: (v) => setState(() => _status = v), options: [
                    ChipOption('ACTIVE', l10n.statusACTIVE), ChipOption('DRAFT', l10n.statusDRAFT), ChipOption('INACTIVE', l10n.statusINACTIVE),
                  ]),
                ),
              ),
              gap,
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.stockTracked, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
                value: _stockTracked,
                onChanged: (v) => setState(() => _stockTracked = v),
              ),
              if (_stockTracked)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: AppFormField(label: l10n.stockQty, child: AppTextInput(controller: _stock, keyboardType: TextInputType.number))),
                  const SizedBox(width: 12),
                  Expanded(child: AppFormField(label: l10n.minStockAlert, child: AppTextInput(controller: _minStock, keyboardType: TextInputType.number))),
                ]),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: AppTextStyles.caption.copyWith(color: c.error))],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: PrimaryButton(label: l10n.save, loading: _saving, onPressed: _valid ? _save : null),
          ),
        ]),
      ),
    );
  }
}
