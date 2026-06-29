import '../dto/user_dto.dart';

class AuthApiService {
  // TODO: Replace with real WebService endpoint when backend is available.
  static const String baseUrl = 'https://api.nexora.local/api/v1';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    // TODO: Connect to POST $baseUrl/auth/login.
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required.');
    }

    return 'temporary-auth-token';
  }

  Future<UserDto> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // TODO: Connect to POST $baseUrl/auth/register.
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Full name, email and password are required.');
    }

    return UserDto(
      id: 0,
      fullName: fullName,
      email: email,
      role: 'User',
      accountStatus: 'Active',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  Future<UserDto> getAuthenticatedUser({
    required String token,
  }) async {
    // TODO: Connect to GET $baseUrl/profile/me.
    if (token.isEmpty) {
      throw Exception('Authentication token is required.');
    }

    return UserDto(
      id: 0,
      fullName: 'Authenticated User',
      email: 'user@nexora.com',
      role: 'User',
      accountStatus: 'Active',
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  Future<UserDto> updateProfile({
    required String token,
    required String fullName,
    required String email,
  }) async {
    // TODO: Connect to PUT $baseUrl/profile/me.
    if (token.isEmpty) {
      throw Exception('Authentication token is required.');
    }

    if (fullName.isEmpty || email.isEmpty) {
      throw Exception('Full name and email are required.');
    }

    return UserDto(
      id: 0,
      fullName: fullName,
      email: email,
      role: 'User',
      accountStatus: 'Active',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}