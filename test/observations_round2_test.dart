// test/observations_round2_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/address/providers/address_provider.dart';
import 'package:bansigo_customer/features/address/services/address_service.dart';
import 'package:bansigo_customer/features/auth/models/user_model.dart';
import 'package:bansigo_customer/features/auth/providers/auth_provider.dart';
import 'package:bansigo_customer/features/auth/services/auth_service.dart';
import 'package:bansigo_customer/features/cart/providers/cart_provider.dart';
import 'package:bansigo_customer/features/orders/models/order_model.dart';
import 'package:bansigo_customer/features/orders/screens/sections/order_card_item.dart';
import 'package:bansigo_customer/shared/widgets/email_verification_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppConfig.initialize(env: AppEnvironment.testing);
  });

  group('Observation 1: Address Reset on Logout & Live GPS Fallback Tests', () {
    test('AddressProvider.resetOnLogout clears selected address and cache', () async {
      SharedPreferences.setMockInitialValues({
        'cached_customer_addresses': '[{"id":1,"label":"Home","recipient_name":"User A","recipient_phone":"+254711223344","area":"OMK","street_address":"Migori","latitude":-1.0612,"longitude":34.4741,"is_default":true}]',
        'selected_location': 'OMK, Migori',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final apiClient = ApiClient(storage: storage);
      final addressService = AddressService(apiClient: apiClient, storage: storage);
      final addressProvider = AddressProvider(addressService: addressService);

      // Verify initial state had address
      expect(storage.prefs.containsKey('cached_customer_addresses'), isTrue);

      // Trigger reset on logout
      await addressProvider.resetOnLogout();

      // State should be cleared
      expect(addressProvider.selectedAddress, isNull);
      expect(addressProvider.addresses, isEmpty);
      expect(storage.prefs.containsKey('cached_customer_addresses'), isFalse);
    });

    test('AuthProvider.onLogoutCallback triggers address reset', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'test_token',
        'cached_user': '{"id":1,"first_name":"Jane","last_name":"Doe","email":"jane@test.com","is_verified":false}',
        'cached_customer_addresses': '[]',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final apiClient = ApiClient(storage: storage);
      final authService = AuthService(apiClient: apiClient, storage: storage);
      final authProvider = AuthProvider(authService);
      final addressService = AddressService(apiClient: apiClient, storage: storage);
      final addressProvider = AddressProvider(addressService: addressService);

      bool resetCallbackCalled = false;
      authProvider.onLogoutCallback = () async {
        resetCallbackCalled = true;
        await addressProvider.resetOnLogout();
      };

      await authProvider.logout();

      expect(resetCallbackCalled, isTrue);
      expect(authProvider.currentUser, isNull);
      expect(addressProvider.selectedAddress, isNull);
    });
  });

  group('Observation 2: Email Verification Warning & Enforcement Tests', () {
    testWidgets('EmailVerificationBanner displays warning when user email is unverified', (tester) async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'valid_token',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final apiClient = ApiClient(storage: storage);
      final authService = AuthService(apiClient: apiClient, storage: storage);

      // Mock unverified user
      final unverifiedUser = UserModel(
        id: 10,
        firstName: 'John',
        lastName: 'Unverified',
        username: 'johnunverified',
        email: 'john@example.com',
        phone: '+254712345678',
        role: 'customer',
        isVerified: false,
      );
      await authService.saveUser(unverifiedUser);
      final authProvider = AuthProvider(authService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Email verification is required before placing orders.'), findsOneWidget);
      expect(find.text('Verify'), findsOneWidget);
    });

    testWidgets('EmailVerificationBanner hides when user is verified', (tester) async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'valid_token',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final apiClient = ApiClient(storage: storage);
      final authService = AuthService(apiClient: apiClient, storage: storage);
      final authProvider = AuthProvider(authService);

      // Mock verified user
      final verifiedUser = UserModel(
        id: 11,
        firstName: 'Mary',
        lastName: 'Verified',
        username: 'maryverified',
        email: 'mary@example.com',
        phone: '+254712345679',
        role: 'customer',
        isVerified: true,
      );
      await authService.saveUser(verifiedUser);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EmailVerificationBanner(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsNothing);
    });
  });

  group('Observation 3: Ongoing Order Actions (Pay Now, Edit, Append, Cancel) Tests', () {
    testWidgets('OrderCardItem renders Complete Payment button and popup menu for pending order', (tester) async {
      final pendingOrder = CustomerOrderModel(
        id: 101,
        orderNumber: 'ORD-101',
        status: 'pending_payment',
        paymentStatus: 'pending',
        paymentMethod: 'mpesa',
        fulfilmentType: 'delivery',
        total: 250.0,
        createdAt: DateTime.now(),
      );

      bool payNowCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrderCardItem(
              order: pendingOrder,
              onPayNow: () => payNowCalled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Complete Payment'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);

      await tester.tap(find.text('Complete Payment'));
      await tester.pump();
      expect(payNowCalled, isTrue);
    });

    test('CartProvider.loadOrderItemsIntoCart creates dedicated session for editing', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final cart = CartProvider(storage);

      final orderLines = [
        {
          'product_id': 1,
          'product_name': 'Fresh Milk',
          'unit_price': 80.0,
          'quantity': 2,
          'unit': 'piece',
        },
        {
          'product_id': 2,
          'product_name': 'Brown Bread',
          'unit_price': 65.0,
          'quantity': 1,
          'unit': 'piece',
        },
      ];

      final session = cart.loadOrderItemsIntoCart(
        items: orderLines,
        sessionName: 'Edit Order #ORD-101',
        createDedicatedSession: true,
      );

      expect(session.name, 'Edit Order #ORD-101');
      expect(session.itemCount, 2);
      expect(session.totalQuantity, 3);
      expect(session.subtotal, 225.0); // 80*2 + 65*1 = 225
    });

    test('CartProvider.loadOrderItemsIntoCart appends items to current session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final cart = CartProvider(storage);

      final initialCount = cart.itemCount;

      final orderLines = [
        {
          'product_id': 99,
          'product_name': 'Mineral Water',
          'unit_price': 50.0,
          'quantity': 3,
          'unit': 'piece',
        },
      ];

      cart.loadOrderItemsIntoCart(
        items: orderLines,
        createDedicatedSession: false,
      );

      expect(cart.itemCount, initialCount + 1);
      expect(cart.getQuantity('99'), 3);
    });
  });
}
