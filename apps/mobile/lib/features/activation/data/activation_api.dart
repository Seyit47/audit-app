import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_config.dart';

enum DeviceStatus { unregistered, pending, active }

/// This device's id for activation, in the activation server's format "SM-A528B-424d82d9": the phone model
/// and the first 8 characters of a stable device id: ANDROID_ID on Android (fixed per device, survives
/// reinstalls, resets on a factory reset), a Keychain id on iOS (survives reinstalls). Apps can't read the IMEI.
Future<String> deviceId() async {
  final info = DeviceInfoPlugin();
  final model = switch (Platform.operatingSystem) {
    'android' => (await info.androidInfo).model,
    'ios' => (await info.iosInfo).utsname.machine,
    final os => os,
  };
  return formatDeviceId(model, await FlutterUdid.udid);
}

/// "SM-A528B" + "424d82d9e5f6a7b8" → "SM-A528B-424d82d9"; an iOS UUID ("7946DA4E-8429-…") gives "…-7946da4e".
String formatDeviceId(String model, String udid) {
  final hex = udid.replaceAll('-', '').toLowerCase();
  return '${model.replaceAll(' ', '')}-${hex.substring(0, hex.length < 8 ? hex.length : 8)}';
}

/// The activation server (`AppConfig.activationUrl`).
class ActivationApi {
  ActivationApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.activationUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              contentType: Headers.jsonContentType,
            ),
          );

  final Dio _dio;

  /// 404: never registered; 200 with `is_active` false: waiting for a moderator; true: approved.
  Future<DeviceStatus> status(String id) async {
    final res = await _dio.get<dynamic>('/devices/status/${Uri.encodeComponent(id)}', options: Options(validateStatus: (s) => s == 200 || s == 404));
    if (res.statusCode == 404) return DeviceStatus.unregistered;
    final data = res.data;
    return data is Map && data['is_active'] == true ? DeviceStatus.active : DeviceStatus.pending;
  }

  /// Signs in with the app account, then registers the device with what identifies it to the moderator.
  Future<void> register(String id) async {
    final login = await _dio.post<Map<String, dynamic>>(
      '/app/login',
      data: {'username': AppConfig.activationUsername, 'password': AppConfig.activationPassword},
    );
    final token = login.data!['token'] as String;
    await _dio.post<dynamic>(
      '/devices/register',
      data: {'device_imei': id, ...await registrationDetails()},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}

/// Auto-filled registration fields: the phone model, the app version and the OS version.
Future<Map<String, String>> registrationDetails() async {
  final app = await PackageInfo.fromPlatform();
  final info = DeviceInfoPlugin();
  final (model, os) = switch (Platform.operatingSystem) {
    'android' => await info.androidInfo.then((a) => ('${a.manufacturer} ${a.model}', 'Android ${a.version.release} (SDK ${a.version.sdkInt})')),
    'ios' => await info.iosInfo.then((i) => (i.utsname.machine, '${i.systemName} ${i.systemVersion}')),
    _ => (Platform.operatingSystem, Platform.operatingSystemVersion),
  };
  return {'shop_name': model, 'description_main': '${app.appName} ${app.version} (${app.buildNumber})', 'description': os};
}
