// lib/features/account/domain/repositories/account_repository.dart
// Abstract repository for Discord account credential handling.

import '../entities/account_info.dart';

abstract class AccountRepository {
  /// Validates [token] against Discord API and returns profile info on success.
  /// Returns null and does NOT save token on failure.
  /// Throws [AccountAuthException] on HTTP errors.
  Future<AccountInfo> validateAndFetch(String token);

  /// Saves a validated token securely.
  Future<void> saveToken(String token);

  /// Retrieves the stored token, or null if none.
  Future<String?> getToken();

  /// Clears the stored token and any cached profile.
  Future<void> clearToken();
}

class AccountAuthException implements Exception {
  final String message;
  final int? statusCode;
  const AccountAuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AccountAuthException($statusCode): $message';
}
