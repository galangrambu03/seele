// lib/features/account/domain/entities/account_info.dart
// Entity representing a Discord user's public profile information.
// Token is never stored here — it is handled by SecureAccountRepository only.

class AccountInfo {
  final String userId;
  final String username;
  final String? displayName; // global_name from Discord API, may be null.
  final String? avatarUrl; // null if user has no custom avatar.

  const AccountInfo({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  /// The best available display label: global_name → username.
  String get effectiveDisplayName => displayName ?? username;
}
