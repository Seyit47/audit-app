import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/form_field.dart';
import '../../../core/widgets/photo_target.dart';
import 'add_shop_controller.dart';

/// Agent Add shop (`252:26487` → `252:26607` / `101:2472` → `106:5970`).
class AddShopScreen extends ConsumerStatefulWidget {
  const AddShopScreen({super.key});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final s = ref.watch(addShopControllerProvider);
    final ctrl = ref.read(addShopControllerProvider.notifier);
    final label = TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 20 / 14, letterSpacing: -0.35, fontWeight: FontWeight.w600, color: c.textPrimary);
    final fix = s.fix;

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          AppTopBar(title: l10n.addShopTitle),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
              AppFormField(
                label: l10n.shopName, required: true, valid: s.nameOk,
                child: AppTextInput(
                  controller: _name, hint: l10n.shopNameHint, textInputAction: TextInputAction.next,
                  onChanged: (v) => ctrl.edit(name: v),
                  suffix: s.name.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l10n.clear,
                          onPressed: () { _name.clear(); ctrl.edit(name: ''); },
                          icon: AppIcon('field-clear', width: 28, height: 28, color: c.textSecondary),
                        ),
                ),
              ),
              const SizedBox(height: 22),
              AppFormField(label: l10n.address, required: true, valid: s.addressOk,
                  child: AppTextInput(hint: l10n.addressHint, textInputAction: TextInputAction.next, onChanged: (v) => ctrl.edit(address: v))),
              const SizedBox(height: 22),
              AppFormField(label: l10n.owner, required: true, valid: s.ownerOk,
                  child: AppTextInput(hint: l10n.ownerHint, textInputAction: TextInputAction.next, onChanged: (v) => ctrl.edit(owner: v))),
              const SizedBox(height: 22),
              AppFormField(
                label: l10n.phoneNumber, required: true, valid: s.phoneOk,
                child: AppTextInput(
                  hint: l10n.phoneHint, keyboardType: TextInputType.phone, onChanged: (v) => ctrl.edit(phone: v),
                  prefix: AppIcon('phone', width: 12, height: 12, color: c.textSecondary),
                ),
              ),
              const SizedBox(height: 28),
              Row(children: [
                const AppIcon('navigate', width: 15, height: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.currentLocation, style: label)),
                Material(
                  color: const Color(0x99E2DFFF),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: s.locating ? null : ctrl.locate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Row(children: [
                        const AppIcon('refresh-small', width: 9.33, height: 9.33),
                        const SizedBox(width: 4),
                        Text(l10n.recheck, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: c.accent)),
                      ]),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    s.locating ? l10n.geoLocating : fix == null ? l10n.geoUnavailable : l10n.accuracyLine(fix.accuracyM.round()),
                    style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: fix == null && !s.locating ? c.error : c.textSecondary),
                  ),
                  if (fix != null) ...[
                    const SizedBox(height: 10),
                    Row(children: [
                      AppIcon('target-small', width: 11.86, height: 11.86, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Text(l10n.coordsLine(fix.lat.toStringAsFixed(4), fix.lng.toStringAsFixed(4)),
                          style: TextStyle(fontFamily: AppTextStyles.mono, fontSize: 12, height: 16.5 / 12, color: c.textSecondary)),
                    ]),
                  ],
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const AppIcon('storefront', width: 16.74, height: 15),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.storefrontPhoto, style: label)),
                if (s.photo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xCC2E303B), borderRadius: BorderRadius.circular(6)),
                    child: Text(l10n.photoCaptured('${(s.photo!.sizeBytes / 1048576).toStringAsFixed(1)} MB'),
                        style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: Color(0xFFF0EFFE))),
                  ),
              ]),
              const SizedBox(height: 12),
              if (s.photo == null)
                PhotoEmptyTarget(title: l10n.photoNotTaken, hint: l10n.photoEmptyHint, buttonLabel: l10n.takePhoto, onTake: ctrl.takePhoto)
              else
                SizedBox(
                  height: 176,
                  child: Stack(fit: StackFit.expand, children: [
                    AppImage(s.photo!.path, radius: 8),
                    Positioned(
                      left: 10, right: 10, bottom: 10,
                      child: Row(children: [
                        Expanded(
                          child: Material(
                            color: const Color(0xD92E303B),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: ctrl.takePhoto,
                              child: SizedBox(
                                height: 36,
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const AppIcon('retake', width: 13.33, height: 12),
                                  const SizedBox(width: 6),
                                  Text(l10n.retake, style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Color(0xFFF0EFFE))),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: l10n.removePhoto,
                          child: Material(
                            color: const Color(0xFFF9EDEC),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: ctrl.removePhoto,
                              child: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('trash-red', width: 12, height: 13.5))),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(color: c.card, border: Border(top: BorderSide(color: c.cardBorder))),
            child: Row(children: [
              Expanded(
                child: Material(
                  color: c.accent6,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.pop(),
                    child: SizedBox(height: 48, child: Center(child: Text(l10n.cancel, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary)))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: s.canSave ? 1 : 0.5,
                  child: Material(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: s.canSave
                          ? () async {
                              if (await ctrl.save() && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.shopSaved)));
                                context.pop();
                              }
                            }
                          : null,
                      child: SizedBox(height: 48, child: Center(child: Text(l10n.save, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.white)))),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
