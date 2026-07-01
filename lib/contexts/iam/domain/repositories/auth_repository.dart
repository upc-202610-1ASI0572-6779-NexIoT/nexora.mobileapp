import '../entities/profile.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<String> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<User> getAuthenticatedUser({
    required String token,
  });

  Future<Profile> getProfile({
    required String token,
  });

  Future<Profile> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    String? phoneNumber,
  });

  Future<void> logout();
}