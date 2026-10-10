import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/app_settings.dart';
import 'app_config.dart';

const _key = 'api_url';

/// The API address set on the login screen's server settings, or the build's `API_URL`.
String storedApiUrl(SharedPreferences prefs) => prefs.getString(_key) ?? AppConfig.apiUrl;

final apiUrlProvider = NotifierProvider<ApiUrlNotifier, String>(ApiUrlNotifier.new);

class ApiUrlNotifier extends Notifier<String> {
  @override
  String build() => storedApiUrl(ref.watch(sharedPreferencesProvider));

  Future<void> set(String url) async {
    await ref.read(sharedPreferencesProvider).setString(_key, url);
    state = url;
  }

  Future<void> reset() async {
    await ref.read(sharedPreferencesProvider).remove(_key);
    state = AppConfig.apiUrl;
  }
}

/// The parts the settings form edits: host (IP or domain), optional port, HTTPS or not.
class ServerAddress {
  const ServerAddress({required this.host, this.port, this.https = true});

  final String host;
  final int? port;
  final bool https;

  static ServerAddress parse(String url) {
    final uri = Uri.parse(url);
    return ServerAddress(host: uri.host, port: uri.hasPort ? uri.port : null, https: uri.scheme == 'https');
  }

  String get url => Uri(scheme: https ? 'https' : 'http', host: host, port: port).toString();
}

final _ipv4 = RegExp(r'^(25[0-5]|2[0-4]\d|1?\d?\d)(\.(25[0-5]|2[0-4]\d|1?\d?\d)){3}$');
final _domain = RegExp(r'^(localhost|([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,})$', caseSensitive: false);

bool isValidHost(String host) => _ipv4.hasMatch(host) || _domain.hasMatch(host);

bool isValidPort(String port) {
  final n = int.tryParse(port);
  return n != null && n >= 1 && n <= 65535;
}

/// Whether the audit API answers at [url]: its `/health` replies 200, or 503 when degraded but up.
Future<bool> apiReachable(String url, {Dio? dio}) async {
  final client = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 8)));
  try {
    final res = await client.get<dynamic>('$url/health', options: Options(validateStatus: (_) => true));
    return (res.statusCode == 200 || res.statusCode == 503) && res.data is Map && (res.data as Map).containsKey('status');
  } on DioException {
    return false;
  }
}
