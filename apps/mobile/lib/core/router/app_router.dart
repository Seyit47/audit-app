import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/session_provider.dart';
import 'redirect.dart';

/// Whether the agent granted background location (set by the permission screen, A9).
final locationGrantedProvider = NotifierProvider<LocationGranted, bool>(LocationGranted.new);

class LocationGranted extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool granted) => state = granted;
}

/// Screens register their routes here as their stories land (contracts/screens.md).
final appRoutesProvider = Provider<List<RouteBase>>((ref) => const []);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.listen(locationGrantedProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Paths.login,
    refreshListenable: refresh,
    routes: ref.watch(appRoutesProvider),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      if (session.isLoading) return null;
      return redirectFor(
        location: state.matchedLocation,
        user: session.value,
        locationGranted: ref.read(locationGrantedProvider),
      );
    },
  );
  ref.onDispose(router.dispose);
  return router;
});
