import 'dart:convert';
import 'dart:typed_data';

import 'package:audit_mobile/core/auth/session.dart';
import 'package:audit_mobile/core/network/api_client.dart';
import 'package:audit_mobile/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Tokens implements TokenSource {
  _Tokens(this.tokens);
  Tokens? tokens;
  @override
  Future<Tokens?> readTokens() async => tokens;
  @override
  Future<void> writeTokens(Tokens t) async => tokens = t;
}

/// Answers by path; counts refresh calls.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handle);
  final ResponseBody Function(RequestOptions) handle;
  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? s, Future<void>? c) async => handle(o);
  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  test('concurrent 401s trigger a single refresh, then retry with the new token', () async {
    var refreshes = 0;
    final tokens = _Tokens(const Tokens(access: 'old', refresh: 'r1'));
    final client = ApiClient(
      tokens: tokens,
      onSessionExpired: () => fail('should not expire'),
      baseUrl: 'http://api',
      adapter: _Adapter((o) {
        if (o.path.endsWith('/auth/refresh')) {
          refreshes++;
          return _json(200, {'accessToken': 'new', 'refreshToken': 'r2'});
        }
        return o.headers['Authorization'] == 'Bearer new'
            ? _json(200, {'ok': true})
            : _json(401, {
                'error': {'code': 'UNAUTHENTICATED', 'message': ''},
              });
      }),
    );

    final results = await Future.wait([client.get<Map<String, dynamic>>('/a'), client.get<Map<String, dynamic>>('/b')]);
    expect(results.every((r) => r['ok'] == true), isTrue);
    expect(refreshes, 1);
    expect(tokens.tokens!.refresh, 'r2');
  });

  test('a rejected refresh expires the session and surfaces the API error', () async {
    var expired = false;
    final client = ApiClient(
      tokens: _Tokens(const Tokens(access: 'old', refresh: 'stale')),
      onSessionExpired: () => expired = true,
      baseUrl: 'http://api',
      adapter: _Adapter(
        (o) => _json(401, {
          'error': {'code': 'UNAUTHENTICATED', 'message': 'idle'},
          'requestId': 'x',
        }),
      ),
    );

    await expectLater(client.get<void>('/a'), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'UNAUTHENTICATED')));
    expect(expired, isTrue);
  });

  test('network failures are retryable ApiExceptions', () async {
    final client = ApiClient(
      tokens: _Tokens(null),
      onSessionExpired: () {},
      baseUrl: 'http://api',
      adapter: _Adapter((o) => throw DioException.connectionError(requestOptions: o, reason: 'offline')),
    );
    await expectLater(client.get<void>('/a'), throwsA(isA<ApiException>().having((e) => e.isRetryable, 'retryable', isTrue)));
  });
}
