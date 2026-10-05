import 'package:audit_mobile/core/router/redirect.dart';
import 'package:audit_mobile/features/session/domain/role.dart';
import 'package:audit_mobile/features/session/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';

const agent = Session(userId: 'dev-agent', role: Role.agent);
const admin = Session(userId: 'dev-admin', role: Role.admin);

String? redirect(
  String location, {
  Session? session,
  bool updateRequired = false,
  bool isDebug = true,
}) => resolveRedirect(
  location: location,
  session: session,
  updateRequired: updateRequired,
  isDebug: isDebug,
);

void main() {
  test('rule 1: update required wins over everything', () {
    expect(
      redirect('/agent/home', session: agent, updateRequired: true),
      '/update-required',
    );
    expect(
      redirect('/update-required', session: agent, updateRequired: true),
      isNull,
    );
  });

  test(
    'rule 2: no session goes to the role picker in debug, sign-in in release',
    () {
      expect(redirect('/agent/home'), '/role-picker');
      expect(redirect('/agent/home', isDebug: false), '/sign-in');
      expect(redirect('/role-picker'), isNull);
      expect(redirect('/sign-in', isDebug: false), isNull);
    },
  );

  test('rule 3: the other role\'s paths go to the current role home', () {
    expect(redirect('/admin/shops', session: agent), '/agent/home');
    expect(redirect('/agent/map', session: admin), '/admin/home');
  });

  test('rule 4: entry points go to the role home once signed in', () {
    expect(redirect('/', session: agent), '/agent/home');
    expect(redirect('/role-picker', session: admin), '/admin/home');
    expect(redirect('/sign-in', session: agent), '/agent/home');
    expect(redirect('/update-required', session: agent), '/agent/home');
  });

  test('own role paths are allowed', () {
    expect(redirect('/agent/gallery', session: agent), isNull);
    expect(redirect('/admin/agents', session: admin), isNull);
  });
}
