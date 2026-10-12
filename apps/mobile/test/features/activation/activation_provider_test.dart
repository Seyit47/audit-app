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

const id = 'samsung SM-A528B-96847ec2';

void main() {
  // The notifier listens for the app returning to the foreground.
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Api api;

  Future<ProviderContainer> open(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance()),
        activationEnabledProvider.overrideWithValue(true),
        activationApiProvider.overrideWithValue(api),
        deviceIdProvider.overrideWith((ref) async => id),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  // The launch check runs in a microtask after the provider is first read; settle lets it finish.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  setUp(() => api = _Api());

  test('an unknown device waits for Register, then for a moderator; activation opens the app', () async {
    final c = await open({});
    expect(c.read(activationProvider), Activation.checking);
    await settle();
    expect(c.read(activationProvider), Activation.unregistered);
    expect(api.registered, isEmpty, reason: 'a launch never registers by itself');

    await c.read(activationProvider.notifier).register();
    expect(api.registered, [id]);
    expect(c.read(activationProvider), Activation.pending);

    api.status_ = DeviceStatus.active;
    await c.read(activationProvider.notifier).check();
    expect(c.read(activationProvider), Activation.active);
    expect((await SharedPreferences.getInstance()).getBool('device_active'), isTrue);
  });

  test('a device already registered is not registered again', () async {
    api.status_ = DeviceStatus.pending;
    final c = await open({});
    await c.read(activationProvider.notifier).register();
    expect(api.registered, isEmpty);
    expect(c.read(activationProvider), Activation.pending);
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

  test('deleted by the moderator: back to Register, without registering it again', () async {
    final c = await open({'device_active': true});
    c.read(activationProvider);
    await settle();
    expect(c.read(activationProvider), Activation.unregistered);
    expect(api.registered, isEmpty);
  });
}
