import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/form_field.dart';
import '../../../core/widgets/home_header.dart';
import '../data/device_identity.dart';

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

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _valid => _login.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(_login.text.trim(), _password.text, device: await DeviceIdentity().read());
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
                      AppFormField(
                        label: l10n.loginLogin,
                        required: true,
                        child: AppTextInput(
                          controller: _login,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username, AutofillHints.telephoneNumber],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppFormField(
                        label: l10n.loginPassword,
                        required: true,
                        error: _error,
                        child: AppTextInput(
                          controller: _password,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _submit(),
                          hasError: _error != null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(label: l10n.loginSubmit, loading: _busy, onPressed: _valid ? _submit : null),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
