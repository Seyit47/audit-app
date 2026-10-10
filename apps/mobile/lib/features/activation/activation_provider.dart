import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/settings/app_settings.dart';
import 'data/activation_api.dart';

/// [needsImei]: no IMEI entered yet on this install. [offline]: the activation server couldn't be reached and
/// this device was never seen active.
enum Activation { checking, needsImei, registering, pending, active, offline }

/// Off when the build has no activation server (tests, local development).
final activationEnabledProvider = Provider<bool>((ref) => AppConfig.activationUrl.isNotEmpty);
final activationApiProvider = Provider<ActivationApi>((ref) => ActivationApi());

const _imeiKey = 'device_imei';
const _activeKey = 'device_active';

/// Whether this device may use the app. Apps can't read the IMEI, so the agent enters it once (dialing *#06#
/// shows it); every launch then checks it with the activation server. An unknown IMEI is registered with
/// the phone's details, and the app waits until a moderator activates it. A device seen active opens at
/// once and stays usable offline (agents start the day without a signal), but is locked again if the
/// server later says it isn't active.
final activationProvider = NotifierProvider<ActivationNotifier, Activation>(ActivationNotifier.new);

class ActivationNotifier extends Notifier<Activation> {
  bool get _wasActive => ref.read(sharedPreferencesProvider).getBool(_activeKey) ?? false;

  /// The IMEI entered on this install, or null.
  String? get imei => ref.read(sharedPreferencesProvider).getString(_imeiKey);

  @override
  Activation build() {
    if (!ref.watch(activationEnabledProvider)) return Activation.active;
    if (imei == null) return Activation.needsImei;
    unawaited(Future.microtask(check));
    return _wasActive ? Activation.active : Activation.checking;
  }

  /// Saves the IMEI from the entry view, then registers or checks it.
  Future<void> submitImei(String value) async {
    await ref.read(sharedPreferencesProvider).setString(_imeiKey, value);
    await check();
  }

  /// Back to the entry view to fix a mistyped IMEI.
  Future<void> changeImei() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_imeiKey);
    await prefs.remove(_activeKey);
    state = Activation.needsImei;
  }

  Future<void> check() async {
    final imei = this.imei;
    if (imei == null) {
      state = Activation.needsImei;
      return;
    }
    if (!_wasActive) state = Activation.checking;
    try {
      final api = ref.read(activationApiProvider);
      var status = await api.status(imei);
      if (status == DeviceStatus.unregistered) {
        state = Activation.registering;
        await api.register(imei);
        status = await api.status(imei);
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
