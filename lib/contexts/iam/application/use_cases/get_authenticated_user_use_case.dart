import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class GetAuthenticatedUserUseCase {
  final AuthRepository repository;

  GetAuthenticatedUserUseCase(this.repository);

  Future<User> execute({
    required String token,
  }) {
    return repository.getAuthenticatedUser(token: token);
  }
}