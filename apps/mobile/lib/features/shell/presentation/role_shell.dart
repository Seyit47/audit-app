import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/role_app_bar.dart';
import '../../session/domain/role.dart';
import '../../system/presentation/connection_status.dart';
import 'role_tabs.dart';

/// Bottom-navigation shell used by both roles; only the tab list differs.
class RoleShell extends StatelessWidget {
  const RoleShell({
    super.key,
    required this.role,
    required this.navigationShell,
  });

  final Role role;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tabs = roleTabs[role]!;
    return Scaffold(
      appBar: RoleAppBar(role: role),
      body: Column(
        children: [
          const ConnectionStatus(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label(context.l10n),
            ),
        ],
      ),
    );
  }
}
