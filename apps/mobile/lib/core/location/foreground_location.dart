import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../auth/session_provider.dart';
import '../router/app_router.dart';
import 'location_hub.dart';

/// Keeps the GPS receiver on while an agent has the app in the foreground, so a shop screen, the map or
/// the audit check opens on a position that is already there. A receiver that was off needs 30–60 s in the
/// open to find the satellites (longer indoors, and without Google's assistance data), and that wait used to
/// start only when a screen first asked. In the background the tracker holds the receiver during working
/// hours; outside them it goes off.
final foregroundLocationProvider = Provider<void>((ref) {
  final hub = ref.watch(locationHubProvider);
  var held = false;
  var foreground = true;
  void sync() {
    final want = foreground && ref.read(locationGrantedProvider) && ref.read(sessionProvider).value?.role == Role.agent;
    if (want && !held) {
      hub.acquire();
      held = true;
    } else if (!want && held) {
      hub.release();
      held = false;
    }
  }

  final lifecycle = AppLifecycleListener(
    onResume: () {
      foreground = true;
      sync();
    },
    onPause: () {
      foreground = false;
      sync();
    },
  );
  ref.listen(sessionProvider, (_, _) => sync());
  ref.listen(locationGrantedProvider, (_, _) => sync());
  ref.onDispose(() {
    lifecycle.dispose();
    if (held) hub.release();
  });
  sync();
});
