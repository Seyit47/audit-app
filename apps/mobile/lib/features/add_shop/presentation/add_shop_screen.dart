import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/settings/remote_config.dart';
import 'add_shop_controller.dart';
import 'map_picker_screen.dart';
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
      picked: s.picked,
      // Agents fine-tune the spot near where they stand: within the audit radius of their GPS position.
      onPickOnMap: s.fix == null
          ? null
          : () async {
              final fix = (s.fix!.lat, s.fix!.lng);
              final config = ref.read(remoteConfigProvider).value ?? const RemoteConfig();
              final point = await MapPickerScreen.open(context, start: s.picked ?? fix, limitFrom: fix, limitMeters: config.defaultAuditRadiusM.toDouble());
              if (point != null) ctrl.pick(point.$1, point.$2);
            },
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
