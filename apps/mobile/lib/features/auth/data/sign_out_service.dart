import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/db/database_provider.dart';
import '../../../core/sync/background_sync.dart';
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
    await _wipeLocalData();
    await _ref.read(sessionProvider.notifier).signOut();
  }

  Future<void> _wipeLocalData() async {
    await cancelBackgroundSync().catchError((_) {});
    await _ref.read(databaseProvider).wipe();
    final photos = Directory('${(await getApplicationDocumentsDirectory()).path}/photos');
    if (await photos.exists()) await photos.delete(recursive: true);
  }
}
