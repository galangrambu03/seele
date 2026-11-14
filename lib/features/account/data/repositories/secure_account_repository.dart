// lib/features/account/data/repositories/secure_account_repository.dart
//
// Uses GET /api/v10/users/@me — the officially documented Discord REST endpoint.
// https://discord.com/developers/docs/resources/user#get-current-user
//
// Token is sent as: Authorization: <token>  (user token format, no prefix).
// Token is NEVER logged, printed, or stored until validation succeeds.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';

class SecureAccountRepository implements AccountRepository {
  static const _tokenKey = 'discord_token';
  static const _apiBase = 'https://discord.com/api/v10';
  static const _cdnBase = 'https://cdn.discordapp.com';

  final FlutterSecureStorage _storage;
  final http.Client _client;

  SecureAccountRepository({FlutterSecureStorage? storage, http.Client? client})
    : _storage = storage ?? const FlutterSecureStorage(),
      _client = client ?? http.Client();

  /// Calls GET /users/@me with the given token.
  /// Saves the token only if the call returns HTTP 200.
  /// Throws [AccountAuthException] on 401/403 or network errors.
  @override
  Future<AccountInfo> validateAndFetch(String token) async {
    final uri = Uri.parse('$_apiBase/users/@me');
    final http.Response response;

    try {
      response = await _client
          .get(
            uri,
            headers: {
              'Authorization': token,
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw const AccountAuthException(
        'Could not reach Discord. Check your internet connection.',
      );
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseProfile(json);
    } else if (response.statusCode == 401) {
      throw const AccountAuthException(
        'Invalid token. Make sure you copied the full token correctly.',
        statusCode: 401,
      );
    } else {
      throw AccountAuthException(
        'Discord returned an unexpected response.',
        statusCode: response.statusCode,
      );
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async => _storage.read(key: _tokenKey);

  @override
  Future<void> clearToken() async => _storage.delete(key: _tokenKey);

  // --- Private helpers ---

  AccountInfo _parseProfile(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final username = json['username'] as String;
    final displayName = json['global_name'] as String?;
    final avatarHash = json['avatar'] as String?;
    final avatarUrl = avatarHash != null
        ? '$_cdnBase/avatars/$id/$avatarHash.png?size=128'
        : null;

    return AccountInfo(
      userId: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
