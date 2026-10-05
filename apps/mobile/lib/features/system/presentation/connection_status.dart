import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/status_banner.dart';
import '../domain/compatibility.dart';
import 'compatibility_provider.dart';

/// Shows the live backend connection state; used by the app shells.
class ConnectionStatus extends ConsumerWidget {
  const ConnectionStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compatibility = ref.watch(compatibilityProvider);
    return switch (compatibility.value) {
      _ when compatibility.isLoading => const StatusBanner.checking(),
      Compatible(:final info) => StatusBanner.connected(
        version: info.serverVersion,
      ),
      _ => StatusBanner.unreachable(
        onRetry: () => ref.read(compatibilityProvider.notifier).retry(),
      ),
    };
  }
}
