import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/session/domain/role.dart';
import '../../features/session/domain/session.dart';
import '../../features/session/presentation/role_picker_screen.dart';
import '../../features/session/presentation/session_provider.dart';
import '../../features/session/presentation/sign_in_placeholder_screen.dart';
import '../../features/shell/presentation/role_shell.dart';
import '../../features/shell/presentation/role_tabs.dart';
import '../../features/system/domain/compatibility.dart';
import '../../features/system/presentation/compatibility_provider.dart';
import '../../features/system/presentation/update_required_screen.dart';
import 'redirect.dart';

typedef RouterState = ({Session? session, bool updateRequired});

final routerProvider = Provider<GoRouter>((ref) {
  // Re-runs the redirect whenever the session or compatibility changes.
  final refresh = ValueNotifier(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..listen(compatibilityProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = createRouter(
    isDebug: kDebugMode,
    refreshListenable: refresh,
    readState: () => (
      session: ref.read(sessionProvider),
      updateRequired: ref.read(compatibilityProvider).value is UpdateRequired,
    ),
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Builds the app's routes. The role picker is only registered in debug builds.
GoRouter createRouter({
  required bool isDebug,
  required RouterState Function() readState,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final current = readState();
      return resolveRedirect(
        location: state.matchedLocation,
        session: current.session,
        updateRequired: current.updateRequired,
        isDebug: isDebug,
      );
    },
    routes: [
      if (isDebug)
        GoRoute(
          path: '/role-picker',
          builder: (_, _) => const RolePickerScreen(),
        ),
      GoRoute(
        path: '/sign-in',
        builder: (_, _) => const SignInPlaceholderScreen(),
      ),
      GoRoute(
        path: '/update-required',
        builder: (_, _) => const UpdateRequiredScreen(),
      ),
      for (final role in Role.values) _roleShellRoute(role),
    ],
  );
}

StatefulShellRoute _roleShellRoute(Role role) {
  return StatefulShellRoute.indexedStack(
    builder: (_, _, navigationShell) =>
        RoleShell(role: role, navigationShell: navigationShell),
    branches: [
      for (final tab in roleTabs[role]!)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '${role.pathPrefix}/${tab.segment}',
              builder: (_, _) => tab.screen,
            ),
          ],
        ),
    ],
  );
}
