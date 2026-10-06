import 'package:audit_mobile/core/auth/session.dart';
import 'package:audit_mobile/core/router/redirect.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = SessionUser(id: 'u1', role: Role.agent, agentId: 'u1');
  const admin = SessionUser(id: 'u2', role: Role.admin);

  String? go(String location, SessionUser? user, {bool granted = true}) =>
      redirectFor(location: location, user: user, locationGranted: granted);

  test('no session goes to sign-in', () {
    expect(go('/agent/shops', null), '/login');
    expect(go('/login', null), isNull);
  });

  test('each role lands on and stays in its own area', () {
    expect(go('/login', agent), '/agent');
    expect(go('/login', admin), '/admin');
    expect(go('/admin/shops', agent), '/agent');
    expect(go('/agent/shops', admin), '/admin');
    expect(go('/admin/shops', admin), isNull);
  });

  test('agents see the permission screen until location is granted', () {
    expect(go('/agent', agent, granted: false), '/agent/permission');
    expect(go('/agent/permission', agent, granted: false), isNull);
    expect(go('/agent/permission', agent), '/agent');
  });
}
