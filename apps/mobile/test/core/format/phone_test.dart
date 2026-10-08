import 'package:audit_mobile/core/format/phone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('common forms of a Turkmen number become +993XXXXXXXX', () {
    for (final input in ['+993 65 123456', '+99365123456', '993 65 123456', '8 65 123456', '65 123456', '(65) 12-34-56']) {
      expect(tmPhone(input, mobile: true), '+99365123456', reason: input);
    }
    expect(tmPhone('+993 72 123456', mobile: true), '+99372123456');
  });

  test('landlines are fine for shops, not for salesmen', () {
    expect(tmPhone('+993 12 345678'), '+99312345678');
    expect(tmPhone('+993 12 345678', mobile: true), isNull);
  });

  test('other countries and wrong lengths are rejected', () {
    for (final input in ['+7 912 345 67 89', '+993 65 12345', '+993 65 1234567', '+993 85 123456', 'phone', '']) {
      expect(tmPhone(input), isNull, reason: input);
    }
  });
}
