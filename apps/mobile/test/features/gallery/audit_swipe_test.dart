import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/core/widgets/photo_grid.dart';
import 'package:audit_mobile/features/gallery/presentation/audit_sequence.dart';
import 'package:audit_mobile/features/gallery/presentation/photo_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audits in grid order, as their first photo; a photo without an audit is its own', () {
    final seq = [('a1', 'A'), ('a2', 'A'), ('x', 'x'), ('b1', 'B'), ('b2', 'B')];
    expect(auditPages(seq, 'a2').audits, ['a1', 'x', 'b1']);
    expect(auditPages(seq, 'a2').index, 0);
    expect(auditPages(seq, 'b2').index, 2);
    expect(auditPages(null, 'a1').index, -1);
  });

  testWidgets('swiping the details pages to the next audit on its first photo; swiping the photo stays', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    // Audit A: a1 then a2 (opened on a1, the older); audit B: b1 then b2. The detail shows them newest first.
    final audits = {
      'A': ['a1', 'a2'],
      'B': ['b1', 'b2'],
    };
    String auditOf(String id) => id.startsWith('a') ? 'A' : 'B';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        supportedLocales: const [Locale('en')],
        home: AuditPager(
          photoId: 'a1',
          sequence: const [('a2', 'A'), ('a1', 'A'), ('b2', 'B'), ('b1', 'B')],
          page: (context, id, first) {
            final related = [for (final (i, p) in audits[auditOf(id)]!.indexed) GridPhoto(id: p, image: null, takenAt: DateTime(2026, 10, 15, 10, i))];
            return PhotoDetailView(photoId: id, openOnFirst: first, related: related, comment: 'Audit ${auditOf(id)}');
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    PageController photos() => tester.widget<PageView>(find.byType(PageView).last).controller!;
    expect(find.text('Audit A'), findsOneWidget);
    expect(photos().page, 1, reason: 'opened on a1, second in newest-first order');

    await tester.fling(find.byType(PageView).last, const Offset(300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Audit A'), findsOneWidget, reason: 'a swipe on the photo stays in the audit');

    await tester.fling(find.text('Audit A'), const Offset(-300, 0), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Audit B'), findsOneWidget);
    expect(photos().page, 0, reason: 'the next audit opens on its first photo');
    expect(find.text('Related audit photos (2)'), findsOneWidget);
  });
}
