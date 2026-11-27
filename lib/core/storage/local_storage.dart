// lib/core/storage/local_storage.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyAccessToken = 'access_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyCachedUser = 'cached_user';
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keySelectedLocation = 'selected_location';
  static const String _keyCustomApiUrl = 'custom_api_url';
  static const String _keyWishlist = 'customer_wishlist';
  static const String _keyCart = 'customer_cart';
  static const String _keyCartSessions = 'all_cart_sessions';
  static const String _keyActiveCartId = 'active_cart_id';

  // Settings keys
  static const String _keyOrderNotifications = 'setting_order_notifications';
  static const String _keyPromoNotifications = 'setting_promo_notifications';
  static const String _keySmsAlerts = 'setting_sms_alerts';
  static const String _keyDarkMode = 'setting_dark_mode';
  static const String _keyLanguage = 'setting_language';

  final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Token management
  Future<void> saveToken(String token, {String tokenType = 'bearer'}) async {
    await _prefs.setString(_keyAccessToken, token);
    await _prefs.setString(_keyTokenType, tokenType);
  }

  String? getAccessToken() => _prefs.getString(_keyAccessToken);
  String getTokenType() => _prefs.getString(_keyTokenType) ?? 'bearer';
  bool get hasToken => _prefs.containsKey(_keyAccessToken) && (_prefs.getString(_keyAccessToken)?.isNotEmpty ?? false);

  Future<void> clearAuth() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyTokenType);
    await _prefs.remove(_keyCachedUser);
    await clearUserAddressData();
  }

  /// Clears persisted address and location data to prevent address leaks between accounts
  Future<void> clearUserAddressData() async {
    await _prefs.remove(_keySelectedLocation);
    await _prefs.remove('cached_customer_addresses');
    await _prefs.remove('cached_customer_notifications');
  }

  Future<void> saveCachedNotificationsJson(String jsonString) async {
    await _prefs.setString('cached_customer_notifications', jsonString);
  }

  String? getCachedNotificationsJson() => _prefs.getString('cached_customer_notifications');

  Future<void> clearCachedNotifications() async {
    await _prefs.remove('cached_customer_notifications');
  }

  // Cached User JSON
  Future<void> saveUserJson(String jsonString) async {
    await _prefs.setString(_keyCachedUser, jsonString);
  }

  String? getCachedUserJson() => _prefs.getString(_keyCachedUser);

  // Onboarding
  bool hasSeenOnboarding() => _prefs.getBool(_keyOnboardingSeen) ?? false;
  Future<void> setOnboardingSeen(bool seen) async {
    await _prefs.setBool(_keyOnboardingSeen, seen);
  }

  // Selected Location (Default: Migori Town, Migori)
  String getSelectedLocation() =>
      _prefs.getString(_keySelectedLocation) ?? 'Migori Town, Migori';

  Future<void> setSelectedLocation(String location) async {
    await _prefs.setString(_keySelectedLocation, location);
  }

  // Custom API URL
  String? getCustomApiUrl() => _prefs.getString(_keyCustomApiUrl);
  Future<void> setCustomApiUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      await _prefs.remove(_keyCustomApiUrl);
    } else {
      await _prefs.setString(_keyCustomApiUrl, url.trim());
    }
  }

  // Wishlist Storage
  String? getWishlistJson() => _prefs.getString(_keyWishlist);
  Future<void> saveWishlistJson(String json) => _prefs.setString(_keyWishlist, json);

  String? getCartJson() => _prefs.getString(_keyCart);
  Future<void> saveCartJson(String json) => _prefs.setString(_keyCart, json);
  Future<void> clearCart() => _prefs.remove(_keyCart);

  // Multi-cart sessions storage
  String? getCartSessionsJson() => _prefs.getString(_keyCartSessions);
  Future<void> saveCartSessionsJson(String json) => _prefs.setString(_keyCartSessions, json);
  Future<void> clearCartSessions() => _prefs.remove(_keyCartSessions);

  String? getActiveCartId() => _prefs.getString(_keyActiveCartId);
  Future<void> setActiveCartId(String id) => _prefs.setString(_keyActiveCartId, id);

  // Settings getters & setters
  bool get orderNotifications => _prefs.getBool(_keyOrderNotifications) ?? true;
  Future<void> setOrderNotifications(bool val) => _prefs.setBool(_keyOrderNotifications, val);

  bool get promoNotifications => _prefs.getBool(_keyPromoNotifications) ?? true;
  Future<void> setPromoNotifications(bool val) => _prefs.setBool(_keyPromoNotifications, val);

  bool get smsAlerts => _prefs.getBool(_keySmsAlerts) ?? false;
  Future<void> setSmsAlerts(bool val) => _prefs.setBool(_keySmsAlerts, val);

  bool get darkMode => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool val) => _prefs.setBool(_keyDarkMode, val);

  String get language => _prefs.getString(_keyLanguage) ?? 'en';
  Future<void> setLanguage(String lang) => _prefs.setString(_keyLanguage, lang);

  // Payment preference persistence
  static const String _keyDefaultPaymentMethod = 'setting_default_payment_method';
  static const String _keySavedMpesaPhone = 'setting_saved_mpesa_phone';

  String getDefaultPaymentMethod() => _prefs.getString(_keyDefaultPaymentMethod) ?? 'mpesa';
  Future<void> setDefaultPaymentMethod(String method) =>
      _prefs.setString(_keyDefaultPaymentMethod, method);

  String? getSavedMpesaPhone() => _prefs.getString(_keySavedMpesaPhone);
  Future<void> setSavedMpesaPhone(String phone) async {
    if (phone.trim().isEmpty) {
      await _prefs.remove(_keySavedMpesaPhone);
    } else {
      await _prefs.setString(_keySavedMpesaPhone, phone.trim());
    }
  }
}
