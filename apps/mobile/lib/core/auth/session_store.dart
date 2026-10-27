import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import 'session.dart';

/// A sign-in the user asked to remember ("Remember password"): the method, the login as typed and the password.
class SavedLogin {
  const SavedLogin({required this.method, required this.login, required this.password});

  final String method;
  final String login;
  final String password;
}

/// Tokens, the signed-in user and the remembered sign-in, kept in the platform keystore.
class SessionStore implements TokenSource {
  SessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _user = 'user';
  static const _savedMethod = 'saved_login_method';
  static const _savedLogin = 'saved_login';
  static const _savedPassword = 'saved_password';

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

  /// The remembered sign-in, or null. Kept across sign-out: it is there so the next sign-in needs one tap.
  Future<SavedLogin?> readSavedLogin() async {
    final login = await _storage.read(key: _savedLogin);
    final password = await _storage.read(key: _savedPassword);
    if (login == null || password == null) return null;
    return SavedLogin(
      method: await _storage.read(key: _savedMethod) ?? 'phone',
      login: login,
      password: password,
    );
  }

  Future<void> writeSavedLogin(SavedLogin saved) async {
    await _storage.write(key: _savedMethod, value: saved.method);
    await _storage.write(key: _savedLogin, value: saved.login);
    await _storage.write(key: _savedPassword, value: saved.password);
  }

  Future<void> clearSavedLogin() async {
    for (final key in [_savedMethod, _savedLogin, _savedPassword]) {
      await _storage.delete(key: key);
    }
  }

  /// Removes the session (tokens and user). The device install id and the remembered sign-in are kept.
  Future<void> clear() async {
    for (final key in [_access, _refresh, _user]) {
      await _storage.delete(key: key);
    }
  }
}
