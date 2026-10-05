import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/widgets/placeholder_screen.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) => PlaceholderScreen(
    title: context.l10n.navAgents,
    icon: Icons.groups_outlined,
  );
}
