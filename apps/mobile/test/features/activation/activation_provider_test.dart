import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/features/activation/activation_provider.dart';
import 'package:audit_mobile/features/activation/data/activation_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Api implements ActivationApi {
  DeviceStatus? status_ = DeviceStatus.unregistered; // null: the server can't be reached
  final registered = <String>[];

  @override
  Future<DeviceStatus> status(String id) async => status_ ?? (throw Exception('offline'));

  @override
  Future<void> register(String id) async {
    registered.add(id);
    status_ = DeviceStatus.pending;
  }
}

void main() {
  late _Api api;

  Future<ProviderContainer> open(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        activationEnabledProvider.overrideWithValue(true),
        activationApiProvider.overrideWithValue(api),
        deviceIdProvider.overrideWith((ref) async => 'dev-1'),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // The check runs in a microtask after the provider is first read; settle lets it finish.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() => api = _Api());

  test('unknown device: register, then wait; activated: open and remember it', () async {
    final c = await open({});
    expect(c.read(activationProvider), Activation.checking);
    await settle();
    expect(c.read(activationProvider), Activation.unregistered);

    await c.read(activationProvider.notifier).register();
    expect(api.registered, ['dev-1']);
    expect(c.read(activationProvider), Activation.pending);

    api.status_ = DeviceStatus.active;
    await c.read(activationProvider.notifier).check();
    expect(c.read(activationProvider), Activation.active);
    expect((await SharedPreferences.getInstance()).getBool('device_active'), isTrue);
  });

  test('a device seen active opens at once and stays usable offline', () async {
    api.status_ = null;
    final c = await open({'device_active': true});
    expect(c.read(activationProvider), Activation.active);
    await settle();
    expect(c.read(activationProvider), Activation.active);
  });

  test('never activated and offline: blocked with a retry', () async {
    api.status_ = null;
    final c = await open({});
    c.read(activationProvider);
    await settle();
    expect(c.read(activationProvider), Activation.offline);
  });

  test('deactivated by the moderator: locked again', () async {
    api.status_ = DeviceStatus.pending;
    final c = await open({'device_active': true});
    c.read(activationProvider);
    await settle();
    expect(c.read(activationProvider), Activation.pending);
    expect((await SharedPreferences.getInstance()).getBool('device_active'), isNull);
  });
}
