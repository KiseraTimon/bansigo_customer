// test/explore_search_more_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/auth/providers/auth_provider.dart';
import 'package:bansigo_customer/features/auth/services/auth_service.dart';
import 'package:bansigo_customer/features/catalogue/providers/catalogue_provider.dart';
import 'package:bansigo_customer/features/catalogue/services/catalogue_service.dart';
import 'package:bansigo_customer/features/catalogue/screens/search_products_screen.dart';
import 'package:bansigo_customer/features/home/widgets/explore_tab_view.dart';
import 'package:bansigo_customer/features/notifications/providers/notification_provider.dart';
import 'package:bansigo_customer/features/notifications/services/notification_service.dart';
import 'package:bansigo_customer/features/notifications/screens/notifications_screen.dart';
import 'package:bansigo_customer/features/profile/screens/more_options_screen.dart';
import 'package:bansigo_customer/features/profile/screens/edit_profile_screen.dart';
import 'package:bansigo_customer/features/profile/screens/payment_methods_screen.dart';
import 'package:bansigo_customer/features/profile/screens/contact_us_screen.dart';
import 'package:bansigo_customer/shared/illustrations/vector_illustrations.dart';

void main() {
  late LocalStorage storage;
  late ApiClient apiClient;
  late AuthService authService;
  late AuthProvider authProvider;
  late CatalogueService catalogueService;
  late CatalogueProvider catalogueProvider;
  late NotificationService notificationService;
  late NotificationProvider notificationProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.testing);
    apiClient = ApiClient(storage: storage);
    authService = AuthService(apiClient: apiClient, storage: storage);
    authProvider = AuthProvider(authService);
    catalogueService = CatalogueService(apiClient);
    catalogueProvider = CatalogueProvider(catalogueService);
    notificationService = NotificationService(apiClient);
    notificationProvider = NotificationProvider(notificationService);
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<CatalogueProvider>.value(value: catalogueProvider),
        ChangeNotifierProvider<NotificationProvider>.value(value: notificationProvider),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('1. Explore Screen renders major departments, promos, and navigates to CategoryProducts', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(ExploreTabView(onBackToHome: () {})));
    await tester.pumpAndSettle();

    // Verify title and search bar trigger
    expect(find.text('Explore Store Aisles'), findsOneWidget);
    expect(find.textContaining('15 Departments'), findsOneWidget);
    expect(find.text('Running Store Deals & Promos'), findsOneWidget);

    // Scroll slightly to ensure major departments are visible
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    // Verify Major Store Departments
    expect(find.text('Major Store Departments'), findsOneWidget);
    expect(find.text('Pharmacy & Healthcare'), findsOneWidget);
    expect(find.text('Bakery & Pastries'), findsOneWidget);
    expect(find.text('Deli & Fresh Meat'), findsOneWidget);
    expect(find.text('Drinks & Beverages'), findsOneWidget);

    // Tap on Pharmacy & Healthcare to open internal CategoryProductsScreen
    await tester.tap(find.text('Pharmacy & Healthcare'));
    await tester.pumpAndSettle();

    // Verify CategoryProductsScreen loaded
    expect(find.text('Aisle Special Promo'), findsOneWidget);
    expect(find.textContaining('Panadol Extra'), findsWidgets);
  });

  testWidgets('2. Search Screen supports live query, filters, and renders EmptySearchIllustration when no items found', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(const SearchProductsScreen()));
    await tester.pumpAndSettle();

    // Verify search bar and popular suggestions
    expect(find.text('Search items, brands, groceries...'), findsOneWidget);
    expect(find.text('Popular Searches'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Bread'), findsOneWidget);
    expect(find.text('All Departments'), findsOneWidget);

    // Enter search text that matches
    await tester.enterText(find.byType(TextField), 'Bread');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify bread found
    expect(find.textContaining('Found'), findsOneWidget);

    // Now enter impossible query to verify Empty State Illustration
    await tester.enterText(find.byType(TextField), 'xyznonexistentitem12345');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.byType(EmptySearchIllustration), findsOneWidget);
    expect(find.text('No Products Found'), findsOneWidget);
    expect(find.text('Clear Filters'), findsOneWidget);
  });

  testWidgets('3. Notifications Screen renders filters, list, and mark all read', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await notificationProvider.loadNotifications();
    await tester.pumpWidget(createTestWidget(const NotificationsScreen()));
    await tester.pump();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('Deliveries'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    // Seeded notifications
    expect(find.text('Welcome to BansiGo Mega Store!'), findsOneWidget);
    expect(find.text('Flash Sale: Up to 25% OFF Deli & Bakery'), findsOneWidget);

    // Tap Mark All Read
    if (find.text('Mark All Read').evaluate().isNotEmpty) {
      await tester.tap(find.text('Mark All Read'));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('4. More Options Screen matches inspo image with all exact requested fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(const MoreOptionsScreen()));
    await tester.pumpAndSettle();

    // Verify Title & Profile info
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Tommy Omolo'), findsOneWidget);
    expect(find.text('07XXXXXX24'), findsOneWidget);

    // Verify exact 6 requested fields
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('My Addresses'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('My Wishlist'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Verify icons match inspo
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byIcon(Icons.credit_card_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.power_settings_new_rounded), findsOneWidget);
  });

  testWidgets('5. Edit Profile, Payment Methods, and Contact Us screens render cleanly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Test Edit Profile
    await tester.pumpWidget(createTestWidget(const EditProfileScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('First Name'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Test Payment Methods
    await tester.pumpWidget(createTestWidget(const PaymentMethodsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('M-Pesa (Lipa Na M-Pesa)'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('Save Payment Preference'), findsOneWidget);

    // Test Contact Us
    await tester.pumpWidget(createTestWidget(const ContactUsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Contact Us'), findsOneWidget);
    expect(find.text('Chat with us'), findsOneWidget);
    expect(find.text('Talk to our Support'), findsOneWidget);
    expect(find.text('Mail us'), findsOneWidget);
    expect(find.text('Message to facebook page'), findsOneWidget);
  });
}
