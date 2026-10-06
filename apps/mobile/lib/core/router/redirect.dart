import '../auth/session.dart';

/// Route prefixes from contracts/screens.md.
abstract final class Paths {
  static const login = '/login';
  static const agentHome = '/agent';
  static const agentPermission = '/agent/permission';
  static const adminHome = '/admin';
}

String homeOf(Role role) => role == Role.agent ? Paths.agentHome : Paths.adminHome;

/// Where to send [location] for [user] (null = stay). No session → sign-in; signed in → own role's
/// area; agents see the location permission screen (A9) until it's granted.
String? redirectFor({required String location, required SessionUser? user, required bool locationGranted}) {
  if (user == null) return location == Paths.login ? null : Paths.login;
  final home = homeOf(user.role);
  if (location == Paths.login || !location.startsWith(home)) return home;
  if (user.role == Role.agent && !locationGranted && location != Paths.agentPermission) return Paths.agentPermission;
  if (user.role == Role.agent && locationGranted && location == Paths.agentPermission) return home;
  return null;
}
