import '../../domain/entities/user.dart';

class UserDto {
  final int id;
  final String email;
  final bool isActive;
  final int failedLoginAttempts;
  final DateTime? lockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserDto({
    required this.id,
    required this.email,
    required this.isActive,
    required this.failedLoginAttempts,
    this.lockedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] ?? json['userId'] ?? 0,
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? true,
      failedLoginAttempts: json['failedLoginAttempts'] ?? 0,
      lockedAt: json['lockedAt'] != null ? DateTime.parse(json['lockedAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      isActive: isActive,
      failedLoginAttempts: failedLoginAttempts,
      lockedAt: lockedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}