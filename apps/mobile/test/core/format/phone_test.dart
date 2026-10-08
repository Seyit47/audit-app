import 'package:audit_mobile/core/format/phone.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  phoneInputTests();
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

TextEditingValue _type(TextEditingValue old, String text, [int? cursor]) => const TmPhoneFormatter().formatEditUpdate(
  old,
  TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: cursor ?? text.length),
  ),
);

TextEditingValue _typeAll(String keys) {
  var v = const TextEditingValue(selection: TextSelection.collapsed(offset: 0));
  for (final k in keys.split('')) {
    v = _type(v, v.text.substring(0, v.selection.baseOffset) + k + v.text.substring(v.selection.baseOffset), v.selection.baseOffset + 1);
  }
  return v;
}

void phoneInputTests() {
  test('typing shows +993 XX XXXXXX and stops after 8 digits', () {
    expect(_typeAll('6').text, '+993 6');
    expect(_typeAll('651').text, '+993 65 1');
    expect(_typeAll('65123456').text, '+993 65 123456');
    expect(_typeAll('651234567').text, '+993 65 123456');
    expect(tmPhone(_typeAll('65123456').text), '+99365123456');
  });

  test('a typed or pasted dialling prefix is folded into +993', () {
    expect(_typeAll('865123456').text, '+993 65 123456');
    expect(_typeAll('+99365123456').text, '+993 65 123456');
    expect(_type(TextEditingValue.empty, '+993 65 12 34 56').text, '+993 65 123456');
  });

  test('backspace steps over spaces and empties the field after the last digit', () {
    final full = _typeAll('651');
    // Cursor right after the space before "1": backspace deletes the space → the 5 goes.
    final v = _type(full, '+993 651', 7);
    expect(v.text, '+993 61');
    expect(_type(_typeAll('6'), '+993 ').text, '');
    // Inside the prefix nothing changes.
    expect(_type(full, '+93 65 1', 2).text, '+993 65 1');
  });

  test('stored numbers are shown formatted', () {
    expect(displayPhone('+99362112233'), '+993 62 112233');
    expect(displayPhone('+7 912'), '+7 912');
  });
}
