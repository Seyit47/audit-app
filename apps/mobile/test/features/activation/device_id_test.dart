import 'package:audit_mobile/features/activation/data/activation_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("device ids follow the activation server's format: model-first 8 hex characters", () {
    expect(formatDeviceId('SM-A528B', '424d82d9e5f6a7b8'), 'SM-A528B-424d82d9');
    expect(formatDeviceId('iPhone14,5', '7946DA4E-8429-423C-B405-B3FC77914E3E'), 'iPhone14,5-7946da4e');
    expect(formatDeviceId('Pixel 7', 'abc'), 'Pixel7-abc');
  });
}
