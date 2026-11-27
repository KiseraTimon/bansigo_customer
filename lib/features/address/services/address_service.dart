// lib/features/address/services/address_service.dart

import 'dart:convert';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_endpoints.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../models/address_model.dart';
import '../models/coverage_model.dart';
import '../models/delivery_zone_model.dart';

class AddressService {
  final ApiClient _apiClient;
  final LocalStorage _storage;

  static const String _cachedAddressesKey = 'cached_customer_addresses';

  AddressService({required ApiClient apiClient, required LocalStorage storage})
      : _apiClient = apiClient,
        _storage = storage;

  /// Clears persisted address cache for the user
  Future<void> clearCache() async {
    await _storage.prefs.remove(_cachedAddressesKey);
  }

  /// Haversine client-side distance calculator (in km) to Bansi Mega Supermarket
  double calculateDistanceToSupermarketKm(double lat, double lon) {
    return calculateHaversineDistanceKm(
      AppConfig.supermarketLatitude,
      AppConfig.supermarketLongitude,
      lat,
      lon,
    );
  }

  /// Calculates geodesic great-circle distance between two GPS coordinates
  static double calculateHaversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Fetch physical GPS position of device with graceful fallback
  Future<Position?> getCurrentDevicePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      AppLogger.w('Failed to get GPS device position: $e');
      return null;
    }
  }

  /// OpenStreetMap Nominatim search with Kenya / Migori bounds
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    final client = http.Client();
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(clean)}&format=json&countrycodes=ke&limit=6&addressdetails=1',
      );
      final res = await client.get(
        uri,
        headers: {'User-Agent': 'BansiGoCustomerApp/1.0 (support@bansigo.co.ke)'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded.map((e) => e as Map<String, dynamic>).toList();
        }
      }
    } catch (e) {
      AppLogger.w('Nominatim place search failed: $e');
    } finally {
      client.close();
    }
    return [];
  }

  /// Reverse geocode coordinates to human-readable street or area
  Future<String?> reverseGeocode(double lat, double lon) async {
    final client = http.Client();
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final res = await client.get(
        uri,
        headers: {'User-Agent': 'BansiGoCustomerApp/1.0 (support@bansigo.co.ke)'},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) {
          final addr = decoded['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final suburb = addr['suburb'] ?? addr['neighbourhood'] ?? addr['village'] ?? addr['quarter'];
            final road = addr['road'] ?? addr['residential'];
            final town = addr['town'] ?? addr['city'] ?? addr['county'];
            final parts = [road, suburb, town].where((p) => p != null && p.toString().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              return parts.join(', ');
            }
          }
          return decoded['display_name'] as String?;
        }
      }
    } catch (e) {
      AppLogger.w('Reverse geocode failed: $e');
    } finally {
      client.close();
    }
    return null;
  }

  /// Returns cached addresses only if explicitly stored in local preferences (null otherwise)
  List<AddressModel>? getCachedAddresses() {
    final raw = _storage.prefs.getString(_cachedAddressesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.e('Failed to parse cached addresses: $e');
      return null;
    }
  }

  /// Fetch saved addresses from server with offline cache fallback
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.addresses);
      if (response is List) {
        final list = response
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _saveToCache(list);
        return list;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch addresses from backend ($e). Loading local cache.');
    }
    return _loadFromCache();
  }

  /// Create new delivery address
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.addresses,
        address.toJson(forCreation: true),
      );
      final created = AddressModel.fromJson(response as Map<String, dynamic>);
      final currentList = _loadFromCache();
      currentList.insert(0, created);
      _saveToCache(currentList);
      return created;
    } catch (e) {
      AppLogger.w('Backend address creation failed ($e). Storing in local cache.');
      // Local fallback for guest / offline mode
      final currentList = _loadFromCache();
      final newId = DateTime.now().millisecondsSinceEpoch % 100000;
      final localCreated = address.copyWith(
        id: newId,
        createdAt: DateTime.now(),
      );
      currentList.insert(0, localCreated);
      _saveToCache(currentList);
      return localCreated;
    }
  }

  /// Update existing delivery address
  Future<AddressModel> updateAddress(int id, Map<String, dynamic> patch) async {
    try {
      final response = await _apiClient.patchJson(
        ApiEndpoints.addressDetail(id),
        patch,
      );
      final updated = AddressModel.fromJson(response as Map<String, dynamic>);
      final list = _loadFromCache();
      final index = list.indexWhere((a) => a.id == id);
      if (index != -1) {
        list[index] = updated;
        _saveToCache(list);
      }
      return updated;
    } catch (e) {
      AppLogger.w('Backend address update failed ($e). Updating local cache.');
      final list = _loadFromCache();
      final index = list.indexWhere((a) => a.id == id);
      if (index != -1) {
        final existing = list[index];
        final updated = existing.copyWith(
          label: patch['label'] as String? ?? existing.label,
          recipientName: patch['recipient_name'] as String? ?? existing.recipientName,
          recipientPhone: patch['recipient_phone'] as String? ?? existing.recipientPhone,
          area: patch['area'] as String? ?? existing.area,
          streetAddress: patch['street_address'] as String? ?? existing.streetAddress,
          landmark: patch['landmark'] as String? ?? existing.landmark,
          directions: patch['directions'] as String? ?? existing.directions,
          latitude: patch['latitude'] != null ? double.parse(patch['latitude'].toString()) : existing.latitude,
          longitude: patch['longitude'] != null ? double.parse(patch['longitude'].toString()) : existing.longitude,
          isDefault: patch['is_default'] as bool? ?? existing.isDefault,
        );
        list[index] = updated;
        _saveToCache(list);
        return updated;
      }
      rethrow;
    }
  }

  /// Delete delivery address
  Future<void> deleteAddress(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.addressDetail(id));
    } catch (e) {
      AppLogger.w('Backend address delete failed ($e). Removing from local cache.');
    }
    final list = _loadFromCache();
    list.removeWhere((a) => a.id == id);
    _saveToCache(list);
  }

  /// Fetch active delivery zones
  Future<List<DeliveryZoneModel>> getDeliveryZones() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.deliveryZones);
      if (response is List) {
        return response
            .map((item) => DeliveryZoneModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Failed to fetch zones from backend ($e). Returning fallback zones.');
    }
    return _fallbackZones;
  }

  /// Check coverage with backend API
  Future<CoverageModel> checkCoverage(double lat, double lon) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.deliveryCoverage,
        queryParameters: {
          'lat': double.parse(lat.toStringAsFixed(6)),
          'lon': double.parse(lon.toStringAsFixed(6)),
        },
      );
      return CoverageModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      AppLogger.w('Backend coverage check failed ($e). Using client-side Haversine estimate.');
      final distKm = calculateDistanceToSupermarketKm(lat, lon);
      return CoverageModel(
        isCovered: distKm <= AppConfig.maxDeliveryRadiusKm,
        distanceToStoreM: distKm * 1000.0,
        maxRadiusKm: AppConfig.maxDeliveryRadiusKm,
        supermarketName: AppConfig.supermarketName,
        supermarketLatitude: AppConfig.supermarketLatitude,
        supermarketLongitude: AppConfig.supermarketLongitude,
      );
    }
  }

  /// Check delivery estimate & fee quote with backend OSM engine
  Future<Map<String, dynamic>> getDeliveryEstimate(double lat, double lon, [int? addressId]) async {
    final payload = <String, dynamic>{
      'latitude': double.parse(lat.toStringAsFixed(6)),
      'longitude': double.parse(lon.toStringAsFixed(6)),
    };
    if (addressId != null) {
      payload['address_id'] = addressId;
    }
    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.deliveryEstimate,
        payload,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      AppLogger.w('Backend estimate failed ($e). Generating fallback estimate.');
      final distKm = calculateDistanceToSupermarketKm(lat, lon);
      final isDeliverable = distKm <= AppConfig.maxDeliveryRadiusKm;
      final fee = isDeliverable
          ? AppConfig.baseDeliveryFee + (distKm * AppConfig.deliveryFeePerKm)
          : 0.0;
      return {
        'is_deliverable': isDeliverable,
        'distance_m': (distKm * 1000).toInt(),
        'duration_s': (distKm * 180).toInt(),
        'estimated_minutes': (distKm * 3).toInt().clamp(15, 60),
        'delivery_fee': fee.toStringAsFixed(2),
        'routing_algorithm': 'haversine_fallback',
        'supermarket_name': AppConfig.supermarketName,
      };
    }
  }

  // --- Local cache helpers ---

  List<AddressModel> _loadFromCache() {
    final raw = _storage.prefs.getString(_cachedAddressesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        AppLogger.e('Failed to parse cached addresses: $e');
      }
    }
    if (AppConfig.current.environment == AppEnvironment.testing) {
      return List.from(_defaultMockAddresses);
    }
    return [];
  }

  void _saveToCache(List<AddressModel> list) {
    try {
      final jsonList = list.map((a) => a.toJson()).toList();
      _storage.prefs.setString(_cachedAddressesKey, jsonEncode(jsonList));
    } catch (e) {
      AppLogger.e('Failed to save addresses to cache: $e');
    }
  }

  // Initial seed addresses matching Migori area + out-of-range benchmark
  static final List<AddressModel> _defaultMockAddresses = [
    const AddressModel(
      id: 1,
      label: 'Home',
      recipientName: 'Main Shopper',
      recipientPhone: '+254711223344',
      zoneId: 1,
      area: 'Omwabo Apartments, Kimaiga, Migori, WFVH+P25',
      streetAddress: 'Omwabo Apartments',
      landmark: 'Kimaiga, Migori, WFVH+P25',
      directions: 'Door 4B',
      latitude: -1.0634,
      longitude: 34.4731,
      isDefault: true,
    ),
    const AddressModel(
      id: 2,
      label: 'Work',
      recipientName: 'Office Desk',
      recipientPhone: '+254711556677',
      zoneId: 1,
      area: 'Widreyn Cafe, Migori, WFGT+Q21',
      streetAddress: 'Widreyn Cafe',
      landmark: 'Migori, WFGT+Q21',
      directions: 'Front counter',
      latitude: -1.0650,
      longitude: 34.4750,
      isDefault: false,
    ),
    const AddressModel(
      id: 3,
      label: 'Parents (Outside Radius)',
      recipientName: 'Mama Bansi',
      recipientPhone: '+254711889900',
      zoneId: 2,
      area: 'Rongai Outskirts, Mile 12',
      streetAddress: 'Mile 12 Barrier',
      landmark: 'Near Rongai Stage',
      directions: 'Call upon arrival',
      latitude: -1.396000,
      longitude: 36.758000,
      isDefault: false,
    ),
  ];

  static const List<DeliveryZoneModel> _fallbackZones = [
    DeliveryZoneModel(
      id: 1,
      name: 'City Core Zone (Within 3km)',
      deliveryFee: 50.0,
      minOrderAmount: 300.0,
      estimatedMinutes: 20,
    ),
    DeliveryZoneModel(
      id: 2,
      name: 'Suburban Zone (3km - 7km)',
      deliveryFee: 90.0,
      minOrderAmount: 500.0,
      estimatedMinutes: 35,
    ),
  ];
}
