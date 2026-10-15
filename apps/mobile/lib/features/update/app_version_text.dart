import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_update.dart';

/// "Версия 1.0.30 (31)" in small grey type: the footer of Home and of the sign-in screen.
class AppVersionText extends ConsumerWidget {
  const AppVersionText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    if (version == null) return const SizedBox(height: 16);
    return Text(AppLocalizations.of(context).versionLine(version.$1, version.$2), style: AppTextStyles.caption.copyWith(color: context.colors.textSecondary));
  }
}
