// test/address_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bansigo_customer/core/config/app_config.dart';
import 'package:bansigo_customer/core/network/api_client.dart';
import 'package:bansigo_customer/core/storage/local_storage.dart';
import 'package:bansigo_customer/features/auth/providers/auth_provider.dart';
import 'package:bansigo_customer/features/auth/services/auth_service.dart';
import 'package:bansigo_customer/features/address/models/address_model.dart';
import 'package:bansigo_customer/features/address/models/time_preference_model.dart';
import 'package:bansigo_customer/features/address/providers/address_provider.dart';
import 'package:bansigo_customer/features/address/services/address_service.dart';
import 'package:bansigo_customer/features/address/screens/my_addresses_screen.dart';
import 'package:bansigo_customer/features/address/screens/map_location_picker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorage storage;
  late ApiClient apiClient;
  late AddressService addressService;
  late AddressProvider addressProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorage.create();
    AppConfig.initialize(env: AppEnvironment.testing);

    apiClient = ApiClient(storage: storage);
    addressService = AddressService(apiClient: apiClient, storage: storage);
    addressProvider = AddressProvider(addressService: addressService);
    await addressProvider.loadData();
  });

  group('AddressService & OSM Harmonization Tests', () {
    test('Supermarket location is harmonized to Bansi Mega Supermarket in Migori (-1.061219, 34.474196)', () {
      expect(AppConfig.supermarketLatitude, equals(-1.061219));
      expect(AppConfig.supermarketLongitude, equals(34.474196));
      expect(AppConfig.maxDeliveryRadiusKm, equals(7.0));
      expect(AppConfig.supermarketName, equals('Bansi Mega Supermarket'));
    });

    test('Haversine distance calculation is accurate', () {
      // Coords very close to Migori Bansi supermarket (~1.0 km away)
      final closeDist = addressService.calculateDistanceToSupermarketKm(-1.065000, 34.475000);
      expect(closeDist, greaterThan(0.2));
      expect(closeDist, lessThan(2.0));

      // Coords far away (~12 km away outside Migori)
      final farDist = addressService.calculateDistanceToSupermarketKm(-1.180000, 34.420000);
      expect(farDist, greaterThan(7.0));
    });
  });

  group('AddressProvider State & Operations Tests', () {
    test('Initializes with default addresses and selects default address', () {
      expect(addressProvider.addresses.isNotEmpty, isTrue);
      expect(addressProvider.selectedAddress, isNotNull);
      expect(addressProvider.selectedAddress!.isDefault, isTrue);
    });

    test('Detects warning when address is far apart (> 7.0km)', () async {
      final farAddr = addressProvider.addresses.firstWhere(
        (a) => a.latitude == -1.396000,
      );

      await addressProvider.selectAddress(farAddr);
      expect(addressProvider.isFarApart, isTrue);
      expect(addressProvider.currentDistanceKm, greaterThan(7.0));
      expect(addressProvider.deliveryDistanceNote, contains('Out of coverage'));
    });

    test('Add, edit, and delete addresses update provider state', () async {
      const newAddr = AddressModel(
        id: 0,
        label: 'Gym',
        recipientName: 'Main Shopper',
        recipientPhone: '+254711223344',
        zoneId: 1,
        area: 'Migori Stadium Road',
        latitude: -1.0640,
        longitude: 34.4740,
        isDefault: false,
      );

      final added = await addressProvider.addAddress(newAddr);
      expect(added, isTrue);
      expect(addressProvider.addresses.any((a) => a.label == 'Gym'), isTrue);

      final createdAddr = addressProvider.addresses.firstWhere((a) => a.label == 'Gym');
      final edited = await addressProvider.updateAddress(createdAddr.id, {'label': 'Fitness Club'});
      expect(edited, isTrue);
      expect(addressProvider.addresses.any((a) => a.label == 'Fitness Club'), isTrue);

      final deleted = await addressProvider.deleteAddress(createdAddr.id);
      expect(deleted, isTrue);
      expect(addressProvider.addresses.any((a) => a.label == 'Fitness Club'), isFalse);
    });

    test('Time preference toggles instant and scheduled', () {
      expect(addressProvider.timePreference.isInstant, isTrue);

      final scheduledPref = TimePreferenceModel(
        type: DeliveryType.scheduled,
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '02:00 PM – 04:00 PM',
        deliveryInstructions: 'Leave with guard',
      );
      addressProvider.setTimePreference(scheduledPref);

      expect(addressProvider.timePreference.isInstant, isFalse);
      expect(addressProvider.timePreference.summary, contains('02:00 PM – 04:00 PM'));
    });
  });

  group('MyAddressesScreen Widget Tests (Image 5 Match)', () {
    testWidgets('Renders My Addresses screen with Home, Work, edit and delete buttons, and Add New Address', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AddressProvider>.value(
            value: addressProvider,
            child: const MyAddressesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Title
      expect(find.text('My Addresses'), findsOneWidget);

      // Address items matching attached image
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Work'), findsWidgets);
      expect(find.textContaining('Omwabo Apartments'), findsOneWidget);
      expect(find.textContaining('Widreyn Cafe'), findsOneWidget);

      // Edit and Delete icons
      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

      // Add New Address Button at bottom
      expect(find.text('Add New Address'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });

  group('MapLocationPickerScreen Widget Tests (Image 4 Match)', () {
    testWidgets('Renders map picker with search, Home/Office/Other chips, and Save Location button', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final authService = AuthService(apiClient: apiClient, storage: storage);
      final authProvider = AuthProvider(authService);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
              ChangeNotifierProvider<AddressProvider>.value(value: addressProvider),
            ],
            child: const MapLocationPickerScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Search bar
      expect(find.text('Search Migori street or landmark...'), findsOneWidget);

      // Label chips
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Office'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Save button
      expect(find.text('Save This Location'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });
  });
}
