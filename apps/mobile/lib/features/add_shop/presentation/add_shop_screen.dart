import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import 'add_shop_controller.dart';
import 'shop_form_view.dart';

/// Agent Add shop (`252:26487` → `252:26607` / `101:2472` → `106:5970`).
class AddShopScreen extends ConsumerWidget {
  const AddShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(addShopControllerProvider);
    final ctrl = ref.read(addShopControllerProvider.notifier);
    return ShopFormView(
      title: l10n.addShopTitle,
      name: s.name,
      address: s.address,
      owner: s.owner,
      phone: s.phone,
      onChanged: ctrl.edit,
      fix: s.fix,
      locating: s.locating,
      onRecheck: ctrl.locate,
      photo: s.photo?.path,
      photoSizeBytes: s.photo?.sizeBytes,
      onTakePhoto: ctrl.takePhoto,
      onRemovePhoto: ctrl.removePhoto,
      canSave: s.canSave,
      saving: s.saving,
      onSave: () async {
        if (await ctrl.save() && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shopSaved)));
          context.pop();
        }
      },
    );
  }
}
