import 'package:audit_mobile/core/settings/app_settings.dart';
import 'package:audit_mobile/features/activation/activation_provider.dart';
import 'package:audit_mobile/features/activation/data/activation_api.dart';
import 'package:audit_mobile/features/activation/domain/imei.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Api implements ActivationApi {
  DeviceStatus? status_ = DeviceStatus.unregistered; // null: the server can't be reached
  final registered = <String>[];

  @override
  Future<DeviceStatus> status(String imei) async => status_ ?? (throw Exception('offline'));

  @override
  Future<void> register(String imei) async {
    registered.add(imei);
    status_ = DeviceStatus.pending;
  }
}

const imei = '356938035643809';

void main() {
  late _Api api;

  Future<ProviderContainer> open(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        activationEnabledProvider.overrideWithValue(true),
        activationApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // The launch check runs in a microtask after the provider is first read; settle lets it finish.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() => api = _Api());

  test('IMEI validation catches wrong lengths and typos', () {
    expect(isValidImei(imei), isTrue);
    expect(isValidImei('356938035643808'), isFalse, reason: 'check digit');
    expect(isValidImei('35693803564380'), isFalse);
    expect(formatImei(imei), '35 693803 564380 9');
  });

  test('first launch asks for the IMEI, registers it, then waits; activation opens the app', () async {
    final c = await open({});
    expect(c.read(activationProvider), Activation.needsImei);

    await c.read(activationProvider.notifier).submitImei(imei);
    expect(api.registered, [imei]);
    expect(c.read(activationProvider), Activation.pending);

    api.status_ = DeviceStatus.active;
    await c.read(activationProvider.notifier).check();
    expect(c.read(activationProvider), Activation.active);
    expect((await SharedPreferences.getInstance()).getBool('device_active'), isTrue);
  });

  test('a known IMEI is not registered again', () async {
    api.status_ = DeviceStatus.pending;
    final c = await open({});
    await c.read(activationProvider.notifier).submitImei(imei);
    expect(api.registered, isEmpty);
    expect(c.read(activationProvider), Activation.pending);
  });

  test('a device seen active opens at once and stays usable offline', () async {
    api.status_ = null;
    final c = await open({'device_imei': imei, 'device_active': true});
    expect(c.read(activationProvider), Activation.active);
    await settle();
    expect(c.read(activationProvider), Activation.active);
  });

  test('never activated and offline: blocked with a retry', () async {
    api.status_ = null;
    final c = await open({'device_imei': imei});
    c.read(activationProvider);
    await settle();
    expect(c.read(activationProvider), Activation.offline);
  });

  test('deactivated by the moderator: locked again; Change IMEI goes back to the entry', () async {
    api.status_ = DeviceStatus.pending;
    final c = await open({'device_imei': imei, 'device_active': true});
    c.read(activationProvider);
    await settle();
    expect(c.read(activationProvider), Activation.pending);
    expect((await SharedPreferences.getInstance()).getBool('device_active'), isNull);

    await c.read(activationProvider.notifier).changeImei();
    expect(c.read(activationProvider), Activation.needsImei);
    expect((await SharedPreferences.getInstance()).getString('device_imei'), isNull);
  });
}
