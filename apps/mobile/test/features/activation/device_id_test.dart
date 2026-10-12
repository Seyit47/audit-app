import 'package:audit_mobile/features/activation/data/activation_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("device ids follow the activation server's format: manufacturer model-first 8 hex characters", () {
    expect(formatDeviceId('samsung', 'SM-A528B', '96847ec2e5f6a7b8'), 'samsung SM-A528B-96847ec2');
    expect(formatDeviceId('Apple', 'iPhone14,5', '7946DA4E-8429-423C-B405-B3FC77914E3E'), 'Apple iPhone14,5-7946da4e');
  });
}
