import '../../application/services/session_service.dart';
import '../../domain/entities/profile.dart';
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
  Future<Profile> getProfile({
    required String token,
  }) async {
    final profileDto = await apiService.getProfile(token: token);
    return profileDto.toDomain();
  }

  @override
  Future<Profile> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    String? phoneNumber,
  }) async {
    final profileDto = await apiService.updateProfile(
      token: token,
      firstName: firstName,
      lastName: lastName,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
    );

    return profileDto.toDomain();
  }

  @override
  Future<void> logout() async {
    await sessionService.clearSession();
  }
}