import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';
import '../../domain/entities/account_info.dart';

class AccountPage extends StatefulWidget {
  final AccountSession accountSession;

  const AccountPage({super.key, required this.accountSession});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _tokenController = TextEditingController();

  bool _obscure = true;

  AccountSession get _session => widget.accountSession;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();

    await _session.connect(token);

    if (!mounted) return;

    if (_session.isConnected) {
      _tokenController.clear();
    }
  }

  Future<void> _disconnect() async {
    await _session.disconnect();

    if (!mounted) return;

    _tokenController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _session.isConnected;
    final isConnecting = _session.isConnecting;
    final accountInfo = _session.accountInfo;

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
              if (!isConnected) _buildInfoBanner(),

              if (!isConnected) const SizedBox(height: AppSpacing.xl),

              if (isConnected && accountInfo != null)
                _buildProfileCard(accountInfo),

              if (isConnected && accountInfo != null)
                const SizedBox(height: AppSpacing.xl),

              if (!isConnected) ...[
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
                  enabled: !isConnecting,
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
                      onPressed: isConnecting
                          ? null
                          : () => setState(() {
                              _obscure = !_obscure;
                            }),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColor.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColor.cyan,
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: AppColor.cardBorder.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              Row(
                children: [
                  if (!isConnected)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lime,
                        foregroundColor: AppColor.background,
                        disabledBackgroundColor: AppColor.lime.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      icon: isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.background,
                              ),
                            )
                          : const Icon(Icons.link_rounded),
                      label: Text(isConnecting ? 'Verifying...' : 'Connect'),
                      onPressed: isConnecting ? null : _connect,
                    ),

                  if (isConnected)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColor.error,
                        side: BorderSide(
                          color: AppColor.error.withValues(alpha: 0.5),
                        ),
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
              ),

              const SizedBox(height: AppSpacing.lg),

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

  Widget _buildProfileCard(AccountInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColor.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          _buildAvatar(info),
          const SizedBox(width: AppSpacing.md),
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    final isConnected = _session.isConnected;
    final isConnecting = _session.isConnecting;
    final errorMessage = _session.errorMessage;

    final String text;
    final Color bannerColor;
    final IconData icon;

    if (isConnecting) {
      text = 'Verifying with Discord…';
      bannerColor = AppColor.cyan;
      icon = Icons.sync_rounded;
    } else if (isConnected) {
      text = 'Token verified. Profile loaded from Discord.';
      bannerColor = AppColor.success;
      icon = Icons.check_circle_outline_rounded;
    } else if (errorMessage != null) {
      text = errorMessage;
      bannerColor = AppColor.error;
      icon = Icons.error_outline_rounded;
    } else {
      text = 'Not connected. Enter your token above and press Connect.';
      bannerColor = AppColor.textMuted;
      icon = Icons.wifi_off_rounded;
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
