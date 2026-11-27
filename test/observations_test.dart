// test/observations_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/address/models/address_model.dart';
import 'package:bansigo_customer/features/address/providers/address_provider.dart';
import 'package:bansigo_customer/features/address/services/address_service.dart';
import 'package:bansigo_customer/features/cart/providers/cart_provider.dart';
import 'package:bansigo_customer/features/home/models/product_model.dart';
import 'package:bansigo_customer/features/orders/models/order_model.dart';
import 'package:bansigo_customer/features/orders/providers/order_provider.dart';
import 'package:bansigo_customer/features/orders/screens/orders_screen.dart';
import 'package:bansigo_customer/features/orders/screens/sections/ongoing_cart_card.dart';
import 'package:bansigo_customer/features/orders/screens/sections/order_card_item.dart';
import 'package:bansigo_customer/features/orders/services/order_service.dart';
import 'package:bansigo_customer/shared/widgets/select_cart_bottom_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage storage;
  late ApiClient apiClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.testing);
    apiClient = ApiClient(storage: storage);
  });

  group('Observation 1 & 4: Address Formatting & Location Display', () {
    test('AddressModel.displayAddress deduplicates tokens and formats as Location, County', () {
      // Case 1: Duplicated token "OMK" in street and area with instructions
      final addr1 = AddressModel(
        id: 1,
        label: 'Home',
        recipientName: 'Jane Doe',
        recipientPhone: '+254712345678',
        zoneId: 1,
        area: 'OMK',
        streetAddress: 'OMK',
        landmark: 'Opposite stage',
        directions: 'Black gate ring bell',
        latitude: -1.0634,
        longitude: 34.4731,
      );

      // Must be "OMK, Migori" without duplicates or instructions
      expect(addr1.displayAddress, equals('OMK, Migori'));
      expect(addr1.displayAddress.contains('Opposite'), isFalse);
      expect(addr1.displayAddress.contains('Black gate'), isFalse);

      // Case 2: Area already includes Migori
      final addr2 = AddressModel(
        id: 2,
        label: 'Office',
        recipientName: 'Jane Doe',
        recipientPhone: '+254712345678',
        zoneId: 1,
        area: 'Nyasare, Migori',
        latitude: -1.0634,
        longitude: 34.4731,
      );
      expect(addr2.displayAddress, equals('Nyasare, Migori'));

      // Case 3: Verify "Wasweta 1" placeholder is not in default location
      expect(storage.getSelectedLocation().contains('Wasweta 1'), isFalse);
    });

    test('AddressProvider default location falls back to GPS display without Wasweta', () {
      final addressService = AddressService(apiClient: apiClient, storage: storage);
      final addressProvider = AddressProvider(addressService: addressService);

      final display = addressProvider.currentDisplayLocation;
      expect(display.contains('Wasweta 1'), isFalse);
    });
  });

  group('Observation 2: Multi-Cart Ongoing Sessions & Persistence', () {
    test('CartProvider supports multiple ongoing carts and persistence', () async {
      final cartProvider = CartProvider(storage);

      final testProduct1 = ProductModel(
        id: '101',
        name: 'Fresh Whole Milk 500ml',
        price: 65.0,
        imageUrl: '',
        category: 'dairy',
        unit: '500ml',
      );

      final testProduct2 = ProductModel(
        id: '102',
        name: 'Artisan Sourdough Loaf',
        price: 120.0,
        imageUrl: '',
        category: 'bakery',
        unit: '1 loaf',
      );

      // Cart 1: Add product 1
      cartProvider.addItem(testProduct1, quantity: 2);
      expect(cartProvider.itemCount, equals(1));
      expect(cartProvider.totalQuantity, equals(2));
      expect(cartProvider.subtotal, equals(130.0));

      // Create Cart 2: Add product 2
      final cart2 = cartProvider.createNewSession(name: 'Office Cart');
      expect(cartProvider.sessions.length, equals(2));
      expect(cartProvider.activeSessionId, equals(cart2.id));

      cartProvider.addItem(testProduct2, quantity: 1);
      expect(cartProvider.itemCount, equals(1));
      expect(cartProvider.subtotal, equals(120.0));

      // Both carts should be active sessions with items
      expect(cartProvider.activeSessionsWithItems.length, equals(2));

      // Verify persistence across new CartProvider instance
      final restoredProvider = CartProvider(storage);
      expect(restoredProvider.sessions.length, equals(2));
      expect(restoredProvider.activeSessionsWithItems.length, equals(2));
      expect(restoredProvider.activeSessionsWithItems[0].items.containsKey('101'), isTrue);
      expect(restoredProvider.activeSessionsWithItems[1].items.containsKey('102'), isTrue);
    });

    testWidgets('OrdersScreen renders ongoing cart cards immediately when items are in bag', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartProvider = CartProvider(storage);
      final orderService = CustomerOrderService(apiClient);
      final orderProvider = OrderProvider(orderService);

      final testProduct = ProductModel(
        id: '101',
        name: 'Fresh Whole Milk 500ml',
        price: 65.0,
        imageUrl: '',
        category: 'dairy',
        unit: '500ml',
      );

      cartProvider.addItem(testProduct, quantity: 3);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider.value(value: apiClient),
              ChangeNotifierProvider.value(value: orderProvider),
              ChangeNotifierProvider.value(value: cartProvider),
            ],
            child: const OrdersScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Cart card must be visible on Ongoing tab before checkout!
      expect(find.byType(OngoingCartCard), findsOneWidget);
      expect(find.text('IN CART • PENDING CHECKOUT'), findsOneWidget);
      expect(find.text('KES 195.00'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
    });

    testWidgets('SelectCartBottomSheet displays ongoing carts and option to create new cart', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final cartProvider = CartProvider(storage);
      final testProduct = ProductModel(
        id: '101',
        name: 'Avocado Pack',
        price: 150.0,
        imageUrl: '',
        category: 'vegetables',
        unit: '1 pack',
      );

      // Create an ongoing cart session with items
      cartProvider.addItem(testProduct, quantity: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: cartProvider,
            child: Scaffold(
              body: SelectCartBottomSheet(product: testProduct),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Cart to Update'), findsOneWidget);
      expect(find.text('Create a New Ongoing Cart'), findsOneWidget);
      expect(find.text('Add Here'), findsOneWidget);
    });
  });

  group('Observation 3: Overflow Prevention', () {
    testWidgets('OrderCardItem handles long order numbers and PENDING PAYMENT status without overflow', (tester) async {
      // Simulate narrow mobile screen (360px wide)
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final order = CustomerOrderModel(
        id: 99999,
        orderNumber: 'ORD-20261106-MIGORI-EXTRALONG-99999',
        status: 'pending_payment',
        paymentStatus: 'pending',
        paymentMethod: 'mpesa',
        fulfilmentType: 'delivery',
        total: 1250.0,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCardItem(order: order),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow exceptions thrown!
      expect(find.text('PENDING PAYMENT'), findsOneWidget);
      expect(find.text('KES 1250.00'), findsOneWidget);
    });
  });
}
