import '../../domain/entities/user.dart';

class UserDto {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String accountStatus;
  final String createdAt;

  const UserDto({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'User',
      accountStatus: json['accountStatus'] ?? json['status'] ?? 'Active',
      createdAt: json['createdAt'] ?? '',
    );
  }

  User toDomain() {
    return User(
      id: id,
      fullName: fullName,
      email: email,
      role: role,
      accountStatus: accountStatus,
      createdAt: createdAt,
    );
  }
}