import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// Release-build entry point until the authentication feature exists.
class SignInPlaceholderScreen extends StatelessWidget {
  const SignInPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PlaceholderScreen(
      title: context.l10n.signInPlaceholder,
      icon: Icons.lock_outline,
    ),
  );
}
