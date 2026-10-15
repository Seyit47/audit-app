import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/buttons.dart';
import 'app_update.dart';
import 'update_gate.dart';

/// "Обновления" from the account menu: the installed version and a manual check. A newer version opens
/// the same dialog as the automatic check. Not a Figma frame (approved exception), in the app's styles.
class UpdatesScreen extends ConsumerStatefulWidget {
  const UpdatesScreen({super.key});

  @override
  ConsumerState<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen> {
  bool _checking = false;
  UpdateCheck? _result;

  Future<void> _check() async {
    setState(() => _checking = true);
    final service = ref.read(updateServiceProvider);
    final result = await service.checkNow();
    if (!mounted) return;
    setState(() {
      _checking = false;
      _result = result;
    });
    final update = result.update;
    if (update != null) await showUpdateDialog(context, update, service);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final version = ref.watch(appVersionProvider).value;
    final result = _result;
    final (message, color) = switch (result?.status) {
      null => (null, c.textSecondary),
      UpdateCheckStatus.upToDate => (l10n.updateUpToDate, c.success),
      UpdateCheckStatus.available => (l10n.updateAvailable(result!.update!.version), c.accent),
      UpdateCheckStatus.unreachable => (l10n.updateUnreachable, c.error),
    };
    return Scaffold(
      backgroundColor: c.mainBg,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(title: l10n.updatesTitle),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.appTitle, style: AppTextStyles.heading.copyWith(color: c.textPrimary)),
                    const SizedBox(height: 4),
                    Text(version == null ? '…' : l10n.versionLine(version.$1, version.$2), style: AppTextStyles.body.copyWith(color: c.textSecondary)),
                    if (message != null) ...[const SizedBox(height: 16), Text(message, style: AppTextStyles.bodyMedium.copyWith(color: color))],
                    const SizedBox(height: 20),
                    PrimaryButton(label: l10n.checkForUpdates, loading: _checking, onPressed: _checking ? null : _check),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
