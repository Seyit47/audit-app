import 'package:dio/dio.dart';

/// An API error in the server's shape: `{error: {code, message, details?}, requestId}`.
class ApiException implements Exception {
  ApiException({required this.code, required this.message, this.status, this.details, this.requestId});

  /// Builds from a dio error. Network failures get the code `NETWORK`.
  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    final data = response?.data;
    if (data is Map && data['error'] is Map) {
      final error = data['error'] as Map;
      return ApiException(
        code: error['code'] as String? ?? 'UNKNOWN',
        message: error['message'] as String? ?? '',
        status: response?.statusCode,
        details: error['details'],
        requestId: data['requestId'] as String?,
      );
    }
    if (response == null) return ApiException(code: 'NETWORK', message: e.message ?? 'Network error');
    return ApiException(code: 'HTTP_${response.statusCode}', message: e.message ?? '', status: response.statusCode);
  }

  final String code;
  final String message;
  final int? status;
  final Object? details;
  final String? requestId;

  bool get isNetwork => code == 'NETWORK';

  /// Worth retrying later: no connection or a server-side failure.
  bool get isRetryable => isNetwork || (status != null && status! >= 500);

  @override
  String toString() => 'ApiException($code, $status): $message';
}
