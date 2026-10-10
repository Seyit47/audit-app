import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/home_header.dart';
import '../activation_provider.dart';
import '../domain/imei.dart';
import 'imei_entry_view.dart';

/// Shown before sign-in until the activation server says this device is active: the IMEI entry on first
/// launch, then checking and "waiting for activation" (checked again every 30 s).
class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) {
      if (ref.read(activationProvider) == Activation.pending) ref.read(activationProvider.notifier).check();
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activationProvider);
    final notifier = ref.read(activationProvider.notifier);
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: HomeGlow()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: state == Activation.needsImei
                      ? ImeiEntryView(key: const ValueKey('imei'), onSubmit: notifier.submitImei)
                      : _Status(key: ValueKey(state), state: state, imei: notifier.imei, notifier: notifier),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({super.key, required this.state, required this.imei, required this.notifier});

  final Activation state;
  final String? imei;
  final ActivationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final busy = state == Activation.checking || state == Activation.registering || state == Activation.active;
    final (icon, title, body) = switch (state) {
      Activation.pending => (Icons.hourglass_top_rounded, l10n.activationTitle, l10n.activationBody),
      Activation.offline => (Icons.cloud_off_outlined, l10n.activationError, l10n.errorNetwork),
      _ => (Icons.verified_user_outlined, l10n.activationChecking, null),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: c.accent6, shape: BoxShape.circle),
            child: Icon(icon, size: 34, color: c.accent),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(color: c.textPrimary),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: c.textSecondary),
          ),
        ],
        if (imei != null) ...[
          const SizedBox(height: 16),
          SelectableText(
            l10n.activationDeviceId(formatImei(imei!)),
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: c.textSecondary, fontFamily: AppTextStyles.mono),
          ),
        ],
        const SizedBox(height: 28),
        if (busy)
          const Center(child: CircularProgressIndicator.adaptive())
        else ...[
          PrimaryButton(label: l10n.recheck, onPressed: notifier.check),
          const SizedBox(height: 8),
          TextButton(onPressed: notifier.changeImei, child: Text(l10n.imeiChange)),
        ],
      ],
    );
  }
}
