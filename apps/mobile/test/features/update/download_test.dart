import 'dart:io';
import 'dart:typed_data';

import 'package:audit_mobile/features/update/app_update.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves [apk] in ranges like the API, and drops the connection the first time [failAt] is asked for.
class _Server implements HttpClientAdapter {
  _Server(this.apk, {this.failAt});

  final Uint8List apk;
  final int? failAt;
  final asked = <String>[];
  var _failed = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final range = options.headers['Range'] as String;
    asked.add(range);
    final m = RegExp(r'bytes=(\d+)-(\d+)').firstMatch(range)!;
    final start = int.parse(m[1]!);
    final end = int.parse(m[2]!);
    if (start == failAt && !_failed) {
      _failed = true;
      throw DioException.connectionError(requestOptions: options, reason: 'Connection reset by peer');
    }
    return ResponseBody.fromBytes(
      apk.sublist(start, end + 1),
      206,
      headers: {
        'content-type': ['application/octet-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory cache;
  const piece = UpdateService.piece;
  final apk = Uint8List.fromList([for (var i = 0; i < piece * 2 + 1234; i++) i % 251]);
  final update = AppUpdate(version: '1.0.32', build: 33, url: '/v1/app/apk/a.apk', sizeBytes: apk.length);

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('updates-test');
    UpdateService.retryDelay = Duration.zero;
  });
  tearDown(() => cache.delete(recursive: true));

  UpdateService service(_Server server) => UpdateService(() => 'http://server', dio: Dio()..httpClientAdapter = server, cacheDir: () async => cache);

  test('downloads in 1 MB pieces, retries a dropped one, and ends with the exact file', () async {
    final server = _Server(apk, failAt: piece);
    final progress = <double>[];
    final path = await service(server).download(update, onProgress: progress.add);
    expect(await File(path).readAsBytes(), apk);
    expect(server.asked, ['bytes=0-${piece - 1}', 'bytes=$piece-${piece * 2 - 1}', 'bytes=$piece-${piece * 2 - 1}', 'bytes=${piece * 2}-${apk.length - 1}']);
    expect(progress.last, 1.0);
  });

  test('an interrupted download continues where it stopped', () async {
    final part = File('${cache.path}/updates/audit-33.apk');
    await part.create(recursive: true);
    await part.writeAsBytes(apk.sublist(0, piece));
    final server = _Server(apk);
    final path = await service(server).download(update, onProgress: (_) {});
    expect(await File(path).readAsBytes(), apk);
    expect(server.asked.first, 'bytes=$piece-${piece * 2 - 1}');
  });
}
