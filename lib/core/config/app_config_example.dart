// lib/core/config/app_config.dart

enum AppEnvironment {
  development,
  testing,
  production,
}

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String googleClientId;
  final String facebookAppId;
  final bool enableLogging;

  // Preset URLs for convenient switching
  static const String defaultWifiUrl = '';
  static const String emulatorUrl = '';
  static const String localhostUrl = '';

  // Google OAuth Web / Server Client ID matching bansigo-customer project
  static const String defaultGoogleClientId =
      '';

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 25),
    this.receiveTimeout = const Duration(seconds: 25),
    this.googleClientId = defaultGoogleClientId,
    this.facebookAppId = '',
    this.enableLogging = true,
  });

  static late AppConfig current;

  AppConfig copyWith({
    AppEnvironment? environment,
    String? apiBaseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    String? googleClientId,
    String? facebookAppId,
    bool? enableLogging,
  }) {
    return AppConfig(
      environment: environment ?? this.environment,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      googleClientId: googleClientId ?? this.googleClientId,
      facebookAppId: facebookAppId ?? this.facebookAppId,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }

  static void setCustomApiBaseUrl(String url) {
    current = current.copyWith(apiBaseUrl: url.trim());
  }

  /// Default development configuration pointing to FastAPI server
  /// Defaults to developer PC Wi-Fi IP (192.168.100.10:8000) for external mobile phone connectivity
  static AppConfig get development => const AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: defaultWifiUrl,
        ),
        googleClientId: String.fromEnvironment(
          'GOOGLE_CLIENT_ID',
          defaultValue: defaultGoogleClientId,
        ),
        facebookAppId: String.fromEnvironment('FACEBOOK_APP_ID', defaultValue: ''),
        connectTimeout: Duration(seconds: 25),
        receiveTimeout: Duration(seconds: 25),
        enableLogging: true,
      );

  static AppConfig get testing => const AppConfig(
        environment: AppEnvironment.testing,
        apiBaseUrl: '',
        googleClientId: 'test-google-id',
        facebookAppId: 'test-facebook-id',
        enableLogging: true,
      );

  static AppConfig get production => const AppConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: '',
        ),
        googleClientId: String.fromEnvironment(
          'GOOGLE_CLIENT_ID',
          defaultValue: defaultGoogleClientId,
        ),
        facebookAppId: String.fromEnvironment('FACEBOOK_APP_ID', defaultValue: ''),
        enableLogging: false,
      );

  static void initialize({AppEnvironment env = AppEnvironment.development, String? customApiUrl}) {
    switch (env) {
      case AppEnvironment.development:
        current = development;
        break;
      case AppEnvironment.testing:
        current = testing;
        break;
      case AppEnvironment.production:
        current = production;
        break;
    }
    if (customApiUrl != null && customApiUrl.trim().isNotEmpty) {
      setCustomApiBaseUrl(customApiUrl);
    }
  }
}
