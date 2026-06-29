import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> execute({
    required String token,
    required String fullName,
    required String email,
  }) {
    return repository.updateProfile(
      token: token,
      fullName: fullName,
      email: email,
    );
  }
}