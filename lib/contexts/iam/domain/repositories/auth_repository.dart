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

  Future<User> updateProfile({
    required String token,
    required String fullName,
    required String email,
  });

  Future<void> logout();
}