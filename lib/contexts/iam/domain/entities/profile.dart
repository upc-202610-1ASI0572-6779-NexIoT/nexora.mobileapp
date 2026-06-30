class Profile {
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String country;
  final String city;
  final String address;
  final String? phoneNumber;

  const Profile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.country,
    required this.city,
    required this.address,
    this.phoneNumber,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get accountStatus => isActive ? 'Active' : 'Inactive';
}