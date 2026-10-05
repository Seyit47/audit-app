import 'package:dio/dio.dart';

/// A failed API call, normalized from [DioException] and the API's error body.
class ApiException implements Exception {
  const ApiException({required this.code, this.statusCode});

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    final code = data is Map && data['error'] is Map
        ? data['error']['code'] as String? ?? 'UNKNOWN'
        : response == null
        ? 'NETWORK_ERROR'
        : 'UNKNOWN';
    return ApiException(code: code, statusCode: response?.statusCode);
  }

  /// Machine-readable error code from the API, or `NETWORK_ERROR` when there was no response.
  final String code;
  final int? statusCode;

  bool get isNetworkError => code == 'NETWORK_ERROR';

  @override
  String toString() => 'ApiException($code, status: $statusCode)';
}
