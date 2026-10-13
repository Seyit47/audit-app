import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/server_address.dart';
import '../db/database_provider.dart';
import '../settings/app_settings.dart';
import '../sync/local_data.dart';
import '../sync/outbox_repository.dart';
import '../network/api_client.dart';
import 'session.dart';
import 'session_store.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

/// Whose data the local database holds: `<user id>@<API address>`.
const _dataOwnerKey = 'data_owner';

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    tokens: ref.watch(sessionStoreProvider),
    onSessionExpired: () => ref.read(sessionProvider.notifier).expire(),
    baseUrl: ref.watch(apiUrlProvider),
  ),
);

/// The signed-in user, or null. Loaded from secure storage at startup.
final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionUser?>(SessionNotifier.new);

class SessionNotifier extends AsyncNotifier<SessionUser?> {
  @override
  Future<SessionUser?> build() async {
    final store = ref.watch(sessionStoreProvider);
    return await store.readTokens() == null ? null : store.readUser();
  }

  /// Signs in. Agents must send their device (`installId`, `model`) for device binding.
  Future<void> signIn(String login, String password, {Map<String, String>? device}) async {
    final api = ref.read(apiClientProvider);
    final body = await api.post<Map<String, dynamic>>('/auth/login', body: {'login': login, 'password': password, 'device': ?device}, auth: false);
    final store = ref.read(sessionStoreProvider);
    final user = SessionUser.fromJson(body['user'] as Map<String, dynamic>);
    // The local data belongs to one user on one server: a different user, or the same phone pointed at another
    // server, starts clean instead of showing the previous one's shops, audits and photos.
    // With no owner recorded (data from before this check), unsent audits are kept rather than risked: they can
    // only belong to the user signing in again after their session expired.
    final prefs = ref.read(sharedPreferencesProvider);
    final owner = '${user.id}@${ref.read(apiUrlProvider)}';
    final previous = prefs.getString(_dataOwnerKey);
    if (previous != owner) {
      final db = ref.read(databaseProvider);
      final unsent = previous == null ? await OutboxRepository(db).openCount() : 0;
      if (unsent == 0) await ref.read(wipeLocalDataProvider)();
      await prefs.setString(_dataOwnerKey, owner);
    }
    await store.writeTokens(Tokens(access: body['accessToken'] as String, refresh: body['refreshToken'] as String));
    await store.writeUser(user);
    state = AsyncData(user);
  }

  /// Ends the session locally. Callers flush the outbox and wipe local data first (sync.md).
  Future<void> signOut() async {
    final store = ref.read(sessionStoreProvider);
    final tokens = await store.readTokens();
    if (tokens != null) {
      try {
        await ref.read(apiClientProvider).post<void>('/auth/logout', body: {'refreshToken': tokens.refresh});
      } catch (_) {}
    }
    await store.clear();
    state = const AsyncData(null);
  }

  void expire() {
    ref.read(sessionStoreProvider).clear();
    state = const AsyncData(null);
  }
}
