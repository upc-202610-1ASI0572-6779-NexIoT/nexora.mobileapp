import '../../domain/entities/profile.dart';

class ProfileDto {
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String country;
  final String city;
  final String address;
  final String? phoneNumber;

  const ProfileDto({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.country,
    required this.city,
    required this.address,
    this.phoneNumber,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      isActive: json['isActive'] ?? true,
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'],
    );
  }

  Profile toDomain() {
    return Profile(
      email: email,
      firstName: firstName,
      lastName: lastName,
      isActive: isActive,
      country: country,
      city: city,
      address: address,
      phoneNumber: phoneNumber,
    );
  }
}