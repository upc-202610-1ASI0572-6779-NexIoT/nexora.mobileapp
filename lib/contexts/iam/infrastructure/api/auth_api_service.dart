import '../dto/profile_dto.dart';
import '../dto/user_dto.dart';

class AuthApiService {
  // TODO: Replace with real WebService URL when backend deployment is available.
  static const String baseUrl = 'https://api.nexora.local/api/v1';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    // TODO: Connect to POST $baseUrl/authentication/signin.
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
    // TODO: Connect to POST $baseUrl/authentication/signup.
    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Full name, email and password are required.');
    }

    final now = DateTime.now();

    return UserDto(
      id: 0,
      email: email,
      isActive: true,
      failedLoginAttempts: 0,
      lockedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<UserDto> getAuthenticatedUser({
    required String token,
  }) async {
    // TODO: Connect to GET $baseUrl/profile/me or equivalent endpoint.
    if (token.isEmpty) {
      throw Exception('Authentication token is required.');
    }

    final now = DateTime.now();

    return UserDto(
      id: 0,
      email: 'user@nexora.com',
      isActive: true,
      failedLoginAttempts: 0,
      lockedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<ProfileDto> getProfile({
    required String token,
  }) async {
    // TODO: Connect to GET $baseUrl/profile/me.
    if (token.isEmpty) {
      throw Exception('Authentication token is required.');
    }

    return const ProfileDto(
      email: 'maria.castillo@nexora.com',
      firstName: 'Maria',
      lastName: 'Castillo',
      isActive: true,
      country: 'Perú',
      city: 'Lima',
      address: 'Av. Principal 123',
      phoneNumber: '+51 955 123 567',
    );
  }

  Future<ProfileDto> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    String? phoneNumber,
  }) async {
    // TODO: Connect to PUT $baseUrl/profile/me.
    if (token.isEmpty) {
      throw Exception('Authentication token is required.');
    }

    if (firstName.isEmpty || lastName.isEmpty || country.isEmpty) {
      throw Exception('First name, last name and country are required.');
    }

    return ProfileDto(
      email: 'maria.castillo@nexora.com',
      firstName: firstName,
      lastName: lastName,
      isActive: true,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
    );
  }
}