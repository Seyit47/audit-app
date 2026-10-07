import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/session.dart';
import '../config/app_config.dart';
import 'api_exception.dart';

/// Where the client reads and writes tokens (the secure session store in the app).
abstract interface class TokenSource {
  Future<Tokens?> readTokens();
  Future<void> writeTokens(Tokens tokens);
}

/// Dio client for `/v1`: adds the bearer token, refreshes it once on 401 (concurrent 401s share
/// a single refresh), and turns failures into [ApiException].
class ApiClient {
  ApiClient({
    required this._tokens,
    required this._onSessionExpired,
    String? baseUrl,
    HttpClientAdapter? adapter,
  }) : dio = Dio(BaseOptions(
          baseUrl: '${baseUrl ?? AppConfig.apiUrl}/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          contentType: Headers.jsonContentType,
        )) {
    if (adapter != null) dio.httpClientAdapter = adapter;
    dio.interceptors.add(InterceptorsWrapper(onRequest: _onRequest, onError: _onError));
  }

  final Dio dio;
  final TokenSource _tokens;
  final void Function() _onSessionExpired;
  Future<bool>? _refreshing;

  static const _retried = 'retried';
  static const _noAuth = 'noAuth';

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _call(() => dio.get<T>(path, queryParameters: query));

  /// A POST without a body still sends `{}`: the JSON content type with an empty body is a 400.
  Future<T> post<T>(String path, {Object? body, bool auth = true}) =>
      _call(() => dio.post<T>(path, data: body ?? const <String, Object?>{}, options: Options(extra: {_noAuth: !auth})));

  Future<T> patch<T>(String path, {Object? body}) => _call(() => dio.patch<T>(path, data: body));

  Future<T> put<T>(String path, {Object? body}) => _call(() => dio.put<T>(path, data: body));

  Future<T> delete<T>(String path) => _call(() => dio.delete<T>(path));

  Future<T> _call<T>(Future<Response<T>> Function() send) async {
    try {
      return (await send()).data as T;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error! as ApiException : ApiException.fromDio(e);
    }
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[_noAuth] != true) {
      final tokens = await _tokens.readTokens();
      if (tokens != null) options.headers['Authorization'] = 'Bearer ${tokens.access}';
    }
    handler.next(options);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    final options = e.requestOptions;
    if (e.response?.statusCode != 401 || options.extra[_noAuth] == true || options.extra[_retried] == true) {
      return handler.next(e);
    }
    if (!await _refreshOnce()) {
      _onSessionExpired();
      return handler.next(e);
    }
    try {
      options.extra[_retried] = true;
      handler.resolve(await dio.fetch(options));
    } on DioException catch (retry) {
      handler.next(retry);
    }
  }

  Future<bool> _refreshOnce() => _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<bool> _refresh() async {
    final tokens = await _tokens.readTokens();
    if (tokens == null) return false;
    try {
      final res = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': tokens.refresh},
        options: Options(extra: {_noAuth: true}),
      );
      final body = res.data!;
      await _tokens.writeTokens(Tokens(access: body['accessToken'] as String, refresh: body['refreshToken'] as String));
      return true;
    } on DioException catch (e) {
      // Offline: keep the session; the request fails as a network error and is retried later.
      if (e.response == null) throw ApiException.fromDio(e);
      return false;
    }
  }
}
