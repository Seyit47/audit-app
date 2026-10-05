import '../../features/session/domain/role.dart';
import '../../features/session/domain/session.dart';

const _entryPaths = {'/', '/role-picker', '/sign-in', '/update-required'};

/// Navigation guard, evaluated on every navigation. Returns the path to go to,
/// or null to allow [location]. Rules are listed in contracts/mobile-navigation.md.
String? resolveRedirect({
  required String location,
  required Session? session,
  required bool updateRequired,
  required bool isDebug,
}) {
  if (updateRequired) {
    return location == '/update-required' ? null : '/update-required';
  }

  if (session == null) {
    final entry = isDebug ? '/role-picker' : '/sign-in';
    return location == entry ? null : entry;
  }

  final role = session.role;
  final otherRole = Role.values.firstWhere((r) => r != role);
  if (_entryPaths.contains(location) ||
      location.startsWith(otherRole.pathPrefix)) {
    return role.homePath;
  }
  return null;
}
