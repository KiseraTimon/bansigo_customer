// lib/features/auth/providers/auth_provider.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SocialAuthResult {
  final bool success;
  final bool cancelled;
  final bool requiresPhone;
  final String? errorMessage;

  SocialAuthResult({
    this.success = false,
    this.cancelled = false,
    this.requiresPhone = false,
    this.errorMessage,
  });
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final GoogleSignIn _googleSignIn;

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSocialLoading = false;
  String? _errorMessage;
  Future<void> Function()? onLogoutCallback;
  Future<void> Function()? onAuthSuccessCallback;

  // Multi-step Login Cache
  String _loginIdentifier = '';

  // Multi-step Register Cache
  String _regFirstName = '';
  String _regLastName = '';
  String _regEmail = '';
  String _regPhone = '';
  String? _regUsername;

  // Multi-step Password Reset Cache
  String _resetEmail = '';
  String _resetCode = '';

  // Settings State
  late bool _orderNotifications;
  late bool _promoNotifications;
  late bool _smsAlerts;
  late bool _darkMode;
  late String _language;

  AuthProvider(this._authService)
      : _googleSignIn = GoogleSignIn(
          clientId: kIsWeb || defaultTargetPlatform == TargetPlatform.iOS
              ? AppConfig.current.googleClientId
              : null,
          serverClientId: AppConfig.current.googleClientId,
          scopes: ['email', 'profile'],
        ) {
    _currentUser = _authService.getCachedUser();
    final storage = _authService.storage;
    _orderNotifications = storage.orderNotifications;
    _promoNotifications = storage.promoNotifications;
    _smsAlerts = storage.smsAlerts;
    _darkMode = storage.darkMode;
    _language = storage.language;
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSocialLoading => _isSocialLoading;
  String? get errorMessage => _errorMessage;

  String get loginIdentifier => _loginIdentifier;
  String get regFirstName => _regFirstName;
  String get regLastName => _regLastName;
  String get regEmail => _regEmail;
  String get regPhone => _regPhone;
  String get resetEmail => _resetEmail;
  String get resetCode => _resetCode;

  // Settings Getters
  bool get orderNotifications => _orderNotifications;
  bool get promoNotifications => _promoNotifications;
  bool get smsAlerts => _smsAlerts;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get currentApiUrl => AppConfig.current.apiBaseUrl;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- Step 1: Login (Username / Email) ---
  void setLoginIdentifier(String identifier) {
    _loginIdentifier = identifier.trim();
    clearError();
  }

  // --- Step 2: Login (Password) ---
  Future<bool> executeLogin(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        identifier: _loginIdentifier,
        password: password,
      );
      if (onAuthSuccessCallback != null) {
        await onAuthSuccessCallback!();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on TimeoutException {
      _errorMessage =
          'Connection timed out connecting to: ${AppConfig.current.apiBaseUrl}.\nPlease ensure the server is running (--host 0.0.0.0) and your mobile device is on the same Wi-Fi.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage =
          'Cannot reach server at: ${AppConfig.current.apiBaseUrl}.\nPlease verify your Wi-Fi network and server IP address.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Login failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Register Step 1: Names ---
  void setRegisterNames(String firstName, String lastName) {
    _regFirstName = firstName.trim();
    _regLastName = lastName.trim();
    clearError();
  }

  // --- Register Step 2: Email & Phone ---
  void setRegisterContact({
    required String email,
    required String phone,
    String? username,
  }) {
    _regEmail = email.trim();
    _regPhone = phone.trim();
    _regUsername = username?.trim().isNotEmpty == true ? username!.trim() : null;
    clearError();
  }

  // --- Register Step 3: Passwords & Submission ---
  Future<bool> executeRegister({
    required String password,
    required String passwordConfirm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signup(
        firstName: _regFirstName,
        lastName: _regLastName,
        email: _regEmail,
        phone: _regPhone,
        username: _regUsername,
        password: password,
        passwordConfirm: passwordConfirm,
      );
      if (onAuthSuccessCallback != null) {
        await onAuthSuccessCallback!();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on TimeoutException {
      _errorMessage =
          'Connection timed out connecting to: ${AppConfig.current.apiBaseUrl}.\nPlease ensure the server is running (--host 0.0.0.0) and your mobile device is on the same Wi-Fi.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on SocketException {
      _errorMessage =
          'Cannot reach server at: ${AppConfig.current.apiBaseUrl}.\nPlease verify your Wi-Fi network and server IP address.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Registration failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Server-Processed Google Authentication ---
  Future<SocialAuthResult> signInWithGoogle() async {
    _isSocialLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        _isSocialLoading = false;
        notifyListeners();
        return SocialAuthResult(cancelled: true);
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final token = auth.idToken ?? auth.accessToken;

      if (token == null || token.isEmpty) {
        throw Exception('Google Sign-In did not return an authentication token.');
      }

      AppLogger.i('Sending Google token to FastAPI backend /api/auth/social');
      final res = await _authService.socialAuth(provider: 'google', token: token);
      UserModel user = res.user;
      if ((user.picture == null || user.picture!.isEmpty) && account.photoUrl != null && account.photoUrl!.isNotEmpty) {
        user = user.copyWith(picture: account.photoUrl);
      }
      _currentUser = user;
      if (onAuthSuccessCallback != null) {
        await onAuthSuccessCallback!();
      }

      _isSocialLoading = false;
      notifyListeners();
      return SocialAuthResult(
        success: true,
        requiresPhone: res.requiresPhone || (res.user.phone.isEmpty),
      );
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: ${e.toString().replaceAll('Exception:', '').trim()}';
      _isSocialLoading = false;
      AppLogger.e('Google Sign-In error', e);
      notifyListeners();
      return SocialAuthResult(errorMessage: _errorMessage);
    }
  }

  // --- Server-Processed Facebook Authentication ---
  Future<SocialAuthResult> signInWithFacebook({String? token}) async {
    _isSocialLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // In development / testing or when Meta developer token is provided:
      final fbToken = token ?? 'test_token_fb_${DateTime.now().millisecondsSinceEpoch}_user@example.com';
      AppLogger.i('Sending Facebook token to FastAPI backend /api/auth/social');
      final res = await _authService.socialAuth(provider: 'facebook', token: fbToken);
      _currentUser = res.user;

      _isSocialLoading = false;
      notifyListeners();
      return SocialAuthResult(
        success: true,
        requiresPhone: res.requiresPhone || (res.user.phone.isEmpty),
      );
    } catch (e) {
      _errorMessage = 'Facebook Sign-In failed: ${e.toString().replaceAll('Exception:', '').trim()}';
      _isSocialLoading = false;
      AppLogger.e('Facebook Sign-In error', e);
      notifyListeners();
      return SocialAuthResult(errorMessage: _errorMessage);
    }
  }

  // --- Complete Phone (POST /api/auth/complete-phone) ---
  Future<bool> completePhone(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _authService.completePhone(phone: phone);
      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Complete phone failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Update Profile ---
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
      );
      _currentUser = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Change Password ---
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Settings Toggles & Persistence ---
  Future<void> setOrderNotifications(bool val) async {
    _orderNotifications = val;
    await _authService.storage.setOrderNotifications(val);
    notifyListeners();
  }

  Future<void> setPromoNotifications(bool val) async {
    _promoNotifications = val;
    await _authService.storage.setPromoNotifications(val);
    notifyListeners();
  }

  Future<void> setSmsAlerts(bool val) async {
    _smsAlerts = val;
    await _authService.storage.setSmsAlerts(val);
    notifyListeners();
  }

  Future<void> setDarkMode(bool val) async {
    _darkMode = val;
    await _authService.storage.setDarkMode(val);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _authService.storage.setLanguage(lang);
    notifyListeners();
  }

  Future<void> setCustomServerUrl(String url) async {
    final clean = url.trim();
    AppConfig.setCustomApiBaseUrl(clean);
    await _authService.storage.setCustomApiUrl(clean);
    notifyListeners();
  }

  /// Pings the server URL to test network reachability from an external device
  Future<bool> testServerConnection(String url) async {
    try {
      final clean = url.trim().endsWith('/')
          ? url.trim().substring(0, url.trim().length - 1)
          : url.trim();
      final client = http.Client();
      try {
        // CHANGED: Ping a public endpoint instead of /users/me to avoid 401 backend logs
        final res = await client
            .get(Uri.parse('$clean/firebase/config'))
            .timeout(const Duration(seconds: 4));
        return res.statusCode > 0;
      } finally {
        client.close();
      }
    } catch (_) {
      return false;
    }
  }

  // --- Password Reset Step 1: Request Code ---
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _resetEmail = email.trim();
      await _authService.requestPasswordReset(_resetEmail);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Password reset request failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Password Reset Step 2: Set Code ---
  void setResetCode(String code) {
    _resetCode = code.trim();
    clearError();
  }

  // --- Password Reset Step 3: Submit New Password ---
  Future<bool> confirmPasswordReset({
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.confirmPasswordReset(
        email: _resetEmail,
        code: _resetCode,
        newPassword: newPassword,
        newPasswordConfirm: newPasswordConfirm,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Password reset confirm failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Verification: Request Code ---
  Future<bool> requestEmailVerification() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.requestEmailVerification();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Request email verification failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Verification: Confirm Code ---
  Future<bool> confirmEmailVerification(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.confirmEmailVerification(code);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      AppLogger.e('Confirm email verification failed', e);
      notifyListeners();
      return false;
    }
  }

  // --- Session Validation & Expiry ---
  Future<void> validateSession() async {
    if (!isAuthenticated) return;
    try {
      _currentUser = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      AppLogger.w('Startup session check failed: $e');
    }
  }

  Future<void> handleSessionExpired() async {
    if (!isAuthenticated && _currentUser == null) return;
    AppLogger.w('Session expired (401); clearing stale credentials');
    await _authService.logout();
    _currentUser = null;
    if (onLogoutCallback != null) {
      await onLogoutCallback!();
    }
    notifyListeners();
  }

  // --- Logout ---
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _authService.logout();
    _currentUser = null;
    if (onLogoutCallback != null) {
      await onLogoutCallback!();
    }
    notifyListeners();
  }
}
