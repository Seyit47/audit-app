import 'package:audit_mobile/core/widgets/photo_capture.dart';
import 'package:audit_mobile/features/add_shop/presentation/add_shop_controller.dart';
import 'package:audit_mobile/features/add_shop/presentation/add_shop_screen.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';

class _Fixed extends AddShopController {
  _Fixed(this.fixed);
  final AddShopState fixed;
  @override
  AddShopState build() => fixed;
}

void main() {
  setUpAll(loadFonts);
  const fix = Fix(lat: 24.7136, lng: 46.6753, accuracyM: 6);
  final states = {
    'add-shop-empty': const AddShopState(fix: fix, locating: false),
    'add-shop-filled': AddShopState(
      name: 'Al-Baraka Fresh Mart',
      address: 'West Boulevard',
      owner: 'Tariq Mansoor',
      phone: '+993 62 112233',
      fix: fix,
      locating: false,
      photo: CapturedPhoto(id: 'p', path: '/none.jpg', sizeBytes: 1258291, sha256: 'x', takenAt: DateTime.utc(2026)),
    ),
  };
  for (final dark in [false, true]) {
    for (final MapEntry(key: name, value: state) in states.entries) {
      testWidgets('$name ${dark ? 'dark' : 'light'}', (tester) async {
        final db = memoryDb();
        await shoot(
          tester,
          name,
          const AddShopScreen(),
          db: db,
          dark: dark,
          height: 898,
          overrides: [addShopControllerProvider.overrideWith(() => _Fixed(state))],
        );
        await tester.runAsync(db.close);
      });
    }
  }
}
