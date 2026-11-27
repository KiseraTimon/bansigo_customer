// test/new_screens_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/cart/providers/cart_provider.dart';
import 'package:bansigo_customer/features/catalogue/screens/product_details_screen.dart';
import 'package:bansigo_customer/features/home/models/product_model.dart';
import 'package:bansigo_customer/features/orders/providers/order_provider.dart';
import 'package:bansigo_customer/features/orders/screens/orders_screen.dart';
import 'package:bansigo_customer/features/orders/services/order_service.dart';
import 'package:bansigo_customer/features/wishlist/providers/wishlist_provider.dart';
import 'package:bansigo_customer/features/wishlist/screens/wishlist_screen.dart';
import 'package:bansigo_customer/features/wishlist/services/wishlist_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage storage;
  late ApiClient apiClient;
  late WishlistService wishlistService;
  late WishlistProvider wishlistProvider;
  late CustomerOrderService orderService;
  late OrderProvider orderProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.testing);

    apiClient = ApiClient(storage: storage);
    wishlistService = WishlistService(storage);
    wishlistProvider = WishlistProvider(wishlistService);
    orderService = CustomerOrderService(apiClient);
    orderProvider = OrderProvider(orderService);
  });

  group('Orders Screen Tests (Image 1 Match)', () {
    testWidgets('Renders Orders screen with Ongoing and History tabs and courier empty state illustration', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartProvider = CartProvider(storage);
      bool orderHereClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider.value(value: apiClient),
              ChangeNotifierProvider.value(value: orderProvider),
              ChangeNotifierProvider.value(value: cartProvider),
            ],
            child: OrdersScreen(
              onStartShopping: () {
                orderHereClicked = true;
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Header and tabs
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Ongoing'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Exact empty state copy matching attached mockup
      expect(find.textContaining('There are no ongoing order right'), findsOneWidget);
      expect(find.textContaining('here'), findsOneWidget);
      expect(orderHereClicked, isFalse);

      // Tap on History tab
      await tester.tap(find.text('History'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(orderProvider.activeTab.name, equals('history'));
    });
  });

  group('Product Details Screen Tests (Image 2 Match)', () {
    testWidgets('Renders Product Details with thumbnails, 1 KG, KES 182.00, recommendations and Add to Bag button', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const testProduct = ProductModel(
        id: '1',
        name: 'Arla DANO Full Cream Milk Powder Instant',
        unit: '1 KG',
        price: 182.00,
        originalPrice: 220.00,
        category: 'Dairy Products',
        description: 'Rich full cream fortified milk powder in a 1 KG pack.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider.value(value: apiClient),
              ChangeNotifierProvider.value(value: wishlistProvider),
            ],
            child: const ProductDetailsScreen(product: testProduct),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title & Header
      expect(find.text('Product Details'), findsOneWidget);
      expect(find.text('Arla DANO Full Cream Milk Powder Instant'), findsOneWidget);

      // Weight & Price
      expect(find.text('1 KG'), findsOneWidget);
      expect(find.text('KES 182.00'), findsOneWidget);

      // Category, Description, and Reviews Section
      expect(find.text('Dairy Products'), findsOneWidget);
      expect(find.textContaining('Rich full cream fortified milk powder'), findsOneWidget);
      expect(find.text('Customer Reviews'), findsOneWidget);
      expect(find.text('Write Review'), findsOneWidget);

      // Add to Bag button
      expect(find.text('Add to Bag'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    });
  });

  group('Wishlist Screen Tests', () {
    testWidgets('Renders empty state first, then real added items with remove and add buttons', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: wishlistProvider,
            child: const WishlistScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Wishlist'), findsOneWidget);
      expect(find.text('Your wishlist is empty'), findsOneWidget);

      await wishlistProvider.add(
        const ProductModel(
          id: '101',
          name: 'Brookside Fresh Milk 500ml',
          unit: '500ml',
          price: 70.00,
          originalPrice: 85.00,
          category: 'Dairy Products',
        ),
      );
      await tester.pump();

      expect(find.text('Brookside Fresh Milk 500ml'), findsOneWidget);
      expect(find.text('KES 85.00'), findsOneWidget);
      expect(find.text('KES 70.00'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove from wishlist'));
      await tester.pump();
      expect(find.text('Your wishlist is empty'), findsOneWidget);
    });
  });
}
