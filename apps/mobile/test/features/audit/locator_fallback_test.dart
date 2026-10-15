import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the last known position is used only while at most a minute old', () {
    final now = DateTime(2026, 10, 14, 16);
    expect(freshEnough(now.subtract(const Duration(seconds: 30)), now), isTrue);
    expect(freshEnough(now.subtract(const Duration(seconds: 60)), now), isTrue);
    expect(freshEnough(now.subtract(const Duration(minutes: 5)), now), isFalse);
  });

  test('a known position is used at once only when recent (15 s) and precise (30 m)', () {
    final now = DateTime(2026, 10, 15, 12);
    expect(usableAtOnce(at: now.subtract(const Duration(seconds: 5)), accuracyM: 12, now: now), isTrue);
    expect(
      usableAtOnce(at: now.subtract(const Duration(seconds: 40)), accuracyM: 12, now: now),
      isFalse,
      reason: 'too old',
    );
    expect(
      usableAtOnce(at: now.subtract(const Duration(seconds: 5)), accuracyM: 60, now: now),
      isFalse,
      reason: 'too rough',
    );
  });
}
