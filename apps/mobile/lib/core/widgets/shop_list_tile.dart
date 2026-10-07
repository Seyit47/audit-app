import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_image.dart';
import 'tap.dart';

/// Shop card of `83:16884` / `101:1985`: facade, name, address and the last visit line.
class ShopListTile extends StatelessWidget {
  const ShopListTile({super.key, required this.name, required this.address, required this.imageUrl, required this.footerLabel, required this.footerValue, required this.onTap, this.footerColor});

  final String name;
  final String address;
  final String? imageUrl;
  final String footerLabel;
  final String footerValue;
  final Color? footerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final footer = TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w500, color: footerColor ?? c.accent);
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.cardBorder),
        boxShadow: [BoxShadow(color: c.cardShadow, offset: const Offset(0, 4), blurRadius: 16)],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Pressable(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              AppImage(imageUrl, width: 60, height: 60),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 15, height: 1.25, fontWeight: FontWeight.w600, color: c.textPrimary)),
                    const SizedBox(height: 2),
                    Text(address, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontFamily: AppTextStyles.family, fontSize: 11, height: 1.5, color: c.textSecondary)),
                    const Spacer(),
                    Row(children: [
                      Text(footerLabel, style: footer),
                      const Spacer(),
                      Text(footerValue, style: footer),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
