import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
      // The synced districts. None yet (an admin hasn't created any, or the first sync is still to come): the
      // field says so, and the shop is saved without one.
      districtField: districts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                l10n.districtsNoneYet,
                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 13, height: 18 / 13, color: context.colors.textSecondary),
              ),
            )
          : AppSelect<String>(value: s.districtId, hint: l10n.selectDistrict, items: [for (final d in districts) (d.id, d.name)], onChanged: ctrl.setDistrict),
      districtValid: s.districtId != null || districts.isEmpty,
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
