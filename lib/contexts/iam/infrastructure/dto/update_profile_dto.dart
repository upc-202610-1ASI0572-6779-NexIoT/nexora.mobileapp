class UpdateProfileDto {
  final String firstName;
  final String lastName;
  final String country;
  final String city;
  final String address;
  final String? phoneNumber;

  const UpdateProfileDto({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.city,
    required this.address,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'city': city,
      'address': address,
      'phoneNumber': phoneNumber,
    };
  }
}