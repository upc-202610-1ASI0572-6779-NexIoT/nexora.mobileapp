class User {
  final int id;
  final String email;
  final bool isActive;
  final int failedLoginAttempts;
  final DateTime? lockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.failedLoginAttempts,
    this.lockedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get accountStatus => isActive ? 'Active' : 'Inactive';
  bool get isLocked => lockedAt != null;
}