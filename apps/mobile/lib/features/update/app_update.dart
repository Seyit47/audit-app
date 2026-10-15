import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/config/server_address.dart';

/// A published version of the app (`GET /v1/app/latest`: the admin's `latest.json` in the server's updates folder).
class AppUpdate {
  const AppUpdate({required this.version, required this.build, required this.url, required this.sizeBytes, this.notes = '', this.required = false});

  factory AppUpdate.fromJson(Map<String, dynamic> json) => AppUpdate(
    version: json['version'] as String,
    build: json['build'] as int,
    url: json['url'] as String,
    sizeBytes: json['sizeBytes'] as int,
    notes: json['notes'] as String? ?? '',
    required: json['required'] as bool? ?? false,
  );

  final String version;

  /// Compared with the installed build number (pubspec `+N`).
  final int build;

  /// Path on the API, e.g. `/v1/app/apk/audit-app-1.0.29.apk`.
  final String url;
  final int sizeBytes;
  final String notes;

  /// No "Later": the app can't be used until it is installed.
  final bool required;

  bool newerThan(int installedBuild) => build > installedBuild;
}

/// Checks, downloads and installs updates (Android only: iOS apps update through the App Store or MDM).
class UpdateService {
  UpdateService(this._apiUrl);

  final String Function() _apiUrl;
  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
  static const _installer = MethodChannel('audit/installer');

  /// The published update when it is newer than this app; null otherwise or when the server can't be reached.
  Future<AppUpdate?> check() async {
    if (!Platform.isAndroid) return null;
    try {
      final res = await _dio.get<Map<String, dynamic>>('${_apiUrl()}/v1/app/latest');
      final update = AppUpdate.fromJson(res.data!);
      final installed = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
      return update.newerThan(installed) ? update : null;
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK into the app's cache (reused when already complete) and returns its path.
  Future<String> download(AppUpdate update, {required void Function(double fraction) onProgress, CancelToken? cancel}) async {
    final dir = Directory(p.join((await getTemporaryDirectory()).path, 'updates'));
    await dir.create(recursive: true);
    final path = p.join(dir.path, 'audit-${update.build}.apk');
    final file = File(path);
    if (await file.exists() && await file.length() == update.sizeBytes) return path;
    // Older downloads are of no use any more.
    await for (final old in dir.list()) {
      if (old.path != path) await old.delete();
    }
    await _dio.download(
      '${_apiUrl()}${update.url}',
      path,
      cancelToken: cancel,
      onReceiveProgress: (received, total) => onProgress(received / (total > 0 ? total : update.sizeBytes)),
    );
    if (await file.length() != update.sizeBytes) {
      await file.delete();
      throw const FileSystemException('The download is incomplete');
    }
    return path;
  }

  /// Whether Android lets this app install APKs ("Install unknown apps"), asked once per phone.
  Future<bool> canInstall() async => await _installer.invokeMethod<bool>('canInstall') ?? false;

  Future<void> openInstallSettings() => _installer.invokeMethod<void>('openInstallSettings');

  /// Opens the system installer; the agent confirms there. Data on the phone is kept (same signing key).
  Future<void> install(String path) => _installer.invokeMethod<void>('install', {'path': path});
}

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService(() => ref.read(apiUrlProvider)));
