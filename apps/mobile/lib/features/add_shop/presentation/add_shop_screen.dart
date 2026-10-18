import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/adaptive.dart';
import '../../shops/data/shops_local_repository.dart';
import '../../sync/presentation/sync_screen.dart';
import '../../audit/presentation/audit_controller.dart';
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
    final districts = ref.watch(districtsProvider).value ?? const <District>[];
    return ShopFormView(
      title: l10n.addShopTitle,
      name: s.name,
      address: s.address,
      owner: s.owner,
      phone: s.phone,
      onChanged: ctrl.edit,
      // Synced districts; before the first sync there are none to choose from, and the shop has none.
      districtField: districts.isEmpty
          ? null
          : AppSelect<String>(value: s.districtId, hint: l10n.selectDistrict, items: [for (final d in districts) (d.id, d.name)], onChanged: ctrl.setDistrict),
      districtValid: s.districtId != null,
      fix: s.fix,
      locating: s.locating,
      onRecheck: ctrl.locate,
      detailsOptional: true,
      unavailableText: s.fix == null && !s.locating ? locationProblemText(l10n, ref.watch(locationProblemProvider).value) : null,
      maxAccuracyM: s.maxAccuracyM,
      photo: s.photo?.path,
      photoSizeBytes: s.photo?.sizeBytes,
      onTakePhoto: ctrl.takePhoto,
      onRemovePhoto: ctrl.removePhoto,
      canSave: s.canSave(districtsKnown: districts.isNotEmpty),
      saving: s.saving,
      onSave: () async {
        final item = await ctrl.save();
        if (item == null || !context.mounted) return;
        await sendNow(context, ref, recordId: item, savedOffline: l10n.shopSaved);
        if (context.mounted) context.pop();
      },
    );
  }
}
