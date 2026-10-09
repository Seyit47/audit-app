import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/features/gallery/data/gallery_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the gallery shows audit photos only, not the storefront photo of a shop the agent added', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    PhotosCompanion photo(String id, String kind) => PhotosCompanion.insert(
      id: id,
      kind: kind,
      status: const Value('READY'),
      mime: 'image/jpeg',
      sizeBytes: 1,
      sha256: 'h',
      takenAt: DateTime.utc(2026, 10, 9),
    );
    await db.into(db.photos).insert(photo('audit-1', 'AUDIT'));
    await db.into(db.photos).insert(photo('facade-1', 'FACADE'));

    final shown = await GalleryRepository(db).watchAll().first;
    expect([for (final p in shown) p.photo.id], ['audit-1']);
  });
}
