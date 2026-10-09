import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/format/formatters.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/audit_history_item.dart';
import '../../../core/widgets/photo_grid.dart';
import '../../../core/widgets/tap.dart';

/// Photo detail of `83:18045` / `248:24402`: date and time, the shop, the audit note and the
/// related audit photos, under the selected photo shown full width. Tapping a photo opens it full screen.
class PhotoDetailView extends StatefulWidget {
  const PhotoDetailView({
    super.key,
    required this.photoId,
    required this.related,
    this.shopName,
    this.shopAddress,
    this.shopImage,
    this.lat,
    this.lng,
    this.meters,
    this.comment = '',
    this.hasViolation = false,
  });

  final String photoId;
  final List<GridPhoto> related;
  final String? shopName;
  final String? shopAddress;
  final String? shopImage;
  final double? lat;
  final double? lng;
  final double? meters;
  final String comment;
  final bool hasViolation;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  late String _selected = widget.photoId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final current = widget.related.firstWhere((p) => p.id == _selected, orElse: () => widget.related.first);
    final t = current.takenAt.toLocal();
    final day = DateFormat('d MMMM', lang).format(t);
    final text = TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 1.5, color: c.textPrimary);

    return Scaffold(
      backgroundColor: c.card,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateUtils.isSameDay(t, DateTime.now()) ? l10n.todayDate(day) : day,
                    style: TextStyle(
                      fontFamily: AppTextStyles.family,
                      fontSize: 16,
                      height: 1.21,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hhmm(t),
                    style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 1.21, letterSpacing: -0.5, color: c.textPrimary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  // 575:3676 / 248:24429: the selected photo, full width and square; tap for full screen.
                  AspectRatio(
                    aspectRatio: 1,
                    child: InkOverlay(onTap: () => _fullScreen(context, current), child: AppImage(current.full, radius: 0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.shopName != null)
                          Row(
                            children: [
                              AppImage(widget.shopImage, width: 70, height: 70, radius: 12),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.shopName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.shopAddress ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.copyWith(fontWeight: FontWeight.w500),
                                    ),
                                    if (widget.lat != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          AppIcon('geo-target', width: 13.69, height: 13.69, color: c.success),
                                          const SizedBox(width: 4),
                                          Text(
                                            coords(widget.lat!, widget.lng!),
                                            style: TextStyle(
                                              fontFamily: AppTextStyles.family,
                                              fontSize: 12,
                                              height: 1.5,
                                              fontWeight: FontWeight.w500,
                                              color: c.success,
                                            ),
                                          ),
                                          if (widget.meters != null) ...[
                                            const SizedBox(width: 8),
                                            const Text('•', style: TextStyle(fontSize: 12, color: Color(0xFFC7C4D8))),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                l10n.fromYou(distance(context, widget.meters!)),
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, height: 1.5, color: c.textSecondary),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (widget.comment.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ViolationNote(text: widget.comment, violationLabel: widget.hasViolation ? l10n.violationRecorded : null),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          l10n.relatedPhotos(widget.related.length),
                          style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 14, height: 16 / 14, fontWeight: FontWeight.w700, color: c.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.related.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 6),
                            itemBuilder: (context, i) {
                              final p = widget.related[i];
                              final on = p.id == _selected;
                              return InkOverlay(
                                radius: 8,
                                onTap: () => on ? _fullScreen(context, p) : setState(() => _selected = p.id),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: on ? c.accent : Colors.transparent),
                                    boxShadow: const [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2)],
                                  ),
                                  child: AppImage(p.image, radius: 8),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

  void _fullScreen(BuildContext context, GridPhoto p) => showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: InteractiveViewer(
        child: Center(child: AppImage(p.full, radius: 0, fit: BoxFit.contain)),
      ),
    ),
  );
}
