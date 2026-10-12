import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/settings/app_settings.dart';
import 'data/activation_api.dart';

/// [unregistered]: the activation server doesn't know this device; it registers when the user taps Register.
/// [offline]: the activation server couldn't be reached and this device was never seen active.
enum Activation { checking, unregistered, registering, pending, active, offline }

/// Off when the build has no activation server (tests, local development).
final activationEnabledProvider = Provider<bool>((ref) => AppConfig.activationUrl.isNotEmpty);
final activationApiProvider = Provider<ActivationApi>((ref) => ActivationApi());

/// "samsung SM-A528B-96847ec2" (see [deviceId]).
final deviceIdProvider = FutureProvider<String>((ref) => deviceId());

const _activeKey = 'device_active';

/// Whether this device may use the app. The app checks its device id with the activation server on every
/// launch and whenever it returns to the foreground. An unknown device is registered (with the phone's
/// details) only when the user taps Register, so one a moderator deleted isn't silently added back; then the
/// app waits until a moderator activates it. A device seen active opens at once and stays usable offline
/// (agents start the day without a signal), but is locked again if the server says it isn't active.
final activationProvider = NotifierProvider<ActivationNotifier, Activation>(ActivationNotifier.new);

class ActivationNotifier extends Notifier<Activation> {
  bool get _wasActive => ref.read(sharedPreferencesProvider).getBool(_activeKey) ?? false;

  @override
  Activation build() {
    if (!ref.watch(activationEnabledProvider)) return Activation.active;
    // The app stays open all day: a device deactivated meanwhile is locked when it comes back to the foreground.
    final lifecycle = AppLifecycleListener(onResume: () => unawaited(check()));
    ref.onDispose(lifecycle.dispose);
    unawaited(Future.microtask(check));
    return _wasActive ? Activation.active : Activation.checking;
  }

  /// Registers this device (Register button), then checks it.
  Future<void> register() => check(register: true);

  /// [register]: only from the Register button; a launch or resume never registers by itself.
  Future<void> check({bool register = false}) async {
    if (!_wasActive) state = Activation.checking;
    try {
      final id = await ref.read(deviceIdProvider.future);
      final api = ref.read(activationApiProvider);
      var status = await api.status(id);
      if (status == DeviceStatus.unregistered) {
        if (!register) {
          await _remember(false);
          state = Activation.unregistered;
          return;
        }
        state = Activation.registering;
        await api.register(id);
        status = await api.status(id);
      }
      await _remember(status == DeviceStatus.active);
      state = status == DeviceStatus.active ? Activation.active : Activation.pending;
    } catch (_) {
      state = _wasActive ? Activation.active : Activation.offline;
    }
  }

  Future<void> _remember(bool active) async {
    final prefs = ref.read(sharedPreferencesProvider);
    active ? await prefs.setBool(_activeKey, true) : await prefs.remove(_activeKey);
  }
}
