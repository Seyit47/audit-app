import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/sync/local_data.dart';
import '../../../core/sync/sync_providers.dart';

final signOutServiceProvider = Provider<SignOutService>((ref) => SignOutService(ref));

/// Sign-out (contracts/sync.md "Session end"): try to flush the outbox for up to 10 s, then wipe the
/// local store, photo files and the session. Theme and locale (shared preferences) are kept.
class SignOutService {
  SignOutService(this._ref);

  final Ref _ref;

  Future<void> signOut() async {
    try {
      await _ref.read(syncControllerProvider.notifier).syncNow().timeout(const Duration(seconds: 10));
    } catch (_) {
      // Offline or timed out: the data is lost by design only after this attempt (spec FR-015).
    }
    await _ref.read(wipeLocalDataProvider)();
    await _ref.read(sessionProvider.notifier).signOut();
  }
}
