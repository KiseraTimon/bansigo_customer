// test/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/auth/providers/auth_provider.dart';
import 'package:bansigo_customer/features/auth/services/auth_service.dart';
import 'package:bansigo_customer/features/cart/providers/cart_provider.dart';
import 'package:bansigo_customer/features/catalogue/providers/catalogue_provider.dart';
import 'package:bansigo_customer/features/catalogue/services/catalogue_service.dart';
import 'package:bansigo_customer/features/address/providers/address_provider.dart';
import 'package:bansigo_customer/features/address/services/address_service.dart';
import 'package:bansigo_customer/features/notifications/providers/notification_provider.dart';
import 'package:bansigo_customer/features/notifications/services/notification_service.dart';
import 'package:bansigo_customer/features/recommendations/providers/recommendation_provider.dart';
import 'package:bansigo_customer/features/recommendations/services/recommendation_service.dart';
import 'package:bansigo_customer/features/home/screens/home_screen.dart';
import 'package:bansigo_customer/features/home/widgets/category_slider.dart';
import 'package:bansigo_customer/features/home/widgets/location_selector.dart';

void main() {
  testWidgets('HomeScreen renders all requested sections and elements correctly', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.development);
    final apiClient = ApiClient(storage: storage);
    final authService = AuthService(apiClient: apiClient, storage: storage);
    final authProvider = AuthProvider(authService);
    final catalogueService = CatalogueService(apiClient);
    final catalogueProvider = CatalogueProvider(catalogueService);
    final notificationService = NotificationService(apiClient);
    final notificationProvider = NotificationProvider(notificationService);
    final addressService = AddressService(apiClient: apiClient, storage: storage);
    final addressProvider = AddressProvider(addressService: addressService);
    final recommendationService = RecommendationService(apiClient);
    final recommendationProvider = RecommendationProvider(recommendationService);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CatalogueProvider>.value(value: catalogueProvider),
          ChangeNotifierProvider<NotificationProvider>.value(value: notificationProvider),
          ChangeNotifierProvider<AddressProvider>.value(value: addressProvider),
          ChangeNotifierProvider<RecommendationProvider>.value(value: recommendationProvider),
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider(storage)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header with BansiGo & notification
    expect(find.text('BansiGo'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // 2. Location selector & note
    expect(find.text('Your Location'), findsOneWidget);
    expect(find.byType(LocationSelector), findsOneWidget);

    // 3. Search Bar
    expect(find.text('Search Anything'), findsOneWidget);

    // 4. Horizontal Category Slider with requested categories
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pharmacy'), findsOneWidget);
    expect(find.text('Bakery'), findsOneWidget);
    expect(find.text('Deli'), findsOneWidget);

    // Scroll category slider to verify remaining categories
    await tester.drag(find.byType(CategorySlider), const Offset(-450, 0), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Drinks'), findsOneWidget);
    expect(find.text('Electronics'), findsOneWidget);
    expect(find.text('Furniture'), findsOneWidget);

    // 5. Advert banner
    expect(find.text('Fresh Farm Harvest'), findsOneWidget);

    // 6. Grocery grid of 6
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Fresh Produce'), findsOneWidget);
    expect(find.text('Dairy & Bread'), findsOneWidget);
    expect(find.text('Spices'), findsOneWidget);
    expect(find.text('Drinks & Juices'), findsOneWidget);
    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Ice Creams & More'), findsOneWidget);

    // 7. Fresh Grocery section
    expect(find.text('Fresh Grocery'), findsOneWidget);

    // 8. Inspo Footer Navigation with menu button
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);

    // Scroll down to check further sections
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    // 9. Spotlight section
    expect(find.text('Spotlight Deal'), findsOneWidget);
    expect(find.text('Pure Kenyan Highland Wild Honey'), findsOneWidget);

    // 10. Household Essentials
    expect(find.text('Household Essentials'), findsOneWidget);

    // 11. Snacks & Munchies
    expect(find.text('Snacks & Munchies'), findsOneWidget);

    // 12. Featured & Best Sellers
    expect(find.text('Featured & Best Sellers'), findsOneWidget);

    // Scroll further down
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1800));
    await tester.pumpAndSettle();

    // 13. Shop section
    expect(find.text('Shop by Aisle & Store'), findsOneWidget);

    // 14. Redirection to Explore page card
    expect(find.text('Looking for something else?'), findsOneWidget);
    expect(find.text('Explore Full Catalog'), findsOneWidget);

    // Tap Explore Full Catalog button at end of page
    await tester.tap(find.text('Explore Full Catalog'));
    await tester.pumpAndSettle();

    // Verify it navigated to Explore tab view
    expect(find.text('Explore Store Aisles'), findsOneWidget);
  });
}
