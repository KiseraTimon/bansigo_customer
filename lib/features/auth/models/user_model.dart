// lib/features/auth/models/user_model.dart

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? picture;
  final bool isVerified;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.picture,
    this.isVerified = false,
    this.isActive = true,
    this.lastLogin,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? role,
    String? picture,
    bool? isVerified,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      picture: picture ?? this.picture,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      picture: (json['picture'] ?? json['image_url'] ?? json['avatar_url'] ?? json['photo_url']) as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'email': email,
        'phone': phone,
        'role': role,
        'picture': picture,
        'is_verified': isVerified,
        'is_active': isActive,
        'last_login': lastLogin?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };
}
