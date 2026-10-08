import 'package:audit_mobile/features/gallery/presentation/gallery_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'harness.dart';

void main() {
  setUpAll(loadFonts);
  for (final dark in [false, true]) {
    testWidgets('gallery ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(tester, 'gallery', const GalleryScreen(), db: db, dark: dark);
      await tester.runAsync(db.close);
    });
    testWidgets('photo detail ${dark ? 'dark' : 'light'}', (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => seed(db));
      await shoot(
        tester,
        'photo-detail',
        const AgentPhotoDetailScreen(photoId: 'ph0'),
        db: db,
        dark: dark,
      );
      await tester.runAsync(db.close);
    });
  }
}
