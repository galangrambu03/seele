import 'package:material_ui/material_ui.dart';

import '../../features/account/data/repositories/secure_account_repository.dart';
import '../../features/account/domain/entities/account_info.dart';
import '../../features/account/domain/repositories/account_repository.dart';

enum AccountSessionState { disconnected, connecting, connected }

class AccountSession extends ChangeNotifier {
  final AccountRepository _repository;

  AccountSession({AccountRepository? repository})
    : _repository = repository ?? SecureAccountRepository();

  AccountSessionState _state = AccountSessionState.disconnected;
  AccountInfo? _accountInfo;
  String? _errorMessage;
  String? _currentToken;

  AccountSessionState get state => _state;
  AccountInfo? get accountInfo => _accountInfo;
  String? get errorMessage => _errorMessage;

  /// Token aktif di memori (untuk dipakai layer data, mis. quest repository).
  String? get currentToken => _currentToken;

  bool get isConnected => _state == AccountSessionState.connected;
  bool get isConnecting => _state == AccountSessionState.connecting;

  Future<void> restoreSession() async {
    final token = await _repository.getToken();
    if (token == null || token.isEmpty) return;
    await _authenticate(token, saveToken: false);
  }

  Future<void> connect(String token) async {
    if (token.trim().isEmpty) {
      _errorMessage = 'Token cannot be empty.';
      notifyListeners();
      return;
    }
    await _authenticate(token.trim(), saveToken: true);
  }

  Future<void> _authenticate(String token, {required bool saveToken}) async {
    _state = AccountSessionState.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final info = await _repository.validateAndFetch(token);

      if (saveToken) {
        await _repository.saveToken(token);
      }

      _currentToken = token;
      _accountInfo = info;
      _state = AccountSessionState.connected;
      _errorMessage = null;
    } on AccountAuthException catch (e) {
      _state = AccountSessionState.disconnected;
      _errorMessage = e.message;
      _currentToken = null;

      if (e.statusCode == 401 || e.statusCode == 403) {
        await _repository.clearToken();
        _accountInfo = null;
      }
    } catch (_) {
      _state = AccountSessionState.disconnected;
      _errorMessage = 'Connection failed. Check your internet connection.';
      _currentToken = null;
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    await _repository.clearToken();

    _accountInfo = null;
    _errorMessage = null;
    _currentToken = null;
    _state = AccountSessionState.disconnected;

    notifyListeners();
  }
}
