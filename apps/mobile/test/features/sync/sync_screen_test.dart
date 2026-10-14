import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/l10n/app_localizations.dart';
import 'package:audit_mobile/core/sync/outbox_repository.dart';
import 'package:audit_mobile/core/sync/sync_engine.dart';
import 'package:audit_mobile/core/sync/sync_providers.dart';
import 'package:audit_mobile/core/theme/app_theme.dart';
import 'package:audit_mobile/features/sync/presentation/sync_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_sync_api.dart';

/// No triggers or session: only the screen's actions.
class _Sync extends SyncController {
  @override
  SyncState build() => const SyncState();

  @override
  Future<void> pushNow() async {}
}

void main() {
  testWidgets('lists a new shop with its photo; Stop pauses it, Resume brings it back', (tester) async {
    late AppDatabase db;
    late OutboxRepository outbox;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      outbox = OutboxRepository(db);
      await outbox.enqueue(OutboxKind.photo, {'id': 'p1', 'localPath': '/nowhere/p1.jpg'}, id: 'ph-p1');
      await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1', 'name': 'Gunes'}, id: 'sh-s1', dependsOn: ['ph-p1']);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncControllerProvider.overrideWith(_Sync.new),
          // The real engine would build the API client, which waits on the session in secure storage.
          syncEngineProvider.overrideWithValue(SyncEngine(db: db, api: FakeApi(), outbox: outbox)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: const SyncScreen(),
        ),
      ),
    );
    // Real async: drift doesn't finish its queries under the widget test's fake clock.
    Future<void> settle() async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    await settle();
    expect(find.text('New shop · Gunes'), findsOneWidget);
    expect(find.text('Waiting to send'), findsOneWidget);
    expect(find.text('Photo 1'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await settle();
    expect(find.text('Stopped'), findsOneWidget);
    expect((await tester.runAsync(outbox.open))!.map((o) => o.state), everyElement(OutboxState.paused));

    await tester.tap(find.text('Resume'));
    await settle();
    expect(find.text('Waiting to send'), findsOneWidget);

    // Unmount first: closing the screen's query stream schedules a zero timer on the fake clock, and
    // the database only closes once it has fired (closing earlier waits on it forever).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });

  testWidgets('a rejected shop shows Delete instead of Stop; confirming removes it', (tester) async {
    late AppDatabase db;
    late OutboxRepository outbox;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      outbox = OutboxRepository(db);
      await outbox.enqueue(OutboxKind.shopCreate, {'id': 's1', 'name': 'Gunes'}, id: 'sh-s1');
      final item = (await outbox.byId('sh-s1'))!;
      await outbox.markFailed(item, 'GPS_ACCURACY: GPS accuracy must be at most 50 m');
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          syncControllerProvider.overrideWith(_Sync.new),
          syncEngineProvider.overrideWithValue(SyncEngine(db: db, api: FakeApi(), outbox: outbox)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: const SyncScreen(),
        ),
      ),
    );
    Future<void> settle() async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    await settle();
    expect(find.text('Error: GPS_ACCURACY: GPS accuracy must be at most 50 m'), findsOneWidget);
    expect(find.text('Stop'), findsNothing);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete from the phone?'), findsOneWidget);
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await settle();
    expect(find.text('Everything is on the server'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });
}
