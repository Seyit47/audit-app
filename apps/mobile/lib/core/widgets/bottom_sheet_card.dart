import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "BottomStoreSummaryDrawer" of `83:17775` / `106:5609`: 32 px top radius, drag pill, soft shadow.
class BottomSheetCard extends StatelessWidget {
  const BottomSheetCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: c.cardBorder)),
        boxShadow: const [BoxShadow(color: Color(0x14000000), offset: Offset(0, -8), blurRadius: 30)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
