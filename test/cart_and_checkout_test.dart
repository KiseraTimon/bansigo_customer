// test/cart_and_checkout_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/address/providers/address_provider.dart';
import 'package:bansigo_customer/features/address/services/address_service.dart';
import 'package:bansigo_customer/features/auth/providers/auth_provider.dart';
import 'package:bansigo_customer/features/auth/services/auth_service.dart';
import 'package:bansigo_customer/features/cart/providers/cart_provider.dart';
import 'package:bansigo_customer/features/checkout/screens/checkout_screen.dart';
import 'package:bansigo_customer/features/home/models/product_model.dart';
import 'package:bansigo_customer/features/orders/services/order_service.dart';
import 'package:bansigo_customer/shared/widgets/floating_cart_bar.dart';

void main() {
  late LocalStorage storage;
  late ApiClient apiClient;
  late AuthService authService;
  late AuthProvider authProvider;
  late AddressService addressService;
  late AddressProvider addressProvider;
  late CustomerOrderService orderService;
  late CartProvider cartProvider;

  final sampleProduct1 = const ProductModel(
    id: 'prod_1',
    name: 'Fresh Whole Milk 500ml',
    price: 65.0,
    originalPrice: 70.0,
    category: 'dairy-eggs',
    inStock: true,
    unit: '500ml',
  );

  final sampleProduct2 = const ProductModel(
    id: 'prod_2',
    name: 'Artisan Sliced Bread',
    price: 85.0,
    originalPrice: 90.0,
    category: 'bakery-pastries',
    inStock: true,
    unit: '400g',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.testing);
    apiClient = ApiClient(storage: storage);
    authService = AuthService(apiClient: apiClient, storage: storage);
    authProvider = AuthProvider(authService);
    addressService = AddressService(apiClient: apiClient, storage: storage);
    addressProvider = AddressProvider(addressService: addressService);
    orderService = CustomerOrderService(apiClient);
    cartProvider = CartProvider(storage);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AddressProvider>.value(value: addressProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        Provider<CustomerOrderService>.value(value: orderService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [child],
          ),
        ),
      ),
    );
  }

  group('CartProvider Unit Tests', () {
    test('starts empty and calculates totals accurately', () {
      expect(cartProvider.isEmpty, isTrue);
      expect(cartProvider.itemCount, 0);
      expect(cartProvider.totalQuantity, 0);
      expect(cartProvider.subtotal, 0.0);
    });

    test('adds items and updates quantities & subtotal', () {
      cartProvider.addItem(sampleProduct1, quantity: 2);
      expect(cartProvider.isEmpty, isFalse);
      expect(cartProvider.itemCount, 1);
      expect(cartProvider.totalQuantity, 2);
      expect(cartProvider.subtotal, 130.0);

      cartProvider.addItem(sampleProduct2, quantity: 1);
      expect(cartProvider.itemCount, 2);
      expect(cartProvider.totalQuantity, 3);
      expect(cartProvider.subtotal, 215.0);
    });

    test('increments, decrements, and removes items properly', () {
      cartProvider.addItem(sampleProduct1, quantity: 2);
      cartProvider.incrementItem(sampleProduct1.id);
      expect(cartProvider.getQuantity(sampleProduct1.id), 3);

      cartProvider.decrementItem(sampleProduct1.id);
      expect(cartProvider.getQuantity(sampleProduct1.id), 2);

      cartProvider.decrementItem(sampleProduct1.id);
      cartProvider.decrementItem(sampleProduct1.id);
      expect(cartProvider.contains(sampleProduct1.id), isFalse);
      expect(cartProvider.isEmpty, isTrue);
    });

    test('clear removes all items', () {
      cartProvider.addItem(sampleProduct1, quantity: 3);
      cartProvider.addItem(sampleProduct2, quantity: 2);
      expect(cartProvider.isEmpty, isFalse);

      cartProvider.clear();
      expect(cartProvider.isEmpty, isTrue);
      expect(cartProvider.subtotal, 0.0);
    });
  });

  group('FloatingCartBar Widget Tests', () {
    testWidgets('renders nothing when cart is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(const FloatingCartBar()));
      expect(find.byType(FloatingCartBar), findsOneWidget);
      expect(find.text('View Cart'), findsNothing);
    });

    testWidgets('renders bar with total and items counter when items added', (tester) async {
      cartProvider.addItem(sampleProduct1, quantity: 2);
      await tester.pumpWidget(createTestWidget(const FloatingCartBar()));
      await tester.pumpAndSettle();

      expect(find.text('2 items in basket'), findsOneWidget);
      expect(find.textContaining('KES 130.00'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
    });
  });

  group('CheckoutScreen Widget Tests', () {
    testWidgets('renders delivery destination, cart items, bill summary, and checkout actions', (tester) async {
      cartProvider.addItem(sampleProduct1, quantity: 2);
      cartProvider.addItem(sampleProduct2, quantity: 1);

      await tester.pumpWidget(createTestWidget(const CheckoutScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsWidgets);
      expect(find.text('Delivery Destination'), findsOneWidget);
      expect(find.text('Basket Items (3)'), findsOneWidget);
      expect(find.text('Fresh Whole Milk 500ml'), findsOneWidget);
      expect(find.text('Artisan Sliced Bread'), findsOneWidget);
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.textContaining('via M-Pesa'), findsOneWidget);
    });
  });
}
