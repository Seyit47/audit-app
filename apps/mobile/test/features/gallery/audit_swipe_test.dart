import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/core/widgets/photo_grid.dart';
import 'package:audit_mobile/features/gallery/presentation/audit_sequence.dart';
import 'package:audit_mobile/features/gallery/presentation/photo_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('neighbouring audits in grid order; a photo without an audit is its own', () {
    final seq = [('a1', 'A'), ('a2', 'A'), ('x', 'x'), ('b1', 'B'), ('b2', 'B')];
    expect(auditNeighbours(seq, 'a2'), (prev: null, next: 'x'));
    expect(auditNeighbours(seq, 'x'), (prev: 'a1', next: 'b1'));
    expect(auditNeighbours(seq, 'b2'), (prev: 'x', next: null));
    expect(auditNeighbours(null, 'a1'), (prev: null, next: null));
  });

  testWidgets('swiping the details changes the audit; swiping the photo changes the photo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final opened = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        supportedLocales: const [Locale('en')],
        home: PhotoDetailView(
          photoId: 'p1',
          related: [
            for (final id in ['p1', 'p2']) GridPhoto(id: id, image: null, takenAt: DateTime(2026, 10, 15, 10)),
          ],
          comment: 'Выкладка в порядке',
          onPrevAudit: () => opened.add('prev'),
          onNextAudit: () => opened.add('next'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1500);
    await tester.pumpAndSettle();
    expect(opened, isEmpty, reason: 'the photo swipe stays in the audit');
    expect(find.text('Related audit photos (2)'), findsOneWidget);

    await tester.fling(find.text('Выкладка в порядке'), const Offset(-300, 0), 1500);
    await tester.pumpAndSettle();
    expect(opened, ['next']);
    await tester.fling(find.text('Выкладка в порядке'), const Offset(300, 0), 1500);
    expect(opened, ['next', 'prev']);
  });
}
