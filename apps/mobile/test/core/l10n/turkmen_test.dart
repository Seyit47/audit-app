import 'package:audit_mobile/core/format/formatters.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/l10n/turkmen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Turkmen loads its strings, Turkmen dates and the Russian Material fallback', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('tk'),
      supportedLocales: const [Locale('ru'), Locale('tk'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...turkmenFallbackDelegates,
      ],
      home: Builder(builder: (context) {
        ctx = context;
        return const SizedBox();
      }),
    ));
    await tester.pumpAndSettle();

    expect(AppLocalizations.of(ctx).homeStartAudit, 'Audite başla');
    expect(MaterialLocalizations.of(ctx).okButtonLabel, isNotEmpty);
    final d = DateTime(2026, 10, 7, 18, 44);
    expect(dayMonth(ctx, d), '7 oktýabr');
    expect(shortDateTime(ctx, d), '7 okt 18:44');
    expect(longDateTime(ctx, d), '7 oktýabr 2026, 18:44');
    expect(distance(ctx, 1234), '1,2 km');
  });
}
