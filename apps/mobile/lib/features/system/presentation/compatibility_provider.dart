import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../data/system_repository.dart';
import '../domain/compatibility.dart';

final compatibilityProvider =
    AsyncNotifierProvider<CompatibilityNotifier, Compatibility>(
      CompatibilityNotifier.new,
    );

/// Checks once at startup whether the backend is reachable and supports this app version.
class CompatibilityNotifier extends AsyncNotifier<Compatibility> {
  @override
  Future<Compatibility> build() => _check();

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_check);
  }

  Future<Compatibility> _check() async {
    try {
      final info = await ref.read(systemRepositoryProvider).getVersion();
      final appVersion = await ref.read(appVersionProvider.future);
      return evaluateCompatibility(appVersion, info);
    } on ApiException catch (error) {
      if (error.statusCode == 426) return const UpdateRequired();
      return const Unreachable();
    }
  }
}
