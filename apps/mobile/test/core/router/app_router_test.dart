import 'package:audit_mobile/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

bool hasRoute(GoRouter router, String path) => router.configuration.routes
    .whereType<GoRoute>()
    .any((route) => route.path == path);

GoRouter build({required bool isDebug}) => createRouter(
  isDebug: isDebug,
  readState: () => (session: null, updateRequired: false),
);

void main() {
  test('release builds do not register the role picker', () {
    final router = build(isDebug: false);
    expect(hasRoute(router, '/role-picker'), isFalse);
    expect(hasRoute(router, '/sign-in'), isTrue);
  });

  test('debug builds register the role picker', () {
    expect(hasRoute(build(isDebug: true), '/role-picker'), isTrue);
  });
}
