import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/home/presentation/admin_home_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/agent_home_screen.dart';
import '../../features/add_shop/presentation/add_shop_screen.dart';
import '../../features/audit/presentation/audit_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../features/map/presentation/agent_map_screen.dart';
import '../../features/permission/presentation/permission_screen.dart';
import '../../features/shop_details/presentation/shop_details_screen.dart';
import '../../features/shops/presentation/shops_screen.dart';
import '../auth/session_provider.dart';
import 'redirect.dart';

/// Whether location is granted (checked at start in `main`, updated by the permission screen, A9).
final initialLocationGrantedProvider = Provider<bool>((ref) => false);
final locationGrantedProvider = NotifierProvider<LocationGranted, bool>(LocationGranted.new);

class LocationGranted extends Notifier<bool> {
  @override
  bool build() => ref.watch(initialLocationGrantedProvider);

  void set(bool granted) => state = granted;
}

/// Routes per contracts/screens.md. Each story adds its screens here.
List<RouteBase> appRoutes() => [
      GoRoute(path: Paths.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Paths.agentPermission, builder: (_, _) => const PermissionScreen()),
      GoRoute(path: Paths.agentHome, builder: (_, _) => const AgentHomeScreen(), routes: agentRoutes),
      GoRoute(path: Paths.adminHome, builder: (_, _) => const AdminHomeScreen(), routes: adminRoutes),
    ];

final List<RouteBase> agentRoutes = [
  GoRoute(path: 'map', builder: (_, _) => const AgentMapScreen()),
  GoRoute(path: 'gallery', builder: (_, state) => GalleryScreen(shopId: state.uri.queryParameters['shopId']), routes: [
    GoRoute(path: ':id', builder: (_, state) => AgentPhotoDetailScreen(photoId: state.pathParameters['id']!)),
  ]),
  GoRoute(path: 'audit/:shopId', builder: (_, state) => AuditScreen(shopId: state.pathParameters['shopId']!)),
  GoRoute(path: 'shops', builder: (_, _) => const ShopsScreen(), routes: [
    GoRoute(path: 'new', builder: (_, _) => const AddShopScreen()),
    GoRoute(path: ':id', builder: (_, state) => ShopDetailsScreen(shopId: state.pathParameters['id']!)),
  ]),
];
final List<RouteBase> adminRoutes = [];

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.listen(locationGrantedProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: Paths.login,
    refreshListenable: refresh,
    routes: appRoutes(),
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
