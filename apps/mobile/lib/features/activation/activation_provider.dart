import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/settings/app_settings.dart';
import 'data/activation_api.dart';

/// [offline]: the activation server couldn't be reached and this device was never seen active.
enum Activation { checking, unregistered, registering, pending, active, offline }

/// Off when the build has no activation server (tests, local development).
final activationEnabledProvider = Provider<bool>((ref) => AppConfig.activationUrl.isNotEmpty);
final activationApiProvider = Provider<ActivationApi>((ref) => ActivationApi());
final deviceIdProvider = FutureProvider<String>((ref) => deviceId());

const _activeKey = 'device_active';

/// Whether this device may use the app. Checked with the activation server on every launch. A device seen
/// active opens at once and stays usable offline (agents start the day without a signal), but is locked
/// again if the server later says it isn't active.
final activationProvider = NotifierProvider<ActivationNotifier, Activation>(ActivationNotifier.new);

class ActivationNotifier extends Notifier<Activation> {
  bool get _wasActive => ref.read(sharedPreferencesProvider).getBool(_activeKey) ?? false;

  @override
  Activation build() {
    if (!ref.watch(activationEnabledProvider)) return Activation.active;
    unawaited(Future.microtask(check));
    return _wasActive ? Activation.active : Activation.checking;
  }

  Future<void> check() async {
    if (!_wasActive) state = Activation.checking;
    try {
      final id = await ref.read(deviceIdProvider.future);
      final status = await ref.read(activationApiProvider).status(id);
      await _remember(status == DeviceStatus.active);
      state = switch (status) {
        DeviceStatus.unregistered => Activation.unregistered,
        DeviceStatus.pending => Activation.pending,
        DeviceStatus.active => Activation.active,
      };
    } catch (_) {
      state = _wasActive ? Activation.active : Activation.offline;
    }
  }

  /// Registers this device (auto-filled details), then shows the waiting state.
  Future<void> register() async {
    state = Activation.registering;
    try {
      await ref.read(activationApiProvider).register(await ref.read(deviceIdProvider.future));
    } catch (_) {
      state = Activation.offline;
      return;
    }
    await check();
  }

  Future<void> _remember(bool active) async {
    final prefs = ref.read(sharedPreferencesProvider);
    active ? await prefs.setBool(_activeKey, true) : await prefs.remove(_activeKey);
  }
}
