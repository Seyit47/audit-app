import 'dart:async';

import 'package:flutter/widgets.dart';
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
/// shows it); the app then checks it with the activation server on every launch and whenever it returns to
/// the foreground. An unknown IMEI is registered with the phone's details only when the agent submits it, and
/// the app waits until a moderator activates it. A device seen active opens at once and stays usable offline
/// (agents start the day without a signal), but is locked again if the server says it isn't active; one the
/// server no longer knows (deleted by a moderator) goes back to the entry, its IMEI filled in.
final activationProvider = NotifierProvider<ActivationNotifier, Activation>(ActivationNotifier.new);

class ActivationNotifier extends Notifier<Activation> {
  bool get _wasActive => ref.read(sharedPreferencesProvider).getBool(_activeKey) ?? false;

  /// The IMEI entered on this install, or null.
  String? get imei => ref.read(sharedPreferencesProvider).getString(_imeiKey);

  @override
  Activation build() {
    if (!ref.watch(activationEnabledProvider)) return Activation.active;
    // The app stays open all day: a device deactivated meanwhile is locked when it comes back to the foreground.
    final lifecycle = AppLifecycleListener(onResume: () => unawaited(check()));
    ref.onDispose(lifecycle.dispose);
    if (imei == null) return Activation.needsImei;
    unawaited(Future.microtask(check));
    return _wasActive ? Activation.active : Activation.checking;
  }

  /// Saves the IMEI from the entry view, then checks it, registering it if the server doesn't know it.
  Future<void> submitImei(String value) async {
    await ref.read(sharedPreferencesProvider).setString(_imeiKey, value);
    await check(register: true);
  }

  /// Back to the entry view to fix a mistyped IMEI.
  Future<void> changeImei() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_imeiKey);
    await prefs.remove(_activeKey);
    state = Activation.needsImei;
  }

  /// [register]: only when the agent submitted the IMEI. A launch or resume never registers by itself, so a
  /// device a moderator deleted isn't silently added back.
  Future<void> check({bool register = false}) async {
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
        if (!register) {
          await _remember(false);
          state = Activation.needsImei;
          return;
        }
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
