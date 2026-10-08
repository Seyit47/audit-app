import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:audit_mobile/features/audit/presentation/audit_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

/// A fixed state: the real controller is covered by test/features/audit.
class _Fixed extends AuditController {
  _Fixed(super.shopId, this.fixed);
  final AuditState fixed;
  @override
  AuditState build() => fixed;
}

Shop _shop() => Shop(
  id: 's0',
  code: 'CL-100',
  name: 'Магазин «Алтын» (ул. Атамурата, 24)',
  type: 'MARKET',
  address: 'г. Ашхабад, ул. Атамурата, 24',
  lat: 37.95,
  lng: 58.38,
  auditRadiusM: 100,
  status: 'ACTIVE',
  latestVisitsJson: '[]',
  updatedAt: DateTime.utc(2026, 10, 7),
);

AuditDraft _draft(String comment) => AuditDraft(shopId: 's0', auditId: 'a1', startedAt: DateTime.utc(2026, 10, 7, 9), comment: comment, hasViolation: false);

Photo _photo(int i) =>
    Photo(id: 'p$i', kind: 'AUDIT', mime: 'image/jpeg', sizeBytes: 1, sha256: 'x', takenAt: DateTime.utc(2026, 10, 7, 9, i), status: 'DRAFT');

void main() {
  setUpAll(loadFonts);

  for (final dark in [false, true]) {
    testWidgets('audit empty ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(
        tester,
        'audit-empty',
        const AuditScreen(shopId: 's0'),
        db: db,
        dark: dark,
        height: 882,
        overrides: [auditControllerProvider.overrideWith(() => _Fixed('s0', AuditState(shop: _shop(), draft: _draft(''), geo: GeoStatus.locating)))],
      );
      await tester.runAsync(db.close);
    });

    testWidgets('audit filled ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(
        tester,
        'audit-filled',
        const AuditScreen(shopId: 's0'),
        db: db,
        dark: dark,
        height: 882,
        overrides: [
          auditControllerProvider.overrideWith(
            () => _Fixed(
              's0',
              AuditState(
                shop: _shop(),
                draft: _draft('Все рекламные воблеры и ценники на месте. Замечаний нет.'),
                photos: [for (var i = 0; i < 7; i++) _photo(i)],
                geo: GeoStatus.inside,
                fix: const Fix(lat: 37.95, lng: 58.38, accuracyM: 5),
              ),
            ),
          ),
        ],
      );
      await tester.runAsync(db.close);
    });
  }
}
