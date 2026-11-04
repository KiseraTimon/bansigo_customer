// lib/core/utils/validators.dart

class Validators {
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z0-9_.]{3,30}$');
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  static final RegExp _keMobileRegex = RegExp(r'^\+254[17]\d{8}$');
  static final RegExp _codeRegex = RegExp(r'^\d{4,10}$');

  /// Validates a first name or last name (1 - 50 chars)
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = value.trim();
    if (trimmed.length > 50) {
      return '$fieldName must be at most 50 characters';
    }
    return null;
  }

  /// Validates username (3-30 characters: letters, digits, '_' or '.')
  static String? validateUsername(String? value, {bool required = false}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Username is required' : null;
    }
    final trimmed = value.trim();
    if (!_usernameRegex.hasMatch(trimmed)) {
      return '3-30 characters: letters, numbers, _ or .';
    }
    return null;
  }

  /// Validates email address (max 100 chars)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim().toLowerCase();
    if (trimmed.length > 100) {
      return 'Email must be at most 100 characters';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Normalises Kenyan mobile phone number to +254XXXXXXXXX
  /// Accepts 07XXXXXXXX, 01XXXXXXXX, 2547XXXXXXXX, +254 7XX XXX XXX
  static String? normalisePhone(String? value) {
    if (value == null) return null;
    String digits = value.replaceAll(RegExp(r'[\s\-().]'), '');
    if (RegExp(r'^0[17]\d{8}$').hasMatch(digits)) {
      digits = '+254${digits.substring(1)}';
    } else if (RegExp(r'^254[17]\d{8}$').hasMatch(digits)) {
      digits = '+$digits';
    }
    return digits;
  }

  /// Validates Kenyan mobile number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final normalised = normalisePhone(value.trim());
    if (normalised == null || !_keMobileRegex.hasMatch(normalised)) {
      return 'Enter a valid Kenyan number (e.g. 0712345678)';
    }
    return null;
  }

  /// Validates password (min 8, max 128 chars)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (value.length > 128) {
      return 'Password must be at most 128 characters';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates verification/reset code (4-10 digits, typically 6)
  static String? validateCode(String? value, {int expectedLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $expectedLength-digit code';
    }
    final trimmed = value.trim();
    if (!_codeRegex.hasMatch(trimmed) || trimmed.length != expectedLength) {
      return 'Must be exactly $expectedLength digits';
    }
    return null;
  }
}
