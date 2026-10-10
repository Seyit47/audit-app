import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/adaptive.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/form_field.dart';
import '../domain/imei.dart';

/// First launch: the agent enters this phone's IMEI. A looping animation shows a phone dialing *#06# and the
/// IMEI appearing; on Android a button opens the dialer with the code filled in.
class ImeiEntryView extends StatefulWidget {
  const ImeiEntryView({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<ImeiEntryView> createState() => _ImeiEntryViewState();
}

class _ImeiEntryViewState extends State<ImeiEntryView> {
  final _imei = TextEditingController();

  @override
  void dispose() {
    _imei.dispose();
    super.dispose();
  }

  void _submit() {
    if (isValidImei(_imei.text)) widget.onSubmit(_imei.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final hint = AppTextStyles.caption.copyWith(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: DialCodeAnimation()),
        const SizedBox(height: 20),
        Text(
          l10n.imeiTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.imeiBody,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(l10n.imeiDualSim, textAlign: TextAlign.center, style: hint),
        if (context.isCupertino) ...[
          const SizedBox(height: 4),
          Text(l10n.imeiIosHint, textAlign: TextAlign.center, style: hint),
        ] else ...[
          const SizedBox(height: 12),
          // Android's dialer accepts the code prefilled ("#" must be encoded); iOS refuses tel: links with * or #.
          SecondaryButton(label: l10n.imeiOpenDialer, onPressed: () => launchUrl(Uri.parse('tel:*%2306%23'))),
        ],
        const SizedBox(height: 20),
        AppTextFormField(
          label: l10n.imeiField,
          required: true,
          controller: _imei,
          hint: '35 693803 564380 9',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(15)],
          validator: (v) => v.length != 15 ? l10n.imeiLength : (isValidImei(v) ? null : l10n.imeiTypo),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: l10n.imeiContinue, onPressed: isValidImei(_imei.text) ? _submit : null),
      ],
    );
  }
}

/// A phone that types *#06# on its keypad (each key lights up as it's pressed), then shows the IMEI, on a loop.
class DialCodeAnimation extends StatefulWidget {
  const DialCodeAnimation({super.key});

  @override
  State<DialCodeAnimation> createState() => _DialCodeAnimationState();
}

class _DialCodeAnimationState extends State<DialCodeAnimation> with SingleTickerProviderStateMixin {
  static const _cycle = 7.0; // seconds
  static const _presses = [('*', 0.6), ('#', 1.1), ('0', 1.6), ('6', 2.1), ('#', 2.6)];
  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
  static const _sample = '356938035643809';

  late final _clock = AnimationController(vsync: this, duration: const Duration(milliseconds: 7000))..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) {
          final s = _clock.value * _cycle;
          final typed = s > 6.6 ? '' : _presses.where((p) => s >= p.$2).map((p) => p.$1).join();
          final pressing = {
            for (final p in _presses)
              if (s >= p.$2 && s < p.$2 + 0.25) p.$1,
          };
          // The IMEI fades in after the last key, stays, then fades out before the loop restarts.
          final shown = s < 3.1 ? 0.0 : (s < 3.5 ? (s - 3.1) / 0.4 : (s < 6.2 ? 1.0 : (s < 6.6 ? (6.6 - s) / 0.4 : 0.0)));
          // A dark bezel around the phone's screen, so it reads as a phone on light and dark backgrounds.
          return Container(
            width: 176,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2549),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: c.cardShadow, blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24)),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 34,
                        child: Center(
                          child: Text(
                            typed,
                            style: AppTextStyles.heading.copyWith(color: c.textPrimary, fontFamily: AppTextStyles.mono, letterSpacing: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 10,
                        children: [for (final k in _keys) _Key(label: k, pressed: pressing.contains(k), inCode: '*#06'.contains(k))],
                      ),
                    ],
                  ),
                  if (shown > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: shown,
                        child: Transform.scale(
                          scale: 0.92 + 0.08 * shown,
                          child: Container(
                            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('IMEI', style: AppTextStyles.label.copyWith(color: c.textSecondary)),
                                const SizedBox(height: 6),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(color: c.accent6, borderRadius: BorderRadius.circular(8)),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      formatImei(_sample),
                                      style: AppTextStyles.caption.copyWith(color: c.accent, fontFamily: AppTextStyles.mono, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.pressed, required this.inCode});

  final String label;
  final bool pressed;
  final bool inCode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      transform: Matrix4.diagonal3Values(pressed ? 0.88 : 1, pressed ? 0.88 : 1, 1),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: pressed ? c.accent : c.secondaryBg),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: pressed ? Colors.white : (inCode ? c.textPrimary : c.textSecondary),
          fontWeight: inCode ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
