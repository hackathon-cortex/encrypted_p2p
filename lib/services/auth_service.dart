import '../models/user_model.dart';

class AuthService {
  bool _isLoggedIn = false;
  UserModel? _currentUser;
  final bool _isMfaRequired = true;
  bool _isMfaVerified = false;
  String _sessionToken = 'CTX-SES-99428-SEC';

  bool get isLoggedIn => _isLoggedIn && (!_isMfaRequired || _isMfaVerified);
  UserModel? get currentUser => _currentUser;
  bool get isMfaRequired => _isMfaRequired;
  bool get isMfaVerified => _isMfaVerified;
  String get sessionToken => _sessionToken;

  AuthService() {
    // Default demo user
    _currentUser = UserModel(
      id: 'usr_cortex_01',
      username: 'commander_alex',
      fullName: 'Alex Morgan',
      callsign: 'Vanguard-1',
      role: 'Commander',
      department: 'Central Command',
      clearanceLevel: 'Level 5 - Command Core',
      isOnline: true,
      publicKeyFingerprint: 'SHA256:4A9C:7E2F:1D8B:3C0A:9F5E:6B8D:2E1A',
      isMfaEnabled: true,
      isBiometricEnabled: true,
    );
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    _isLoggedIn = true;
    _isMfaVerified = false; // Requires MFA step
    _sessionToken = 'CTX-SES-${DateTime.now().millisecondsSinceEpoch % 100000}-SEC';

    _currentUser = UserModel(
      id: 'usr_cortex_01',
      username: username.trim(),
      fullName: username.toLowerCase().contains('alex') ? 'Alex Morgan' : 'Field Commander',
      callsign: 'Vanguard-1',
      role: 'Commander',
      department: 'Central Command',
      clearanceLevel: 'Level 5 - Command Core',
      isOnline: true,
      publicKeyFingerprint: 'SHA256:4A9C:7E2F:1D8B:3C0A:9F5E:6B8D:2E1A',
      isMfaEnabled: true,
      isBiometricEnabled: true,
    );

    return true;
  }

  Future<bool> verifyMfa(String code) async {
    if (code.length == 6 || code == '123456' || code == '999999') {
      _isMfaVerified = true;
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithBiometrics() async {
    // Simulated biometric hardware authentication
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = true;
    _isMfaVerified = true;
    return true;
  }

  Future<bool> recoverAccount({
    required String username,
    required String recoveryKey,
  }) async {
    if (recoveryKey.trim().length >= 8) {
      _isLoggedIn = true;
      _isMfaVerified = true;
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String username,
    required String fullName,
    required String callsign,
    required String department,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username.trim(),
      fullName: fullName.trim().isEmpty ? username.trim() : fullName.trim(),
      callsign: callsign.trim().isEmpty ? 'Agent-${username.substring(0, 3).toUpperCase()}' : callsign.trim(),
      role: 'Security Officer',
      department: department.isEmpty ? 'Cyber Defense' : department,
      clearanceLevel: 'Level 4 - Top Secret',
      isOnline: true,
      publicKeyFingerprint: 'SHA256:9F8E:7D6C:5B4A:3F2E:1D0C:8B7A:6F5E',
      isMfaEnabled: true,
      isBiometricEnabled: true,
    );

    _isLoggedIn = true;
    _isMfaVerified = true;
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isMfaVerified = false;
  }

  void updateProfile(UserModel updated) {
    _currentUser = updated;
  }
}