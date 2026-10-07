import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';

/// Where to PUT a photo. `ready` means the server already has it (a repeated upload).
class UploadTarget {
  const UploadTarget({required this.ready, this.url, this.headers = const {}});

  final bool ready;
  final String? url;
  final Map<String, String> headers;
}

class ShopRecord {
  const ShopRecord({required this.json});

  final Map<String, Object?> json;
}

class ShopsPage {
  const ShopsPage({required this.items, required this.tombstones, required this.cursor});

  final List<ShopRecord> items;
  /// Ids of shops deleted or no longer assigned to this agent.
  final List<String> tombstones;
  final String? cursor;
}

/// The endpoints the sync engine uses (contracts/sync.md). Every create is idempotent by id.
abstract interface class SyncApi {
  Future<UploadTarget> createUpload(Map<String, Object?> body);
  Future<void> putFile(UploadTarget target, String path, String mime);
  Future<void> completeUpload(String id);
  Future<void> createShop(Map<String, Object?> body);
  Future<void> createAudit(Map<String, Object?> body);
  Future<void> sendPings(List<Map<String, Object?>> pings);
  Future<ShopsPage> shops({String? updatedAfter});
  /// `{id, date, updatedAt, stops: [...]}`; `id` is null when there is no route today.
  Future<Map<String, Object?>> routeToday();
  /// The user, agent profile and the company settings subset (`GET /me`).
  Future<Map<String, Object?>> me();
  /// The agent's own photos, newest first (the server scopes `/photos` to them).
  Future<List<Map<String, Object?>>> myPhotos();
}

class HttpSyncApi implements SyncApi {
  HttpSyncApi(this._api);

  final ApiClient _api;
  // Presigned storage URLs must not get the API's bearer token.
  final _storage = Dio();

  @override
  Future<UploadTarget> createUpload(Map<String, Object?> body) async {
    final res = await _api.post<Map<String, dynamic>>('/uploads', body: body);
    return UploadTarget(
      ready: res['status'] == 'READY',
      url: res['uploadUrl'] as String?,
      headers: (res['headers'] as Map?)?.cast<String, String>() ?? const {},
    );
  }

  @override
  Future<void> putFile(UploadTarget target, String path, String mime) async {
    final file = File(path);
    try {
      await _storage.put<void>(
        target.url!,
        data: file.openRead(),
        options: Options(headers: {...target.headers, Headers.contentLengthHeader: await file.length(), Headers.contentTypeHeader: mime}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  @override
  Future<void> completeUpload(String id) => _api.post<void>('/uploads/$id/complete');

  @override
  Future<void> createShop(Map<String, Object?> body) => _api.post<void>('/shops', body: body);

  @override
  Future<void> createAudit(Map<String, Object?> body) => _api.post<void>('/audits', body: body);

  @override
  Future<void> sendPings(List<Map<String, Object?>> pings) => _api.post<void>('/tracking/pings', body: {'pings': pings});

  @override
  Future<ShopsPage> shops({String? updatedAfter}) async {
    final res = await _api.get<Map<String, dynamic>>('/shops', query: {'updatedAfter': ?updatedAfter});
    return ShopsPage(
      items: [for (final item in res['items'] as List) ShopRecord(json: (item as Map).cast<String, Object?>())],
      tombstones: [for (final id in res['tombstones'] as List? ?? const []) id as String],
      cursor: res['cursor'] as String?,
    );
  }

  @override
  Future<Map<String, Object?>> me() async => (await _api.get<Map<String, dynamic>>('/me')).cast<String, Object?>();

  @override
  Future<Map<String, Object?>> routeToday() async => (await _api.get<Map<String, dynamic>>('/routes/today')).cast<String, Object?>();

  @override
  Future<List<Map<String, Object?>>> myPhotos() async {
    final res = await _api.get<Map<String, dynamic>>('/photos', query: {'limit': 50});
    return [for (final item in res['items'] as List) (item as Map).cast<String, Object?>()];
  }
}
