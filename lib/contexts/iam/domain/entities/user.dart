class User {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String accountStatus;
  final String createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.accountStatus,
    required this.createdAt,
  });

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? role,
    String? accountStatus,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}