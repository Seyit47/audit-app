import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import 'session.dart';

/// Tokens and the signed-in user, kept in the platform keystore.
class SessionStore implements TokenSource {
  SessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _user = 'user';

  @override
  Future<Tokens?> readTokens() async {
    final access = await _storage.read(key: _access);
    final refresh = await _storage.read(key: _refresh);
    if (access == null || refresh == null) return null;
    return Tokens(access: access, refresh: refresh);
  }

  @override
  Future<void> writeTokens(Tokens tokens) async {
    await _storage.write(key: _access, value: tokens.access);
    await _storage.write(key: _refresh, value: tokens.refresh);
  }

  Future<SessionUser?> readUser() async {
    final raw = await _storage.read(key: _user);
    return raw == null ? null : SessionUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> writeUser(SessionUser user) => _storage.write(key: _user, value: jsonEncode(user.toJson()));

  Future<void> clear() => _storage.deleteAll();
}
