// lib/main.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'features/address/providers/address_provider.dart';
import 'features/address/services/address_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/catalogue/providers/catalogue_provider.dart';
import 'features/catalogue/services/catalogue_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/orders/providers/order_provider.dart';
import 'features/orders/services/order_service.dart';
import 'features/recommendations/providers/recommendation_provider.dart';
import 'features/recommendations/services/recommendation_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/wishlist/providers/wishlist_provider.dart';
import 'features/wishlist/services/wishlist_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide Samsung & Android system functionalities (notifications bar; bottom back, home, and active apps)
  // for a clean, immersive full-screen application experience
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Storage & Networking
  final storage = await LocalStorage.create();

  // Initialize Environment Configuration (Development by default)
  var customApiUrl = storage.getCustomApiUrl();
  if (customApiUrl != null &&
      customApiUrl.trim().isNotEmpty &&
      customApiUrl.trim() != AppConfig.defaultWifiUrl) {
    final customReachable = await _isHostReachable(customApiUrl);
    if (!customReachable && await _isHostReachable(AppConfig.defaultWifiUrl)) {
      AppLogger.w(
        'Saved server URL ($customApiUrl) is unreachable; switching to ${AppConfig.defaultWifiUrl}',
      );
      await storage.setCustomApiUrl(null);
      customApiUrl = null;
    }
  }

  AppConfig.initialize(
    env: AppEnvironment.development,
    customApiUrl: customApiUrl,
  );

  final apiClient = ApiClient(storage: storage);
  final authService = AuthService(apiClient: apiClient, storage: storage);
  final addressService = AddressService(apiClient: apiClient, storage: storage);
  final wishlistService = WishlistService(storage, apiClient: apiClient);
  final customerOrderService = CustomerOrderService(apiClient);
  final catalogueService = CatalogueService(apiClient);
  final notificationService = NotificationService(apiClient, storage: storage);
  final recommendationService = RecommendationService(apiClient);

  final authProvider = AuthProvider(authService);
  final addressProvider = AddressProvider(addressService: addressService);
  final wishlistProvider = WishlistProvider(wishlistService);
  final orderProvider = OrderProvider(customerOrderService);
  final notificationProvider = NotificationProvider(notificationService);

  apiClient.onUnauthorized = () {
    authProvider.handleSessionExpired();
  };

  if (authService.isAuthenticated) {
    authProvider.validateSession();
    orderProvider.loadOrders();
    wishlistProvider.loadWishlist();
  }

  // Address, order, wishlist & notification reset on logout to prevent leaks, and sync on login/register
  authProvider.onLogoutCallback = () async {
    orderProvider.clearOnLogout();
    await wishlistProvider.clearOnLogout();
    await notificationProvider.resetOnLogout();
    await addressProvider.resetOnLogout();
  };
  authProvider.onAuthSuccessCallback = () async {
    orderProvider.loadOrders();
    await wishlistProvider.syncOnLogin();
    await notificationProvider.loadNotifications();
    await addressProvider.loadData();
  };

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: storage),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: addressProvider),
        ChangeNotifierProvider.value(value: wishlistProvider),
        ChangeNotifierProvider.value(
          value: orderProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogueProvider(catalogueService),
        ),
        ChangeNotifierProvider.value(
          value: notificationProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationProvider(recommendationService),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(storage),
        ),
      ],
      child: BansiGoApp(
        initialRoute: authService.isAuthenticated ? const HomeScreen() : const SplashScreen(),
      ),
    ),
  );
}

Future<bool> _isHostReachable(String baseUrl) async {
  try {
    final uri = Uri.parse(baseUrl.trim());
    if (uri.host.isEmpty) return false;
    final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
    final socket = await Socket.connect(
      uri.host,
      port,
      timeout: const Duration(milliseconds: 1200),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

class BansiGoApp extends StatefulWidget {
  final Widget initialRoute;

  const BansiGoApp({super.key, required this.initialRoute});

  @override
  State<BansiGoApp> createState() => _BansiGoAppState();
}

class _BansiGoAppState extends State<BansiGoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BansiGo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: widget.initialRoute,
    );
  }
}