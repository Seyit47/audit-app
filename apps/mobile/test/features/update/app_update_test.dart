import 'dart:ffi' show Abi;

import 'package:audit_mobile/features/update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads GET /v1/app/latest; only a higher build number is an update', () {
    final u = AppUpdate.fromJson({
      'version': '1.0.29',
      'build': 30,
      'url': '/v1/app/apk/audit-app-1.0.29.apk',
      'sizeBytes': 79000000,
      'notes': 'Fixes',
      'required': true,
    });
    expect(u.required, isTrue);
    expect(u.newerThan(29), isTrue);
    expect(u.newerThan(30), isFalse);
    expect(u.newerThan(31), isFalse);
  });

  test('notes and required are optional', () {
    final u = AppUpdate.fromJson({'version': '1.0.29', 'build': 30, 'url': '/v1/app/apk/a.apk', 'sizeBytes': 1});
    expect(u.notes, '');
    expect(u.required, isFalse);
  });

  test('the CPU type the server picks the APK by', () {
    expect(androidAbi(Abi.androidArm64), 'arm64-v8a');
    expect(androidAbi(Abi.androidArm), 'armeabi-v7a');
    expect(androidAbi(Abi.linuxX64), isNull);
  });
}
