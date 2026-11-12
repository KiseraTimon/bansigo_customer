// lib/features/auth/models/social_auth_response.dart

import 'user_model.dart';

class SocialAuthResponse {
  final String accessToken;
  final String tokenType;
  final UserModel user;
  final bool isNewUser;
  final bool requiresPhone;

  SocialAuthResponse({
    required this.accessToken,
    this.tokenType = 'bearer',
    required this.user,
    this.isNewUser = false,
    this.requiresPhone = false,
  });

  factory SocialAuthResponse.fromJson(Map<String, dynamic> json) {
    return SocialAuthResponse(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser: json['is_new_user'] as bool? ?? false,
      requiresPhone: json['requires_phone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'user': user.toJson(),
        'is_new_user': isNewUser,
        'requires_phone': requiresPhone,
      };
}
