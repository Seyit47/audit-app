import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/form_field.dart';
import '../../../core/widgets/photo_target.dart';
import '../../audit/domain/geofence.dart';
import '../../../core/widgets/tap.dart';

/// The add/edit shop form of `252:26487` (agent) and `252:25423` (admin, with Агент and the
/// gallery button). Values live in the caller; this lays them out.
class ShopFormView extends StatefulWidget {
  const ShopFormView({
    super.key,
    required this.title,
    required this.name,
    required this.address,
    required this.owner,
    required this.phone,
    required this.onChanged,
    required this.fix,
    required this.locating,
    required this.onRecheck,
    required this.photo,
    this.photoSizeBytes,
    required this.onTakePhoto,
    this.onPickPhoto,
    required this.onRemovePhoto,
    required this.canSave,
    required this.saving,
    required this.onSave,
    this.agentField,
    this.agentValid = false,
    this.error,
  });

  final String title;
  final String name;
  final String address;
  final String owner;
  final String phone;
  final void Function({String? name, String? address, String? owner, String? phone}) onChanged;
  final Fix? fix;
  final bool locating;
  final VoidCallback onRecheck;

  /// Local path or URL of the storefront photo.
  final String? photo;
  final int? photoSizeBytes;
  final VoidCallback onTakePhoto;
  final VoidCallback? onPickPhoto;
  final VoidCallback onRemovePhoto;
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;

  /// The admin "Агент" select.
  final Widget? agentField;
  final bool agentValid;
  final String? error;

  @override
  State<ShopFormView> createState() => _ShopFormViewState();
}

class _ShopFormViewState extends State<ShopFormView> {
  late final _name = TextEditingController(text: widget.name);
  late final _address = TextEditingController(text: widget.address);
  late final _owner = TextEditingController(text: widget.owner);
  late final _phone = TextEditingController(text: widget.phone);

  @override
  void dispose() {
    for (final c in [_name, _address, _owner, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  static final _phoneRe = RegExp(r'^\+?[0-9 ()-]{6,20}$');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final w = widget;
    final label = TextStyle(
      fontFamily: AppTextStyles.family,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: -0.35,
      fontWeight: FontWeight.w600,
      color: c.textPrimary,
    );
    final fix = w.fix;

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: w.title),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  AppFormField(
                    label: l10n.shopName,
                    required: true,
                    valid: w.name.trim().isNotEmpty,
                    child: AppTextInput(
                      controller: _name,
                      hint: l10n.shopNameHint,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) => w.onChanged(name: v),
                      suffix: w.name.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.clear,
                              onPressed: () {
                                _name.clear();
                                w.onChanged(name: '');
                              },
                              icon: AppIcon('field-clear', width: 28, height: 28, color: c.textSecondary),
                            ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppFormField(
                    label: l10n.address,
                    required: true,
                    valid: w.address.trim().isNotEmpty,
                    child: AppTextInput(
                      controller: _address,
                      hint: l10n.addressHint,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) => w.onChanged(address: v),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppFormField(
                    label: l10n.owner,
                    required: true,
                    valid: w.owner.trim().isNotEmpty,
                    child: AppTextInput(
                      controller: _owner,
                      hint: l10n.ownerHint,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) => w.onChanged(owner: v),
                    ),
                  ),
                  if (w.agentField != null) ...[
                    const SizedBox(height: 22),
                    AppFormField(label: l10n.agent, required: true, valid: w.agentValid, child: w.agentField!),
                  ],
                  const SizedBox(height: 22),
                  AppFormField(
                    label: l10n.phoneNumber,
                    required: true,
                    valid: _phoneRe.hasMatch(w.phone.trim()),
                    child: AppTextInput(
                      controller: _phone,
                      hint: l10n.phoneHint,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => w.onChanged(phone: v),
                      prefix: AppIcon('phone', width: 12, height: 12, color: c.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const AppIcon('navigate', width: 15, height: 15),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.currentLocation, style: label)),
                      Material(
                        color: const Color(0x99E2DFFF),
                        borderRadius: BorderRadius.circular(6),
                        child: Pressable(
                          borderRadius: BorderRadius.circular(6),
                          onTap: w.locating ? null : w.onRecheck,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Row(
                              children: [
                                const AppIcon('refresh-small', width: 9.33, height: 9.33),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.recheck,
                                  style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: c.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.locating
                              ? l10n.geoLocating
                              : fix == null
                              ? l10n.geoUnavailable
                              : l10n.accuracyLine(fix.accuracyM.round()),
                          style: TextStyle(
                            fontFamily: AppTextStyles.family,
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w500,
                            color: fix == null && !w.locating ? c.error : c.textSecondary,
                          ),
                        ),
                        if (fix != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              AppIcon('target-small', width: 11.86, height: 11.86, color: c.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                l10n.coordsLine(fix.lat.toStringAsFixed(4), fix.lng.toStringAsFixed(4)),
                                style: TextStyle(fontFamily: AppTextStyles.mono, fontSize: 12, height: 16.5 / 12, color: c.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const AppIcon('storefront', width: 16.74, height: 15),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.storefrontPhoto, style: label)),
                      if (w.photo != null && w.photoSizeBytes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xCC2E303B), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            l10n.photoCaptured('${(w.photoSizeBytes! / 1048576).toStringAsFixed(1)} MB'),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.family,
                              fontSize: 11,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFF0EFFE),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (w.photo == null)
                    PhotoEmptyTarget(
                      title: l10n.photoNotTaken,
                      hint: l10n.photoEmptyHint,
                      buttonLabel: l10n.takePhoto,
                      onTake: w.onTakePhoto,
                      galleryLabel: l10n.openGallery,
                      onGallery: w.onPickPhoto,
                    )
                  else
                    SizedBox(
                      height: 176,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(w.photo, radius: 8),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Material(
                                    color: const Color(0xD92E303B),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Pressable(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: w.onTakePhoto,
                                      child: SizedBox(
                                        height: 36,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const AppIcon('retake', width: 13.33, height: 12),
                                            const SizedBox(width: 6),
                                            Text(
                                              l10n.retake,
                                              style: const TextStyle(
                                                fontFamily: AppTextStyles.family,
                                                fontSize: 12,
                                                height: 16 / 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFF0EFFE),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                    child: Pressable(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: w.onRemovePhoto,
                                      child: const SizedBox(width: 36, height: 36, child: Center(child: AppIcon('trash-red', width: 12, height: 13.5))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (w.error != null) ...[const SizedBox(height: 12), Text(w.error!, style: AppTextStyles.caption.copyWith(color: c.error))],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: c.card,
                border: Border(top: BorderSide(color: c.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: c.accent6,
                      borderRadius: BorderRadius.circular(12),
                      child: Pressable(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: Text(
                              l10n.cancel,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Opacity(
                      opacity: w.canSave ? 1 : 0.5,
                      child: Material(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(12),
                        child: Pressable(
                          borderRadius: BorderRadius.circular(12),
                          onTap: w.canSave && !w.saving ? w.onSave : null,
                          child: SizedBox(
                            height: 48,
                            child: Center(
                              child: w.saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    )
                                  : Text(
                                      l10n.save,
                                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
