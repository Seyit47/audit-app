import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sync/sync_api.dart';
import '../../../core/sync/sync_providers.dart';

typedef Json = Map<String, dynamic>;

/// A page of `GET` list results (`{items, total, page, size}`).
class PageOf {
  const PageOf(this.items, this.total);

  final List<Json> items;
  final int total;
}

/// The admin role's API calls (online: the admin app reads the server, contracts/screens.md).
class AdminApi {
  AdminApi(this._api, this._uploads);

  final ApiClient _api;
  final SyncApi _uploads;

  Future<PageOf> _page(String path, Map<String, dynamic> query) async {
    final res = await _api.get<Json>(path, query: {for (final e in query.entries) if (e.value != null && e.value != '') e.key: e.value});
    return PageOf([for (final i in res['items'] as List) (i as Map).cast<String, dynamic>()], (res['total'] as int?) ?? (res['items'] as List).length);
  }

  Future<PageOf> shops({int page = 1, String? q, String? status, String? regionId, String dir = 'asc'}) =>
      _page('/shops', {'page': page, 'size': 20, 'q': q, 'status': status, 'regionId': regionId, 'sort': 'name', 'dir': dir});
  Future<Json> shop(String id) => _api.get<Json>('/shops/$id');
  Future<List<Json>> shopVisits(String id, {int limit = 10}) async =>
      [for (final i in (await _api.get<Json>('/shops/$id/visits', query: {'limit': limit}))['items'] as List) (i as Map).cast<String, dynamic>()];
  Future<Json> createShop(Json body) => _api.post<Json>('/shops', body: body);
  Future<Json> updateShop(String id, Json body) => _api.patch<Json>('/shops/$id', body: body);
  Future<void> setContacts(String id, List<Json> contacts) => _api.put<void>('/shops/$id/contacts', body: {'contacts': contacts});

  Future<PageOf> agents({int page = 1, String? q, String? status, String? regionId}) =>
      _page('/agents', {'page': page, 'size': 50, 'q': q, 'status': status, 'regionId': regionId, 'sort': 'fullName', 'dir': 'asc'});
  Future<Json> agentsSummary() => _api.get<Json>('/agents/summary');
  Future<Json> agent(String id) => _api.get<Json>('/agents/$id');
  Future<List<Json>> timeline(String id) async => [for (final i in await _api.get<List<dynamic>>('/agents/$id/timeline')) (i as Map).cast<String, dynamic>()];
  Future<Json> track(String id) => _api.get<Json>('/agents/$id/track');
  Future<Json> agentVisits(String id) => _api.get<Json>('/agents/$id/visits', query: {'limit': 10});
  Future<String> nextAgentCode() async => (await _api.get<Json>('/agents/next-code'))['code'] as String;
  Future<Json> createAgent(Json body) => _api.post<Json>('/agents', body: body);
  Future<List<Json>> positions() async => [for (final i in await _api.get<List<dynamic>>('/agents/positions')) (i as Map).cast<String, dynamic>()];

  Future<List<Json>> regions() async => [for (final i in await _api.get<List<dynamic>>('/regions')) (i as Map).cast<String, dynamic>()];
  Future<List<Json>> mapShops({List<String>? agentIds, List<String>? regionIds}) async =>
      [for (final i in await _api.get<List<dynamic>>('/shops/map', query: {'agentIds': ?agentIds, 'regionIds': ?regionIds})) (i as Map).cast<String, dynamic>()];

  Future<Json> photos({String? shopId, String? agentId, String? from, String? cursor, int limit = 40, bool groups = false}) =>
      _api.get<Json>('/photos', query: {'shopId': ?shopId, 'agentId': ?agentId, 'from': ?from, 'cursor': ?cursor, 'limit': limit, if (groups) 'groups': true});
  Future<Json> photo(String id) => _api.get<Json>('/photos/$id');
  Future<Json> photoSummary() => _api.get<Json>('/photos/summary');

  Future<PageOf> products({int page = 1, String? q}) => _page('/products', {'page': page, 'size': 50, 'q': q});
  Future<List<Json>> productCategories() async => [for (final i in await _api.get<List<dynamic>>('/product-categories')) (i as Map).cast<String, dynamic>()];
  Future<Json> createProduct(Json body) => _api.post<Json>('/products', body: body);

  Future<String> exportReport(String agentId, String type) async {
    var job = await _api.post<Json>('/exports', body: {'type': type, 'params': {'agentId': agentId}});
    for (var i = 0; i < 60 && (job['status'] == 'QUEUED' || job['status'] == 'RUNNING'); i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      job = await _api.get<Json>('/exports/${job['id']}');
    }
    final url = job['url'] as String?;
    if (url == null) throw StateError('Export failed');
    return url;
  }

  /// Presign → PUT → complete, straight away (admins are online). Returns the photo id.
  Future<String> upload(File file, String kind, {String? shopId}) async {
    final id = const Uuid().v7();
    final bytes = await file.readAsBytes();
    final mime = file.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
    final target = await _uploads.createUpload({
      'id': id, 'kind': kind, 'mime': mime, 'sizeBytes': bytes.length, 'sha256': sha256.convert(bytes).toString(),
      'takenAt': DateTime.now().toUtc().toIso8601String(), 'shopId': ?shopId,
    });
    if (!target.ready) {
      await _uploads.putFile(target, file.path, mime);
      await _uploads.completeUpload(id);
    }
    return id;
  }
}

final adminApiProvider = Provider<AdminApi>((ref) => AdminApi(ref.watch(apiClientProvider), ref.watch(syncApiProvider)));
