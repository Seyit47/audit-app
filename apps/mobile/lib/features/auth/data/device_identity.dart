import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_udid/flutter_udid.dart';

/// The device id and model sent at sign-in for device binding (FR-002a). The id is the phone's own stable id
/// (ANDROID_ID on Android, a Keychain id on iOS): it survives sign-out, clearing the app's data and reinstalling,
/// so the same phone is always recognised and an agent isn't locked out by "bound to another device".
class DeviceIdentity {
  Future<Map<String, String>> read() async => {'installId': await FlutterUdid.udid, 'model': await _model()};

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
