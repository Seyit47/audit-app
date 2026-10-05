import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/version_info.dart';

final systemRepositoryProvider = Provider<SystemRepository>(
  (ref) => SystemRepository(ref.watch(dioProvider)),
);

/// Backend system endpoints (version, health).
class SystemRepository {
  const SystemRepository(this._dio);

  final Dio _dio;

  Future<VersionInfo> getVersion() => guardApiCall(() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/version');
    return VersionInfo.fromJson(response.data!);
  });
}
