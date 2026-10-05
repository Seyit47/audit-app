import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/role.dart';
import '../domain/session.dart';
import 'role_label.dart';
import 'session_provider.dart';

/// Debug-only stand-in for sign-in: pick a role to explore its shell.
class RolePickerScreen extends ConsumerWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.rolePickerTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              for (final role in Role.values) ...[
                FilledButton(
                  onPressed: () => ref
                      .read(sessionProvider.notifier)
                      .signIn(Session(userId: 'dev-${role.name}', role: role)),
                  child: Text(role.label(context)),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
