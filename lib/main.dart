// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
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
  AppConfig.initialize(
    env: AppEnvironment.development,
    customApiUrl: storage.getCustomApiUrl(),
  );

  final apiClient = ApiClient(storage: storage);
  final authService = AuthService(apiClient: apiClient, storage: storage);
  final addressService = AddressService(apiClient: apiClient, storage: storage);
  final wishlistService = WishlistService(storage);
  final customerOrderService = CustomerOrderService(apiClient);
  final catalogueService = CatalogueService(apiClient);
  final notificationService = NotificationService(apiClient);
  final recommendationService = RecommendationService(apiClient);

  final authProvider = AuthProvider(authService);
  final addressProvider = AddressProvider(addressService: addressService);

  // Address reset on logout to prevent address leaks, and user addresses sync on login/register
  authProvider.onLogoutCallback = () async => await addressProvider.resetOnLogout();
  authProvider.onAuthSuccessCallback = () async => await addressProvider.loadData();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: storage),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: addressProvider),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(wishlistService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(customerOrderService),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogueProvider(catalogueService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService),
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