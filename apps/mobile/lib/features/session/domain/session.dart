import 'role.dart';

/// The signed-in user. Filled by the debug role picker until authentication exists.
class Session {
  const Session({required this.userId, required this.role});

  final String userId;
  final Role role;
}
