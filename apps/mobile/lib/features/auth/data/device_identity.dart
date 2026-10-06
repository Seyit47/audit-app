import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// The install id and model sent at sign-in for device binding (FR-002a). The id is created once
/// per install and survives sign-out.
class DeviceIdentity {
  DeviceIdentity([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _key = 'install_id';

  Future<Map<String, String>> read() async {
    var installId = await _storage.read(key: _key);
    if (installId == null) {
      installId = const Uuid().v4();
      await _storage.write(key: _key, value: installId);
    }
    return {'installId': installId, 'model': await _model()};
  }

  Future<String> _model() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      return '${a.manufacturer} ${a.model}';
    }
    if (Platform.isIOS) return (await info.iosInfo).utsname.machine;
    return Platform.operatingSystem;
  }
}
