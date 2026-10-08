import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import 'session.dart';
import 'session_store.dart';

final sessionStoreProvider = Provider<SessionStore>((ref) => SessionStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokens: ref.watch(sessionStoreProvider), onSessionExpired: () => ref.read(sessionProvider.notifier).expire()),
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
