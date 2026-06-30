import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Profile> execute({
    required String token,
    required String firstName,
    required String lastName,
    required String country,
    required String city,
    required String address,
    String? phoneNumber,
  }) {
    return repository.updateProfile(
      token: token,
      firstName: firstName,
      lastName: lastName,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
    );
  }
}