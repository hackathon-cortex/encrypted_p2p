class AuthService {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    // Backend authentication will be connected here later.
    _isLoggedIn = true;
    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
  }

  Future<bool> register({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return false;
    }

    // Backend registration will be connected here later.
    return true;
  }
}