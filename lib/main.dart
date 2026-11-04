// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/splash/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock status bar to transparent dark icons for clean look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Storage & Networking
  final storage = await LocalStorage.create();

  // Initialize Environment Configuration (Development by default)
  AppConfig.initialize(
    env: AppEnvironment.development,
    customApiUrl: storage.getCustomApiUrl(),
  );

  final apiClient = ApiClient(storage: storage);
  final authService = AuthService(apiClient: apiClient, storage: storage);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
      ],
      child: BansiGoApp(
        initialRoute: authService.isAuthenticated ? const HomeScreen() : const SplashScreen(),
      ),
    ),
  );
}

class BansiGoApp extends StatelessWidget {
  final Widget initialRoute;

  const BansiGoApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BansiGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialRoute,
    );
  }
}
