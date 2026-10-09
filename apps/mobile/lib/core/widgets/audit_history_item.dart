import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';
import 'app_image.dart';
import 'tap.dart';

/// "Зафиксировано нарушение" note or a plain comment box of `83:17057` (83:17149).
class ViolationNote extends StatelessWidget {
  const ViolationNote({super.key, required this.text, this.violationLabel});

  final String text;

  /// Shown with the warning icon when the audit recorded a violation.
  final String? violationLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (violationLabel != null) ...[
            Row(
              children: [
                AppIcon('violation', width: 12.83, height: 11.08, color: c.error),
                const SizedBox(width: 4),
                Text(
                  violationLabel!,
                  style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, fontWeight: FontWeight.w600, color: c.error),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 19.5 / 12, color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// One audit of the shop history (`83:17142`): date and coordinates, note, photos, GPS accuracy.
class AuditHistoryItem extends StatelessWidget {
  const AuditHistoryItem({
    super.key,
    required this.date,
    this.coords,
    this.note,
    this.photosLabel,
    this.photos = const [],
    this.photoTotal,
    this.moreLabel,
    this.seeAllLabel,
    this.onSeeAll,
    this.accuracy,
    this.accuracyOk = true,
    this.status,
    this.statusColor,
    this.duration,
  });

  final String date;
  final String? coords;
  final Widget? note;
  final String? photosLabel;
  final List<String> photos;

  /// All photos of the audit (the server sends at most 8 URLs).
  final int? photoTotal;

  /// "+3 фото" on the fifth tile when there are more.
  final String Function(int hidden)? moreLabel;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;
  final String? accuracy;
  final bool accuracyOk;

  /// Right-aligned state instead of coordinates ("Пропущен", "Ожидает синхронизации").
  final String? status;
  final Color? statusColor;

  /// "Длительность: 12 мин" on the right of the date (admin shop details, 248:24538).
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final small = TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, color: c.textSecondary, fontWeight: FontWeight.w500);
    final shown = photos.length > 5 ? photos.sublist(0, 5) : photos;
    final hidden = (photoTotal ?? photos.length) - shown.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.symmetric(horizontal: BorderSide(color: c.cardBorder)),
        boxShadow: [BoxShadow(color: c.cardShadow, offset: const Offset(0, 4), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                date,
                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, color: c.textPrimary),
              ),
              const Spacer(),
              if (status != null)
                Text(
                  status!,
                  style: small.copyWith(color: statusColor ?? c.textSecondary, fontWeight: FontWeight.w600),
                )
              else if (duration != null)
                Text(duration!, style: small.copyWith(fontWeight: FontWeight.w400))
              else if (coords != null) ...[
                AppIcon('geo-target-muted', width: 13.69, height: 13.69, color: c.textSecondary),
                const SizedBox(width: 4),
                Text(coords!, style: small.copyWith(fontSize: 12)),
              ],
            ],
          ),
          if (note != null) ...[const SizedBox(height: 8), note!],
          if (shown.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(photosLabel ?? '', style: small),
                const Spacer(),
                if (onSeeAll != null && hidden > 0)
                  TextLink(
                    onTap: onSeeAll,
                    child: Text(
                      seeAllLabel ?? '',
                      style: small.copyWith(color: c.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final (i, url) in shown.indexed) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AppImage(url),
                          if (i == 4 && hidden > 0)
                            DecoratedBox(
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text(
                                  moreLabel?.call(hidden) ?? '+$hidden',
                                  style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                for (var i = shown.length; i < 5; i++) ...[const SizedBox(width: 6), const Expanded(child: SizedBox())],
              ],
            ),
          ],
          if (accuracy != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  AppIcon('verified', width: 13.75, height: 13.12, color: accuracyOk ? c.success : c.error),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(accuracy!, style: small.copyWith(color: accuracyOk ? c.success : c.error)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
