import 'package:audit_mobile/core/settings/remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an agent shows the name with code and phone', () {
    final p = Profile.fromMe({
      'user': {'id': 'u', 'role': 'AGENT', 'email': null, 'phone': '+99361234567'},
      'agent': {'code': 'SL-101', 'fullName': 'Demo Agent', 'phone': '+99361234567'},
    })!;
    expect(p.name, 'Demo Agent');
    expect(p.detail, 'SL-101 · +99361234567');
  });

  test('an admin shows the email; nothing before the first pull', () {
    final p = Profile.fromMe({
      'user': {'id': 'u', 'role': 'ADMIN', 'email': 'admin@audit.com', 'phone': null},
      'agent': null,
    })!;
    expect(p.name, 'admin@audit.com');
    expect(p.detail, isNull);
    expect(Profile.fromMe({}), isNull);
  });
}
