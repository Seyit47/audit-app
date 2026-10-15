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
import '../../../core/widgets/photo_viewer.dart';
import '../../../core/widgets/shop_card.dart';
import '../../../core/widgets/tap.dart';

/// Photo detail of `83:18045` / `248:24402`: date and time, the shop, the audit note and the
/// related audit photos, under the selected photo shown full width. Swipe the photo for the next one;
/// tapping it opens them full screen. The admin's (248:24402) shows the shop's type and code and the
/// responsible agent instead of the coordinates.
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
    this.shopType,
    this.shopCode,
    this.agentName,
    this.agentAudits,
    this.onPrevAudit,
    this.onNextAudit,
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

  /// Admin (248:24402): the type label and code badges, and "Агент: …" with their audits in total.
  final String? shopType;
  final String? shopCode;
  final String? agentName;
  final int? agentAudits;

  /// Swiping the details area (below the photo) right / left: the gallery's previous / next audit.
  final VoidCallback? onPrevAudit;
  final VoidCallback? onNextAudit;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  late String _selected = widget.photoId;
  late final _pages = PageController(initialPage: _indexOf(widget.photoId));

  int _indexOf(String id) => widget.related.indexWhere((p) => p.id == id).clamp(0, widget.related.length - 1);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _select(String id) {
    setState(() => _selected = id);
    _pages.animateToPage(_indexOf(id), duration: const Duration(milliseconds: 250), curve: Curves.easeOutCubic);
  }

  void _fullScreen(BuildContext context, GridPhoto p) =>
      showPhotoViewer(context, [for (final r in widget.related) r.full], initial: widget.related.indexWhere((r) => r.id == p.id));

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
                  // 575:3676 / 248:24429: the selected photo, full width and square; swipe for the next, tap for full screen.
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pages,
                          itemCount: widget.related.length,
                          onPageChanged: (i) => setState(() => _selected = widget.related[i].id),
                          itemBuilder: (context, i) =>
                              InkOverlay(onTap: () => _fullScreen(context, widget.related[i]), child: AppImage(widget.related[i].full, radius: 0)),
                        ),
                        // Which of the audit's photos this is.
                        if (widget.related.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 12,
                            child: IgnorePointer(
                              child: _Dots(count: widget.related.length, index: _indexOf(_selected)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Swiping here (not on the photo) moves to the previous / next audit.
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (d) {
                      final v = d.primaryVelocity ?? 0;
                      if (v < -300) widget.onNextAudit?.call();
                      if (v > 300) widget.onPrevAudit?.call();
                    },
                    child: Padding(
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
                                      if (widget.shopType != null || widget.shopCode != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (widget.shopType != null) ...[Tag(widget.shopType!, strong: true), const SizedBox(width: 8)],
                                            if (widget.shopCode != null) Tag(widget.shopCode!),
                                          ],
                                        ),
                                      ] else if (widget.lat != null) ...[
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
                          if (widget.agentName != null) ...[
                            const SizedBox(height: 12),
                            // 248:24491: a hairline above "Агент: …" and the audits in total.
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: c.border)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: IconLine(icon: 'person-small', iconSize: const Size(10, 10), text: l10n.agentLabel, bold: widget.agentName),
                                  ),
                                  if (widget.agentAudits != null)
                                    IconLine(icon: 'history', iconSize: const Size(11.25, 11.25), text: l10n.auditsTotal(widget.agentAudits!)),
                                ],
                              ),
                            ),
                          ],
                          if (widget.comment.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ViolationNote(text: widget.comment, violationLabel: widget.hasViolation ? l10n.violationRecorded : null),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            l10n.relatedPhotos(widget.related.length),
                            style: TextStyle(
                              fontFamily: AppTextStyles.family,
                              fontSize: 14,
                              height: 16 / 14,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
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
                                  onTap: () => on ? _fullScreen(context, p) : _select(p.id),
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

/// Page dots over the photo (white, the current one wider); "3 / 12" for many photos.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count > 10) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(999)),
          child: Text(
            '${index + 1} / $count',
            style: const TextStyle(fontFamily: AppTextStyles.family, fontSize: 12, color: Colors.white),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? Colors.white : Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(3),
              boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 3)],
            ),
          ),
      ],
    );
  }
}
