import '../../application/services/session_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final SessionService sessionService;

  AuthRepositoryImpl({
    required this.apiService,
    required this.sessionService,
  });

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final token = await apiService.login(
      email: email,
      password: password,
    );

    await sessionService.saveToken(token);
    return token;
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final userDto = await apiService.register(
      fullName: fullName,
      email: email,
      password: password,
    );

    return userDto.toDomain();
  }

  @override
  Future<User> getAuthenticatedUser({
    required String token,
  }) async {
    final userDto = await apiService.getAuthenticatedUser(token: token);
    return userDto.toDomain();
  }

  @override
  Future<User> updateProfile({
    required String token,
    required String fullName,
    required String email,
  }) async {
    final userDto = await apiService.updateProfile(
      token: token,
      fullName: fullName,
      email: email,
    );

    return userDto.toDomain();
  }

  @override
  Future<void> logout() async {
    await sessionService.clearSession();
  }
}