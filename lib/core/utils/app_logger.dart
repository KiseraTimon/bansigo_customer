// lib/core/utils/app_logger.dart

import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AppLogger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode && AppConfig.current.enableLogging) {
      debugPrint('[DEBUG] [BansiGo] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }

  static void i(String message) {
    if (kDebugMode && AppConfig.current.enableLogging) {
      debugPrint('[INFO] [BansiGo] $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      debugPrint('[WARN] [BansiGo] $message');
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] [BansiGo] $message');
    if (error != null) debugPrint('Exception: $error');
    if (stackTrace != null) debugPrint('$stackTrace');
  }
}
