import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../agents/agents_screen.dart';
import '../../gallery/gallery_screen.dart';
import '../../home/home_screen.dart';
import '../../map/map_screen.dart';
import '../../session/domain/role.dart';
import '../../shops/shops_screen.dart';

/// One bottom-navigation tab: its route segment, icon, label and screen.
class RoleTab {
  const RoleTab({
    required this.segment,
    required this.icon,
    required this.label,
    required this.screen,
  });

  final String segment;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final Widget screen;
}

final _home = RoleTab(
  segment: 'home',
  icon: Icons.home_outlined,
  label: (l10n) => l10n.navHome,
  screen: const HomeScreen(),
);
final _shops = RoleTab(
  segment: 'shops',
  icon: Icons.storefront_outlined,
  label: (l10n) => l10n.navShops,
  screen: const ShopsScreen(),
);
final _map = RoleTab(
  segment: 'map',
  icon: Icons.map_outlined,
  label: (l10n) => l10n.navMap,
  screen: const MapScreen(),
);
final _gallery = RoleTab(
  segment: 'gallery',
  icon: Icons.photo_library_outlined,
  label: (l10n) => l10n.navGallery,
  screen: const GalleryScreen(),
);
final _agents = RoleTab(
  segment: 'agents',
  icon: Icons.groups_outlined,
  label: (l10n) => l10n.navAgents,
  screen: const AgentsScreen(),
);

/// Tabs per role, in the order shown in the designs. Shared screens are reused.
final Map<Role, List<RoleTab>> roleTabs = {
  Role.agent: [_home, _shops, _map, _gallery],
  Role.admin: [_home, _shops, _agents, _map, _gallery],
};
