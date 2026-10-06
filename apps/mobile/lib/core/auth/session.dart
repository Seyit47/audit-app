enum Role { admin, agent }

/// The signed-in user as returned by `POST /v1/auth/login`.
class SessionUser {
  const SessionUser({required this.id, required this.role, this.agentId});

  factory SessionUser.fromJson(Map<String, dynamic> json) => SessionUser(
        id: json['id'] as String,
        role: json['role'] == 'ADMIN' ? Role.admin : Role.agent,
        agentId: json['agentId'] as String?,
      );

  final String id;
  final Role role;
  final String? agentId;

  Map<String, dynamic> toJson() => {'id': id, 'role': role == Role.admin ? 'ADMIN' : 'AGENT', 'agentId': agentId};
}

class Tokens {
  const Tokens({required this.access, required this.refresh});

  final String access;
  final String refresh;
}
