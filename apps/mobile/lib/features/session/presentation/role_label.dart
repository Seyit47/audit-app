import 'package:flutter/widgets.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/role.dart';

extension RoleLabel on Role {
  String label(BuildContext context) => switch (this) {
    Role.agent => context.l10n.roleAgent,
    Role.admin => context.l10n.roleAdmin,
  };
}
