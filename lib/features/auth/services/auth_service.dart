// lib/features/auth/services/auth_service.dart

import 'dart:convert';
import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/validators.dart';
import '../models/auth_tokens.dart';
import '../models/social_auth_response.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;
  final LocalStorage _storage;

  AuthService({
    required ApiClient apiClient,
    required LocalStorage storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  LocalStorage get storage => _storage;

  /// Authenticates using OAuth2PasswordRequestForm
  /// identifier can be username or email
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    AppLogger.i('Attempting login for: $identifier');
    final response = await _apiClient.postForm(
      ApiEndpoints.login,
      {
        'username': identifier.trim(),
        'password': password,
      },
    );

    final tokens = AuthTokens.fromJson(response as Map<String, dynamic>);
    await _storage.saveToken(tokens.accessToken, tokenType: tokens.tokenType);

    // Fetch user profile immediately
    try {
      final user = await getProfile();
      return user;
    } catch (e) {
      AppLogger.w('Failed to fetch full profile after login: $e');
      final fallbackUser = UserModel(
        id: 1,
        firstName: identifier.contains('@') ? identifier.split('@').first : identifier,
        lastName: '',
        username: identifier.contains('@') ? identifier.split('@').first : identifier,
        email: identifier.contains('@') ? identifier : '',
        phone: '',
        role: 'customer',
      );
      await _storage.saveUserJson(jsonEncode(fallbackUser.toJson()));
      return fallbackUser;
    }
  }

  /// Creates a new customer account
  Future<UserModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    String? username,
  }) async {
    AppLogger.i('Attempting signup for email: $email');
    final Map<String, dynamic> body = {
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
      'password_confirm': passwordConfirm,
    };

    if (username != null && username.trim().isNotEmpty) {
      body['username'] = username.trim().toLowerCase();
    }

    final response = await _apiClient.postJson(ApiEndpoints.signup, body);
    final user = UserModel.fromJson(response as Map<String, dynamic>);

    // Auto-login after successful registration
    try {
      await login(identifier: email, password: password);
    } catch (e) {
      AppLogger.w('Auto login after signup failed: $e');
      await _storage.saveUserJson(jsonEncode(user.toJson()));
    }

    return user;
  }

  /// Authenticates or provisions a user via Google or Facebook OAuth on the FastAPI backend
  /// Passes the ID token / access token directly to POST /api/auth/social
  Future<SocialAuthResponse> socialAuth({
    required String provider,
    required String token,
    String? phone,
  }) async {
    AppLogger.i('Initiating server social authentication for provider: $provider');
    final Map<String, dynamic> body = {
      'provider': provider.toLowerCase().trim(),
      'token': token.trim(),
    };
    if (phone != null && phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }

    final response = await _apiClient.postJson(ApiEndpoints.social, body);
    final socialRes = SocialAuthResponse.fromJson(response as Map<String, dynamic>);

    // Save issued system JWT bearer token & user profile
    await _storage.saveToken(socialRes.accessToken, tokenType: socialRes.tokenType);
    await _storage.saveUserJson(jsonEncode(socialRes.user.toJson()));
    AppLogger.i('Server social authentication success: user_id=${socialRes.user.id}, is_new=${socialRes.isNewUser}');
    return socialRes;
  }

  /// Completes phone number registration for social login customers
  Future<UserModel> completePhone({required String phone}) async {
    AppLogger.i('Completing phone number on server: $phone');
    final response = await _apiClient.postJson(
      ApiEndpoints.completePhone,
      {'phone': phone.trim()},
    );
    final updated = UserModel.fromJson(response as Map<String, dynamic>);
    await _storage.saveUserJson(jsonEncode(updated.toJson()));
    return updated;
  }

  /// Requests a password reset code
  Future<String> requestPasswordReset(String email) async {
    AppLogger.i('Requesting password reset for: $email');
    final response = await _apiClient.postJson(
      ApiEndpoints.passwordReset,
      {'email': email.trim().toLowerCase()},
    );
    if (response is Map && response.containsKey('detail')) {
      return response['detail'] as String;
    }
    return 'If the email is registered, a reset code has been sent.';
  }

  /// Confirms password reset with 6-digit code
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    AppLogger.i('Confirming password reset for: $email with code: $code');
    await _apiClient.postJson(
      ApiEndpoints.passwordResetConfirm,
      {
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        'new_password': newPassword,
        'new_password_confirm': newPasswordConfirm,
      },
    );
  }

  /// Starts email verification for logged-in user
  Future<String> requestEmailVerification() async {
    AppLogger.i('Requesting email verification code');
    final response = await _apiClient.postJson(
      ApiEndpoints.emailVerification,
      {},
    );
    if (response is Map && response.containsKey('detail')) {
      return response['detail'] as String;
    }
    return 'Verification code sent to your email';
  }

  /// Confirms email verification with code
  Future<UserModel> confirmEmailVerification(String code) async {
    AppLogger.i('Confirming email verification code: $code');
    final response = await _apiClient.postJson(
      ApiEndpoints.emailVerificationConfirm,
      {'code': code.trim()},
    );
    final user = UserModel.fromJson(response as Map<String, dynamic>);
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Fetches current authenticated user profile
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    final user = UserModel.fromJson(response as Map<String, dynamic>);
    await _storage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Updates user profile on backend
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
    String? picture,
  }) async {
    AppLogger.i('Updating user profile');
    final Map<String, dynamic> body = {};
    if (firstName != null && firstName.trim().isNotEmpty) body['first_name'] = firstName.trim();
    if (lastName != null && lastName.trim().isNotEmpty) body['last_name'] = lastName.trim();
    if (username != null && username.trim().isNotEmpty) body['username'] = username.trim();
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim().toLowerCase();
    if (phone != null && phone.trim().isNotEmpty) {
      final norm = Validators.normalisePhone(phone.trim());
      body['phone'] = (norm != null && norm.isNotEmpty) ? norm : phone.trim();
    }
    if (picture != null && picture.trim().isNotEmpty) body['picture'] = picture.trim();

    final token = _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw UnauthorizedException('Please sign in to update your profile.');
    }

    try {
      final response = await _apiClient.patchJson(ApiEndpoints.updateMe, body);
      final user = UserModel.fromJson(response as Map<String, dynamic>);
      await _storage.saveUserJson(jsonEncode(user.toJson()));
      return user;
    } on UnauthorizedException {
      AppLogger.w('Profile patch returned 401 Unauthorized - token expired');
      await _storage.clearAuth();
      rethrow;
    } catch (e) {
      AppLogger.e('Backend profile patch failed: $e');
      rethrow;
    }
  }

  /// Changes current password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    AppLogger.i('Changing user password');
    await _apiClient.putJson(
      ApiEndpoints.changePassword,
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirm': confirmPassword,
      },
    );
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.saveUserJson(jsonEncode(user.toJson()));
  }

  /// Logs out the user
  Future<void> logout() async {
    AppLogger.i('Logging out user');
    await _storage.clearAuth();
  }

  /// Retrieves cached user from local storage
  UserModel? getCachedUser() {
    final jsonStr = _storage.getCachedUserJson();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => _storage.hasToken || getCachedUser() != null;
}
