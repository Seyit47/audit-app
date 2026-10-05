import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/session/domain/role.dart';
import '../../features/session/presentation/role_label.dart';
import '../../features/session/presentation/session_provider.dart';
import '../l10n/l10n.dart';

/// App bar showing the active role; in debug builds it also offers a role switch.
class RoleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const RoleAppBar({super.key, required this.role});

  final Role role;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(context.l10n.appTitle),
      actions: [
        Chip(label: Text(role.label(context))),
        if (kDebugMode)
          IconButton(
            tooltip: context.l10n.switchRole,
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        const SizedBox(width: 8),
      ],
    );
  }
}
