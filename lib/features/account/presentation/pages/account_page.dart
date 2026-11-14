// lib/features/account/presentation/pages/account_page.dart
// UI for manual Discord token entry and account connection.

import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../domain/entities/account_info.dart';
import '../../domain/repositories/account_repository.dart';
import '../../data/repositories/secure_account_repository.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

enum _ConnState { disconnected, connecting, connected, failed }

class _AccountPageState extends State<AccountPage> {
  final AccountRepository _repo = SecureAccountRepository();
  final _tokenController = TextEditingController();
  bool _obscure = true;
  _ConnState _state = _ConnState.disconnected;
  AccountInfo? _accountInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  /// On startup: if a token was previously saved, re-validate it.
  Future<void> _restoreSession() async {
    final token = await _repo.getToken();
    if (token == null || !mounted) return;
    // Fill the field with masked placeholder (don't restore raw token to UI).
    _tokenController.text = '••••••••••••••••';
    // Re-validate silently.
    await _validateAndConnect(token);
  }

  /// Connect: validate FIRST, save token only on success.
  Future<void> _connect() async {
    if (!mounted) return;
    final token = _tokenController.text.trim();
    if (token.isEmpty || token == '••••••••••••••••') {
      setState(() {
        _state = _ConnState.failed;
        _errorMessage = 'Please paste your Discord token before connecting.';
      });
      return;
    }
    await _validateAndConnect(token);
  }

  Future<void> _validateAndConnect(String token) async {
    if (!mounted) return;
    setState(() {
      _state = _ConnState.connecting;
      _errorMessage = null;
    });
    try {
      final info = await _repo.validateAndFetch(token);
      // Only save after successful validation.
      await _repo.saveToken(token);
      if (!mounted) return;
      setState(() {
        _accountInfo = info;
        _state = _ConnState.connected;
        _errorMessage = null;
        // Clear the text field — token is now stored securely.
        _tokenController.clear();
      });
    } on AccountAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ConnState.failed;
        _errorMessage = e.message;
        _tokenController.clear();
      });
      // Clear any previously saved token so stale data isn't kept.
      await _repo.clearToken();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _state = _ConnState.failed;
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _tokenController.clear();
      });
      await _repo.clearToken();
    }
  }

  Future<void> _disconnect() async {
    await _repo.clearToken();
    if (!mounted) return;
    setState(() {
      _state = _ConnState.disconnected;
      _accountInfo = null;
      _errorMessage = null;
      _tokenController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.surface,
        title: const Text(
          'Discord Account',
          style: TextStyle(color: AppColor.textPrimary),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner — shown only when disconnected/failed
              if (_state != _ConnState.connected) _buildInfoBanner(),

              if (_state != _ConnState.connected)
                const SizedBox(height: AppSpacing.xl),

              // Profile card — shown only when connected
              if (_state == _ConnState.connected && _accountInfo != null)
                _buildProfileCard(),

              if (_state == _ConnState.connected && _accountInfo != null)
                const SizedBox(height: AppSpacing.xl),

              // Token input — hidden when connected
              if (_state != _ConnState.connected) ...[
                const Text(
                  'Discord Token',
                  style: TextStyle(
                    color: AppColor.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _tokenController,
                  obscureText: _obscure,
                  enabled: _state != _ConnState.connecting,
                  style: const TextStyle(color: AppColor.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Paste your token here',
                    hintStyle: const TextStyle(color: AppColor.textMuted),
                    filled: true,
                    fillColor: AppColor.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColor.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide:
                          const BorderSide(color: AppColor.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                          color: AppColor.cyan, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                          color: AppColor.cardBorder.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Action buttons
              Row(
                children: [
                  if (_state != _ConnState.connected)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lime,
                        foregroundColor: AppColor.background,
                        disabledBackgroundColor:
                            AppColor.lime.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      icon: _state == _ConnState.connecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.background,
                              ),
                            )
                          : const Icon(Icons.link_rounded),
                      label: Text(_state == _ConnState.connecting
                          ? 'Verifying...'
                          : 'Connect'),
                      onPressed:
                          _state == _ConnState.connecting ? null : _connect,
                    ),
                  if (_state == _ConnState.connected) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.error,
                        side:
                            BorderSide(color: AppColor.error.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      icon: const Icon(Icons.link_off_rounded),
                      label: const Text('Disconnect'),
                      onPressed: _disconnect,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // Status / error banner
              _buildStatusBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColor.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColor.amberDark.withValues(alpha: 0.6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColor.amber, size: 18),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Enter your Discord user token. '
              'Your token will be verified against the Discord API '
              'and stored securely on this device. '
              'Never share your token with anyone.',
              style: TextStyle(
                color: AppColor.amber,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final info = _accountInfo!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColor.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(info),
          const SizedBox(width: AppSpacing.md),
          // Name & ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.effectiveDisplayName,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (info.displayName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${info.username}',
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceLight,
                        borderRadius:
                            BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'ID: ${info.userId}',
                        style: const TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Connected indicator
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppColor.success, size: 7),
                SizedBox(width: 4),
                Text(
                  'Connected',
                  style: TextStyle(
                    color: AppColor.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AccountInfo info) {
    if (info.avatarUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(info.avatarUrl!),
        backgroundColor: AppColor.surfaceLight,
        radius: 28,
      );
    }
    // Fallback: initials
    final initial = info.effectiveDisplayName.isNotEmpty
        ? info.effectiveDisplayName[0].toUpperCase()
        : '?';
    return CircleAvatar(
      backgroundColor: AppColor.cyan,
      radius: 28,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColor.background,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final String text;
    final Color bannerColor;
    final IconData icon;

    switch (_state) {
      case _ConnState.disconnected:
        text = 'Not connected. Enter your token above and press Connect.';
        bannerColor = AppColor.textMuted;
        icon = Icons.wifi_off_rounded;
        break;
      case _ConnState.connecting:
        text = 'Verifying with Discord…';
        bannerColor = AppColor.cyan;
        icon = Icons.sync_rounded;
        break;
      case _ConnState.connected:
        text = 'Token verified. Profile loaded from Discord.';
        bannerColor = AppColor.success;
        icon = Icons.check_circle_outline_rounded;
        break;
      case _ConnState.failed:
        text = _errorMessage ??
            'Connection failed. Check your token and try again.';
        bannerColor = AppColor.error;
        icon = Icons.error_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: bannerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: bannerColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
