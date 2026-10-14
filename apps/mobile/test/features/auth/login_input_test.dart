import 'package:audit_mobile/features/auth/domain/login_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a phone signs in as +993 and 8 digits, only once complete', () {
    expect(loginOf(LoginMethod.phone, '+993 65 123456'), '+99365123456');
    expect(loginOf(LoginMethod.phone, '+993 65 123'), isNull);
  });

  test('an email must look like one; it is trimmed and lower-cased', () {
    expect(loginOf(LoginMethod.email, ' Admin@Audit.com '), 'admin@audit.com');
    for (final bad in ['admin', 'admin@', 'admin@audit', 'admin@audit.c', 'a b@audit.com']) {
      expect(loginOf(LoginMethod.email, bad), isNull, reason: bad);
    }
  });
}
