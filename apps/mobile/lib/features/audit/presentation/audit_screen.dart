import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/app_database.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../data/audit_local_repository.dart';
import '../domain/geofence.dart';
import 'audit_controller.dart';

/// Audit (`83:17207` → `83:17285` / `106:4374` → `106:6229`).
class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key, required this.shopId});

  final String shopId;

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  final _comment = TextEditingController();
  bool _loadedComment = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final provider = auditControllerProvider(widget.shopId);
    final s = ref.watch(provider);
    final ctrl = ref.read(provider.notifier);
    if (!_loadedComment && s.draft != null) {
      _loadedComment = true;
      _comment.text = s.draft!.comment;
    }

    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(children: [
          ColoredBox(
            color: c.card,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  SizedBox(
                    width: 36,
                    height: 44,
                    child: OverflowBox(
                      maxWidth: 44,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        icon: AppIcon('back', width: 11.77, height: 20, color: c.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.auditTitle, style: AppTextStyles.title.copyWith(fontSize: 20, height: 1.3, letterSpacing: -0.5, color: c.textPrimary)),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: c.success, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(l10n.offlineSaved, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.success)),
                    ]),
                  ]),
                ]),
              ),
            ),
          ),
          _LocationBar(state: s, onRecheck: ctrl.locate),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), children: [
              if (s.photos.isEmpty)
                _EmptyPhotos(onTake: s.canAddPhoto ? ctrl.takePhoto : null)
              else
                _PhotoGrid(photos: s.photos, canAdd: s.canAddPhoto, onAdd: ctrl.takePhoto, onRemove: ctrl.removePhoto),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.cardBorder),
                  boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    AppIcon('comment', width: 13.33, height: 13.33, color: c.textSecondary),
                    const SizedBox(width: 6),
                    Text(l10n.auditComment, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
                  ]),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    constraints: const BoxConstraints(minHeight: 78.5),
                    decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _comment,
                      onChanged: ctrl.setComment,
                      minLines: 2,
                      maxLines: 6,
                      maxLength: 2000,
                      style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 19.5 / 12, color: c.textPrimary),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        counterText: '',
                        hintText: l10n.auditCommentHint,
                        hintStyle: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 19.5 / 12, color: c.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Approved exception 2: the violation chip, from the 83:16884 chip and the
                  // "Зафиксировано нарушение" error colors and icon.
                  _ViolationChip(on: s.hasViolation, label: l10n.violationChip, onTap: ctrl.toggleViolation),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: _FinishButton(
              label: l10n.finishAudit,
              busy: s.finishing,
              onPressed: s.canFinish
                  ? () async {
                      if (await ctrl.finish() && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.auditSaved)));
                        context.pop();
                      }
                    }
                  : null,
            ),
          ),
        ]),
      ),
    );
  }
}

/// "Progress Header Banner": the shop (or the location state) and Проверить заново.
class _LocationBar extends StatelessWidget {
  const _LocationBar({required this.state, required this.onRecheck});

  final AuditState state;
  final Future<void> Function() onRecheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final shop = state.shop;
    final fix = state.fix;
    String? problem;
    switch (state.geo) {
      case GeoStatus.locating:
        problem = l10n.geoLocating;
      case GeoStatus.outside:
        problem = shop == null || fix == null ? null : l10n.geoOutside(distanceMeters(fix.lat, fix.lng, shop.lat, shop.lng).round());
      case GeoStatus.inaccurate:
        problem = l10n.geoInaccurate(fix?.accuracyM.round() ?? 0);
      case GeoStatus.unavailable:
        problem = l10n.geoUnavailable;
      case GeoStatus.inside:
        problem = null;
    }
    final showShop = state.geo == GeoStatus.inside && shop != null;
    return Container(
      color: c.accent6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(children: [
        Expanded(
          child: Row(children: [
            AppIcon('store', width: showShop ? 18 : 15.07, height: showShop ? 16 : 13.5, color: c.accent),
            const SizedBox(width: 6),
            Expanded(
              child: showShop
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(shop.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
                      Text(shop.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 21 / 12, color: c.textSecondary)),
                    ])
                  : Text(problem ?? '', style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500,
                      color: state.geo == GeoStatus.locating ? c.textSecondary : c.error)),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        Tooltip(
          message: l10n.recheck,
          child: Material(
            color: showShop ? const Color(0x99E2DFFF) : c.accent6,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: state.geo == GeoStatus.locating ? null : onRecheck,
              child: const SizedBox(width: 32, height: 32, child: Center(child: AppIcon('refresh', width: 12.67, height: 12.67))),
            ),
          ),
        ),
      ]),
    );
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos({required this.onTake});

  final VoidCallback? onTake;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return _Dashed(
      color: c.border,
      radius: 12,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Container(
            width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: c.accent6, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)]),
            child: const AppIcon('camera', width: 21.67, height: 19.5),
          ),
          const SizedBox(height: 8),
          Text(l10n.photoEmptyTitle, textAlign: TextAlign.center, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
          const SizedBox(height: 4),
          SizedBox(
            width: 259,
            child: Text(l10n.photoEmptyHint, textAlign: TextAlign.center,
                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 17.88 / 11, color: c.textSecondary)),
          ),
          const SizedBox(height: 12),
          Material(
            color: c.accent,
            borderRadius: BorderRadius.circular(8),
            elevation: 2,
            shadowColor: const Color(0x33000000),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTake,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 40,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const AppIcon('camera-add', width: 16.5, height: 15),
                    const SizedBox(width: 8),
                    Text(l10n.takePhoto, style: AppTextStyles.label.copyWith(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// "Фотоматериалы (N фото)": the add tile and photos with delete, 3 per row.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos, required this.canAdd, required this.onAdd, required this.onRemove});

  final List<Photo> photos;
  final bool canAdd;
  final VoidCallback onAdd;
  final ValueChanged<Photo> onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.photoMaterials(photos.length), style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w500, color: c.textSecondary)),
      const SizedBox(height: 6),
      GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Tooltip(
            message: canAdd ? l10n.takePhoto : l10n.photoLimit(AuditLocalRepository.maxPhotos),
            child: _Dashed(
              color: const Color(0xFFD6D5E8),
              radius: 8,
              child: Material(
                color: c.accent6,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: canAdd ? onAdd : null,
                  child: Center(child: Opacity(opacity: canAdd ? 1 : 0.4, child: AppIcon('add-photo', width: 30, height: 30, color: c.textPrimary))),
                ),
              ),
            ),
          ),
          for (final p in photos)
            Stack(fit: StackFit.expand, children: [
              AppImage(p.localPath ?? p.previewUrl),
              Positioned(
                top: 4,
                right: 4,
                child: Tooltip(
                  message: l10n.removePhoto,
                  child: Material(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onRemove(p),
                      child: const SizedBox(width: 28, height: 28, child: Center(child: AppIcon('trash', width: 12, height: 13.5))),
                    ),
                  ),
                ),
              ),
            ]),
        ],
      ),
    ]);
  }
}

class _ViolationChip extends StatelessWidget {
  const _ViolationChip({required this.on, required this.label, required this.onTap});

  final bool on;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      toggled: on,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: on ? c.errorBg : c.chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: on ? c.errorStroke.withValues(alpha: 0.3) : c.chipBorder),
            boxShadow: const [BoxShadow(color: Color(0x0A191B25), offset: Offset(0, 1), blurRadius: 3)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            AppIcon('violation', width: 12.83, height: 11.08, color: on ? c.error : c.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: on ? c.error : c.textSecondary)),
          ]),
        ),
      ),
    );
  }
}

/// "Завершить аудит ✓": disabled at half opacity (83:17207), enabled (83:17285).
class _FinishButton extends StatelessWidget {
  const _FinishButton({required this.label, required this.onPressed, required this.busy});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: const [
          BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
          BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
        ]),
        child: Material(
          color: c.accent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: busy ? null : onPressed,
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (busy)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                else ...[
                  Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(width: 8),
                  const AppIcon('check-white', width: 12.23, height: 9.02),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 1 px dashed rounded border (the photo targets of `83:17207` / `83:17285`).
class _Dashed extends StatelessWidget {
  const _Dashed({required this.child, required this.color, required this.radius});

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(foregroundPainter: _DashPainter(color, radius), child: child);
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.radius);

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5));
    for (final ui.PathMetric m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 7) {
        canvas.drawPath(m.extractPath(d, d + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color || old.radius != radius;
}
