import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/config/app_config.dart';

enum DeviceStatus { unregistered, pending, active }

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
  Future<DeviceStatus> status(String imei) async {
    final res = await _dio.get<dynamic>('/devices/status/$imei', options: Options(validateStatus: (s) => s == 200 || s == 404));
    if (res.statusCode == 404) return DeviceStatus.unregistered;
    final data = res.data;
    return data is Map && data['is_active'] == true ? DeviceStatus.active : DeviceStatus.pending;
  }

  /// Signs in with the app account, then registers the device with what identifies it to the moderator.
  Future<void> register(String imei) async {
    final login = await _dio.post<Map<String, dynamic>>(
      '/app/login',
      data: {'username': AppConfig.activationUsername, 'password': AppConfig.activationPassword},
    );
    final token = login.data!['token'] as String;
    await _dio.post<dynamic>(
      '/devices/register',
      data: {'device_imei': imei, ...await registrationDetails()},
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
