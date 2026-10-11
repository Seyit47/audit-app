import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/server_address.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/adaptive.dart';
import '../../../core/widgets/bottom_sheet_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/form_field.dart';

/// The login screen's gear: asks for the build's settings PIN, then opens the server address sheet.
Future<void> openServerSettings(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final pin = TextEditingController();
  final entered = await showAppDialog<String>(
    context: context,
    title: Text(l10n.settingsPin),
    content: Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppTextInput(
        controller: pin,
        obscureText: true,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
    ),
    actions: (dialog) => [
      AppDialogAction(label: l10n.cancel, onPressed: () => Navigator.pop(dialog)),
      AppDialogAction(label: l10n.apply, primary: true, onPressed: () => Navigator.pop(dialog, pin.text)),
    ],
  );
  pin.dispose();
  if (entered == null || !context.mounted) return;
  if (entered != AppConfig.settingsPin) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinWrong)));
    return;
  }
  // iOS: a Cupertino modal popup; Android: a Material modal bottom sheet (as the filter sheet).
  context.isCupertino
      ? await showCupertinoModalPopup<void>(
          context: context,
          builder: (_) => const Material(type: MaterialType.transparency, child: _ServerSettingsSheet()),
        )
      : await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: false,
          backgroundColor: Colors.transparent,
          builder: (_) => const _ServerSettingsSheet(),
        );
}

class _ServerSettingsSheet extends ConsumerStatefulWidget {
  const _ServerSettingsSheet();

  @override
  ConsumerState<_ServerSettingsSheet> createState() => _ServerSettingsSheetState();
}

class _ServerSettingsSheetState extends ConsumerState<_ServerSettingsSheet> {
  late final ServerAddress _initial = ServerAddress.parse(ref.read(apiUrlProvider));
  late final _host = TextEditingController(text: _initial.host);
  late final _port = TextEditingController(text: _initial.port?.toString() ?? '');
  late bool _https = _initial.https;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  bool get _valid => isValidHost(_host.text.trim()) && (_port.text.isEmpty || isValidPort(_port.text));

  Future<void> _save() async {
    final url = ServerAddress(host: _host.text.trim(), port: int.tryParse(_port.text), https: _https).url;
    await _apply(() => ref.read(apiUrlProvider.notifier).set(url), url);
  }

  Future<void> _reset() => _apply(() => ref.read(apiUrlProvider.notifier).reset(), AppConfig.apiUrl);

  /// Saves only an address where the API answers, so a typo can't cut the app off its server.
  Future<void> _apply(Future<void> Function() save, String url) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await apiReachable(url);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = l10n.serverUnreachable;
      });
      return;
    }
    await save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.serverSaved)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: BottomSheetCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.serverSettings,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.serverCurrent(ref.watch(apiUrlProvider)),
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: l10n.serverHost,
              required: true,
              controller: _host,
              hint: '192.168.1.10',
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              validator: (v) => isValidHost(v.trim()) ? null : l10n.hostInvalid,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: l10n.serverPort,
              controller: _port,
              hint: '3000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v.isEmpty || isValidPort(v) ? null : l10n.portInvalid,
              onChanged: (_) => setState(() => _error = null),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.serverHttps, style: AppTextStyles.label.copyWith(color: c.textPrimary)),
              value: _https,
              onChanged: (v) => setState(() {
                _https = v;
                _error = null;
              }),
            ),
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: c.error),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            PrimaryButton(label: l10n.save, loading: _busy, onPressed: _valid && !_busy ? _save : null),
            const SizedBox(height: 12),
            SecondaryButton(label: l10n.serverReset, onPressed: _busy ? null : _reset),
          ],
        ),
      ),
    );
  }
}
