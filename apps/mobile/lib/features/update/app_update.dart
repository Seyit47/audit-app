import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

enum UpdateCheckStatus { available, upToDate, unreachable }

/// What a check found: the newer update, or why there is none.
class UpdateCheck {
  const UpdateCheck(this.status, [this.update]);

  final UpdateCheckStatus status;
  final AppUpdate? update;
}

/// The installed version, e.g. ("1.0.30", 31).
final appVersionProvider = FutureProvider<(String, int)>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return (info.version, int.tryParse(info.buildNumber) ?? 0);
});

/// The Android name of this phone's CPU type, as the split APKs are named: the server then hands out the
/// smaller APK built for it.
String? androidAbi(Abi abi) => switch (abi) {
  Abi.androidArm64 => 'arm64-v8a',
  Abi.androidArm => 'armeabi-v7a',
  Abi.androidX64 => 'x86_64',
  Abi.androidIA32 => 'x86',
  _ => null,
};

/// Checks, downloads and installs updates (Android only: iOS apps update through the App Store or MDM).
class UpdateService {
  UpdateService(this._apiUrl, {Dio? dio, Future<Directory> Function()? cacheDir})
    : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15))),
      _cacheDir = cacheDir ?? getTemporaryDirectory;

  final String Function() _apiUrl;
  final Dio _dio;
  final Future<Directory> Function() _cacheDir;
  static const _installer = MethodChannel('audit/installer');

  /// The published update when it is newer than this app; null otherwise or when the server can't be reached.
  Future<AppUpdate?> check() async => (await checkNow()).update;

  /// Like [check], telling "up to date" (nothing newer, or nothing published) from "server unreachable".
  Future<UpdateCheck> checkNow() async {
    if (!Platform.isAndroid) return const UpdateCheck(UpdateCheckStatus.upToDate);
    try {
      final res = await _dio.get<Map<String, dynamic>>('${_apiUrl()}/v1/app/latest', queryParameters: {'abi': ?androidAbi(Abi.current())});
      final update = AppUpdate.fromJson(res.data!);
      final installed = int.tryParse((await PackageInfo.fromPlatform()).buildNumber) ?? 0;
      return update.newerThan(installed) ? UpdateCheck(UpdateCheckStatus.available, update) : const UpdateCheck(UpdateCheckStatus.upToDate);
    } on DioException catch (e) {
      // 404: nothing published yet.
      return UpdateCheck(e.response?.statusCode == 404 ? UpdateCheckStatus.upToDate : UpdateCheckStatus.unreachable);
    } catch (_) {
      return const UpdateCheck(UpdateCheckStatus.unreachable);
    }
  }

  /// Downloads the APK into the app's cache (kept when already complete) and returns its path.
  ///
  /// In [piece]-sized ranges, each on a new connection and retried a few times: the server's network cuts
  /// a connection ~2 MB into an APK, and a weak mobile signal drops some. A part left by an interrupted
  /// download is continued, not started over.
  Future<String> download(AppUpdate update, {required void Function(double fraction) onProgress, CancelToken? cancel}) async {
    final dir = Directory(p.join((await _cacheDir()).path, 'updates'));
    await dir.create(recursive: true);
    final path = p.join(dir.path, 'audit-${update.build}.apk');
    final file = File(path);
    // Older downloads are of no use any more.
    await for (final old in dir.list()) {
      if (old.path != path) await old.delete();
    }
    var done = await file.exists() ? await file.length() : 0;
    if (done > update.sizeBytes) {
      await file.delete();
      done = 0;
    }
    final out = file.openSync(mode: FileMode.append);
    try {
      while (done < update.sizeBytes) {
        final end = (done + piece < update.sizeBytes ? done + piece : update.sizeBytes) - 1;
        final bytes = await _piece(update.url, done, end, cancel);
        out.writeFromSync(bytes);
        done += bytes.length;
        onProgress(done / update.sizeBytes);
      }
    } finally {
      out.closeSync();
    }
    return path;
  }

  /// 1 MB: well under where the server's network cuts a connection.
  static const piece = 1024 * 1024;

  /// Wait before retrying a piece (times the attempt); tests shorten it.
  @visibleForTesting
  static Duration retryDelay = const Duration(seconds: 1);

  Future<List<int>> _piece(String url, int start, int end, CancelToken? cancel) async {
    for (var attempt = 1; ; attempt++) {
      try {
        final res = await _dio.get<List<int>>(
          '${_apiUrl()}$url',
          cancelToken: cancel,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Range': 'bytes=$start-$end', 'Connection': 'close'},
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        final bytes = res.data ?? const [];
        // 206 with the asked range; a server without ranges (200) would resend the whole file.
        if (res.statusCode != 206 || bytes.length != end - start + 1) throw const FileSystemException('Unexpected download range');
        return bytes;
      } on DioException catch (e) {
        if (CancelToken.isCancel(e) || attempt >= 4) rethrow;
        await Future<void>.delayed(retryDelay * attempt);
      }
    }
  }

  /// Whether Android lets this app install APKs ("Install unknown apps"), asked once per phone.
  Future<bool> canInstall() async => await _installer.invokeMethod<bool>('canInstall') ?? false;

  Future<void> openInstallSettings() => _installer.invokeMethod<void>('openInstallSettings');

  /// Opens the system installer; the agent confirms there. Data on the phone is kept (same signing key).
  Future<void> install(String path) => _installer.invokeMethod<void>('install', {'path': path});
}

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService(() => ref.read(apiUrlProvider)));
