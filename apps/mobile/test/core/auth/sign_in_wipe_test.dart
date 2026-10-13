import 'package:audit_mobile/core/auth/session.dart';
import 'package:audit_mobile/core/auth/session_provider.dart';
import 'package:audit_mobile/core/auth/session_store.dart';
import 'package:audit_mobile/core/db/app_database.dart';
import 'package:audit_mobile/core/db/database_provider.dart';
import 'package:audit_mobile/core/network/api_client.dart';
import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/core/sync/local_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Api extends Mock implements ApiClient {}

class _Store extends Mock implements SessionStore {}

void main() {
  late _Api api;
  late _Store store;
  late AppDatabase db;
  late int wipes;

  Future<ProviderContainer> open(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        apiClientProvider.overrideWithValue(api),
        sessionStoreProvider.overrideWithValue(store),
        databaseProvider.overrideWithValue(db),
        wipeLocalDataProvider.overrideWithValue(() async => wipes++),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  void loginAs(String id) => when(() => api.post<Map<String, dynamic>>('/auth/login', body: any(named: 'body'), auth: false)).thenAnswer(
    (_) async => {
      'accessToken': 'a',
      'refreshToken': 'r',
      'user': {'id': id, 'role': 'AGENT', 'agentId': id},
    },
  );

  setUpAll(() {
    registerFallbackValue(const Tokens(access: '', refresh: ''));
    registerFallbackValue(const SessionUser(id: 'x', role: Role.agent));
  });
  setUp(() {
    api = _Api();
    store = _Store();
    db = AppDatabase(NativeDatabase.memory());
    wipes = 0;
    when(() => store.readTokens()).thenAnswer((_) async => null);
    when(() => store.writeTokens(any())).thenAnswer((_) async {});
    when(() => store.writeUser(any())).thenAnswer((_) async {});
  });
  tearDown(() => db.close());

  test('the same user on the same server keeps the local data', () async {
    final c = await open({'data_owner': 'u1@${c0Url()}'});
    loginAs('u1');
    await c.read(sessionProvider.notifier).signIn('a', 'b');
    expect(wipes, 0);
  });

  test('another user, or the same user on another server, starts clean', () async {
    final c = await open({'data_owner': 'u1@${c0Url()}'});
    loginAs('u2');
    await c.read(sessionProvider.notifier).signIn('a', 'b');
    expect(wipes, 1);
    expect((await SharedPreferences.getInstance()).getString('data_owner'), 'u2@${c0Url()}');

    final c2 = await open({'data_owner': 'u2@http://old-server:3000'});
    await c2.read(sessionProvider.notifier).signIn('a', 'b');
    expect(wipes, 2);
  });

  test('with no owner recorded, unsent audits are kept; without any, the data is wiped', () async {
    await db.into(db.outbox).insert(OutboxCompanion.insert(id: 'o1', kind: OutboxKind.auditCreate, payloadJson: '{}', createdAt: DateTime.utc(2026, 10, 13)));
    final c = await open({});
    loginAs('u1');
    await c.read(sessionProvider.notifier).signIn('a', 'b');
    expect(wipes, 0, reason: 'unsent audit kept');

    await db.delete(db.outbox).go();
    final c2 = await open({});
    await c2.read(sessionProvider.notifier).signIn('a', 'b');
    expect(wipes, 1);
  });
}

/// The build's default API address (no server set by hand in these tests).
String c0Url() => const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');
