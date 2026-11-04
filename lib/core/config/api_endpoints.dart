// lib/core/config/api_endpoints.dart

class ApiEndpoints {
  // Auth endpoints (prefixed by /api/auth on FastAPI server)
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String social = '/auth/social';
  static const String completePhone = '/auth/complete-phone';
  static const String reactivate = '/auth/reactivate';
  static const String passwordReset = '/auth/password-reset';
  static const String passwordResetConfirm = '/auth/password-reset/confirm';

  // User & Profile endpoints (prefixed by /api/users on FastAPI server)
  static const String me = '/users/me';
  static const String updateMe = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String deactivateMe = '/users/me/deactivate';
  static const String deleteMe = '/users/me';
  static const String emailVerification = '/users/me/email-verification';
  static const String emailVerificationConfirm = '/users/me/email-verification/confirm';
}
