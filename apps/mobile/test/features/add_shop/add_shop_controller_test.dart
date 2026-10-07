import 'dart:convert';

import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/widgets/photo_capture.dart';
import 'package:audit_mobile/features/add_shop/presentation/add_shop_controller.dart';
import 'package:audit_mobile/features/audit/domain/geofence.dart';
import 'package:audit_mobile/features/audit/presentation/audit_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Locator implements Locator {
  @override
  Future<Fix?> current() async => const Fix(lat: 37.95, lng: 58.38, accuracyM: 7);
}

class _Capture implements PhotoCapture {
  @override
  Future<CapturedPhoto?> capture({Fix? fix}) async =>
      CapturedPhoto(id: 'facade-1', path: '/tmp/does-not-exist.jpg', sizeBytes: 1200000, sha256: 'h', takenAt: DateTime.utc(2026, 10, 7, 9), fix: fix);
}

void main() {
  test('Save needs every field, a location and the photo; it queues PHOTO then SHOP_CREATE', () async {
    final db = AppDatabase(NativeDatabase.memory());
    var syncs = 0;
    final c = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      locatorProvider.overrideWithValue(_Locator()),
      photoCaptureProvider.overrideWithValue(_Capture()),
      syncTriggerProvider.overrideWithValue(() => syncs++),
    ]);
    addTearDown(() async { c.dispose(); await db.close(); });
    c.listen(addShopControllerProvider, (_, _) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final ctrl = c.read(addShopControllerProvider.notifier);

    ctrl.edit(name: 'Al-Baraka Fresh Mart', address: 'West Boulevard', owner: 'Tariq Mansoor', phone: 'abc');
    expect(c.read(addShopControllerProvider).canSave, isFalse);
    ctrl.edit(phone: '+993 62 112233');
    expect(c.read(addShopControllerProvider).canSave, isFalse, reason: 'no photo yet');
    await ctrl.takePhoto();
    expect(c.read(addShopControllerProvider).canSave, isTrue);

    expect(await ctrl.save(), isTrue);
    final items = await db.select(db.outbox).get();
    final shop = items.singleWhere((o) => o.kind == OutboxKind.shopCreate);
    final photo = items.singleWhere((o) => o.kind == OutboxKind.photo);
    expect(jsonDecode(shop.dependsOn), [photo.id]);
    final body = jsonDecode(shop.payloadJson) as Map<String, dynamic>;
    expect(body['facadePhotoId'], 'facade-1');
    expect(body['contacts'], [{'phone': '+993 62 112233'}]);
    expect((jsonDecode(photo.payloadJson) as Map).containsKey('shopId'), isFalse);
    expect((await db.select(db.shops).getSingle()).status, 'PENDING_REVIEW');
    expect(syncs, 1);
  });
}
