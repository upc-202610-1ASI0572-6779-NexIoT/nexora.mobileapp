class SessionService {
  String? _token;

  Future<void> saveToken(String token) async {
    _token = token;
  }

  Future<String?> getToken() async {
    return _token;
  }

  Future<bool> hasActiveSession() async {
    return _token != null && _token!.isNotEmpty;
  }

  Future<void> clearSession() async {
    _token = null;
  }
}