import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/format/phone.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/form_field.dart';
import '../../../core/widgets/home_header.dart';
import '../data/device_identity.dart';
import '../domain/login_input.dart';
import '../../update/app_version_text.dart';
import 'server_settings_sheet.dart';

/// Sign-in (approved exception G1): built only from the Figma form field, primary button, header
/// type and Home background.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _showPassword = false;

  /// The login field shows its error only once the user has left it (or tried to sign in), not after the first letter.
  bool _touched = false;

  static const _methodKey = 'login_method';
  late LoginMethod _method = LoginMethod.values.asNameMap()[ref.read(sharedPreferencesProvider).getString(_methodKey)] ?? LoginMethod.phone;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _loginValue => loginOf(_method, _login.text);
  bool get _valid => _loginValue != null && _password.text.isNotEmpty;

  void _setMethod(LoginMethod method) {
    if (method == _method) return;
    ref.read(sharedPreferencesProvider).setString(_methodKey, method.name);
    setState(() {
      _method = method;
      _login.clear();
      _touched = false;
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_valid) setState(() => _touched = true);
    if (!_valid || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(_loginValue!, _password.text, device: await DeviceIdentity().read());
    } on ApiException catch (e) {
      setState(
        () => _error = switch (e.code) {
          'UNAUTHENTICATED' => l10n.errorCredentials,
          'DEVICE_NOT_BOUND' => l10n.errorDeviceNotBound,
          'RATE_LIMITED' => l10n.errorRateLimited,
          'NETWORK' => l10n.errorNetwork,
          _ => l10n.errorGeneric,
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final phone = _method == LoginMethod.phone;
    final loginError = _touched && _login.text.isNotEmpty && _loginValue == null ? (phone ? l10n.phoneInvalid : l10n.emailInvalid) : null;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: HomeGlow()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.loginTitle,
                        style: TextStyle(
                          fontFamily: AppTextStyles.family,
                          fontSize: 20,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.loginSubtitle,
                        style: AppTextStyles.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      _MethodSwitch(value: _method, onChanged: _setMethod),
                      const SizedBox(height: 16),
                      AppFormField(
                        label: phone ? l10n.phoneNumber : l10n.email,
                        required: true,
                        valid: _loginValue != null,
                        error: loginError,
                        child: Focus(
                          onFocusChange: (focused) {
                            if (!focused && _login.text.isNotEmpty) setState(() => _touched = true);
                          },
                          child: AppTextInput(
                            // A new field per method, so the keyboard type and formatter switch with it.
                            key: ValueKey(_method),
                            controller: _login,
                            hint: phone ? l10n.phoneHint : l10n.emailHint,
                            keyboardType: phone ? TextInputType.phone : TextInputType.emailAddress,
                            inputFormatters: phone ? const [TmPhoneFormatter()] : null,
                            textInputAction: TextInputAction.next,
                            autofillHints: phone ? const [AutofillHints.telephoneNumber] : const [AutofillHints.email],
                            hasError: loginError != null,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppFormField(
                        label: l10n.loginPassword,
                        required: true,
                        error: _error,
                        child: AppTextInput(
                          controller: _password,
                          obscureText: !_showPassword,
                          suffix: IconButton(
                            tooltip: _showPassword ? l10n.hidePassword : l10n.showPassword,
                            icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: c.textSecondary),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                          hasError: _error != null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(label: l10n.loginSubmit, loading: _busy, onPressed: _valid ? _submit : null),
                      const SizedBox(height: 24),
                      const Center(child: AppVersionText()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (AppConfig.settingsPin.isNotEmpty)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip: l10n.serverSettings,
                  icon: Icon(Icons.settings_outlined, color: c.textSecondary),
                  onPressed: () => openServerSettings(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Phone | Email, in the track and accent pill of the language toggle.
class _MethodSwitch extends StatelessWidget {
  const _MethodSwitch({required this.value, required this.onChanged});

  final LoginMethod value;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.white5,
        border: Border.all(color: c.toggleBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: value == LoginMethod.phone ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
          Row(
            children: [
              for (final (method, label) in [(LoginMethod.phone, l10n.loginByPhone), (LoginMethod.email, l10n.loginByEmail)])
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: method == value,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(method),
                      child: Center(
                        child: Text(
                          label,
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: method == value ? const Color(0xFFFCFDFF) : c.toggleOff),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
