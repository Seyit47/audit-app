import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_image.dart';
import 'tap.dart';

class GridPhoto {
  const GridPhoto({required this.id, required this.image, required this.takenAt});

  final String id;
  final String? image;
  final DateTime takenAt;
}

/// "Photo Stream Timeline" of `83:17954`: day headings and a 4-column grid with 2 px gaps.
class PhotoDayGrid extends StatelessWidget {
  const PhotoDayGrid({super.key, required this.photos, required this.onTap, required this.todayLabel});

  final List<GridPhoto> photos;
  final ValueChanged<GridPhoto> onTap;

  /// "Сегодня, {date}".
  final String Function(String date) todayLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lang = Localizations.localeOf(context).languageCode;
    final groups = <DateTime, List<GridPhoto>>{};
    for (final p in photos) {
      final t = p.takenAt.toLocal();
      groups.putIfAbsent(DateTime(t.year, t.month, t.day), () => []).add(p);
    }
    final today = DateUtils.dateOnly(DateTime.now());
    return SliverList.list(
      children: [
        for (final MapEntry(key: day, value: items) in groups.entries)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day == today ? todayLabel(DateFormat('d MMMM', lang).format(day)) : DateFormat('d MMMM', lang).format(day),
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: c.textPrimary),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [for (final p in items) InkOverlay(onTap: () => onTap(p), child: AppImage(p.image, radius: 0))],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
