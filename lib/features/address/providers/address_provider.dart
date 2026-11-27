// lib/features/address/providers/address_provider.dart

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';
import '../models/address_model.dart';
import '../models/coverage_model.dart';
import '../models/delivery_zone_model.dart';
import '../models/time_preference_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService;

  List<AddressModel> _addresses = [];
  AddressModel? _selectedAddress;
  List<DeliveryZoneModel> _zones = [];
  CoverageModel? _currentCoverage;
  TimePreferenceModel _timePreference = const TimePreferenceModel();
  Position? _devicePosition;
  String? _gpsLocationName;

  bool _isLoading = false;
  String? _error;
  int _loadEpoch = 0;

  AddressProvider({required AddressService addressService})
      : _addressService = addressService {
    loadData();
  }

  // Getters
  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  AddressModel? get selectedAddress => _selectedAddress;
  List<DeliveryZoneModel> get zones => List.unmodifiable(_zones);
  CoverageModel? get currentCoverage => _currentCoverage;
  TimePreferenceModel get timePreference => _timePreference;
  Position? get devicePosition => _devicePosition;
  String? get gpsLocationName => _gpsLocationName;
  AddressService get service => _addressService;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Human-friendly display string for current location
  String get currentDisplayLocation {
    if (_selectedAddress != null) {
      return _selectedAddress!.displayAddress;
    }
    if (_gpsLocationName != null && _gpsLocationName!.isNotEmpty) {
      return _gpsLocationName!;
    }
    if (_devicePosition != null) {
      return 'Current Location, Migori';
    }
    return 'Select delivery location';
  }

  /// Current distance to Bansi Mega Supermarket in kilometers
  double get currentDistanceKm {
    if (_selectedAddress != null) {
      return _addressService.calculateDistanceToSupermarketKm(
        _selectedAddress!.latitude,
        _selectedAddress!.longitude,
      );
    }
    if (_devicePosition != null) {
      return _addressService.calculateDistanceToSupermarketKm(
        _devicePosition!.latitude,
        _devicePosition!.longitude,
      );
    }
    return 0.0;
  }

  /// Whether current active address is far apart (> 7.0km or outside coverage)
  bool get isFarApart {
    if (_selectedAddress != null) {
      final dist = currentDistanceKm;
      if (dist > AppConfig.maxDeliveryRadiusKm) return true;
      if (_currentCoverage != null && !_currentCoverage!.isCovered) return true;
      return false;
    }

    // No location set: Rely on actual phone GPS
    if (_devicePosition != null) {
      final gpsDist = _addressService.calculateDistanceToSupermarketKm(
        _devicePosition!.latitude,
        _devicePosition!.longitude,
      );
      return gpsDist > AppConfig.maxDeliveryRadiusKm;
    }

    // If no location set and GPS not yet acquired, flag as out of coverage
    return true;
  }

  /// Short human-readable supermarket delivery badge note
  String get deliveryDistanceNote {
    if (_selectedAddress != null) {
      final dist = currentDistanceKm;
      if (isFarApart) {
        return '⚠️ Out of coverage • ${dist.toStringAsFixed(1)} km from ${AppConfig.supermarketName}';
      }
      final mins = (dist * 3 + 12).toInt().clamp(15, 45);
      return '$mins mins delivery • ${dist.toStringAsFixed(1)} km from ${AppConfig.supermarketName}';
    }

    // Rely on actual phone GPS when no address is set
    if (_devicePosition != null) {
      final gpsDist = _addressService.calculateDistanceToSupermarketKm(
        _devicePosition!.latitude,
        _devicePosition!.longitude,
      );
      if (gpsDist > AppConfig.maxDeliveryRadiusKm) {
        return '⚠️ Out of coverage • ${gpsDist.toStringAsFixed(1)} km from store • Set address';
      }
      final mins = (gpsDist * 3 + 12).toInt().clamp(15, 45);
      return '$mins mins delivery • ${gpsDist.toStringAsFixed(1)} km (Phone GPS)';
    }

    return '⚠️ Out of coverage • Set delivery location';
  }

  /// Load addresses and zones immediately, then enrich with GPS & coverage in the background
  Future<void> loadData() async {
    final currentEpoch = ++_loadEpoch;
    _error = null;

    // Hydrate from persisted cache immediately so UI has addresses on first frame
    if (_addresses.isEmpty) {
      final cached = _addressService.getCachedAddresses();
      if (cached != null && cached.isNotEmpty) {
        _addresses = cached;
        _selectedAddress ??= _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _addressService.getAddresses(),
        _addressService.getDeliveryZones(),
      ]);

      if (currentEpoch != _loadEpoch) return;

      _addresses = results[0] as List<AddressModel>;
      _zones = results[1] as List<DeliveryZoneModel>;

      if (_addresses.isNotEmpty) {
        final previousId = _selectedAddress?.id;
        _selectedAddress = _addresses.firstWhere(
          (a) => previousId != null && a.id == previousId,
          orElse: () => _addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => _addresses.first,
          ),
        );
      } else {
        // No saved addresses for this user (e.g. brand new user registration)
        // Reset selected address so location strictly borrows from live GPS
        _selectedAddress = null;
      }
    } catch (e) {
      if (currentEpoch != _loadEpoch) return;
      AppLogger.e('AddressProvider load error: $e');
      _error = e.toString();
    } finally {
      if (currentEpoch == _loadEpoch) {
        _isLoading = false;
        notifyListeners();
      }
    }

    if (currentEpoch != _loadEpoch) return;

    // Non-blocking background enrichment: coverage check + live device GPS
    if (_selectedAddress != null) {
      _checkCoverageForSelected();
    }
    _loadDevicePositionInBackground(currentEpoch);
  }

  /// Fetch device GPS and reverse-geocode without blocking address list loading
  Future<void> _loadDevicePositionInBackground(int epoch) async {
    try {
      final pos = await _addressService.getCurrentDevicePosition();
      if (epoch != _loadEpoch || pos == null) return;
      _devicePosition = pos;
      notifyListeners();
      await _resolveGpsLocationName(pos);
    } catch (e) {
      AppLogger.w('Background GPS refresh failed: $e');
    }
  }

  /// Resolve readable place name for GPS coordinates
  Future<void> _resolveGpsLocationName(Position pos) async {
    try {
      final place = await _addressService.reverseGeocode(pos.latitude, pos.longitude);
      if (place != null && place.trim().isNotEmpty) {
        final tokens = place.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        final distinct = <String>[];
        for (final t in tokens) {
          if (!distinct.any((d) => d.toLowerCase() == t.toLowerCase())) {
            distinct.add(t);
          }
        }
        final loc = distinct.take(2).join(', ');
        final hasCounty = loc.toLowerCase().contains('migori');
        _gpsLocationName = hasCounty ? loc : '$loc, Migori';
        notifyListeners();
      }
    } catch (e) {
      AppLogger.w('Failed to reverse geocode device GPS: $e');
    }
  }

  /// Resets addresses and selection on logout to prevent address leakage.
  /// Refreshes live GPS position so any subsequent or newly registered user
  /// borrows strictly from device live GPS.
  Future<void> resetOnLogout() async {
    _loadEpoch++;
    _addresses = [];
    _selectedAddress = null;
    _currentCoverage = null;
    _error = null;
    await _addressService.clearCache();
    await refreshDeviceLocation();
    notifyListeners();
  }

  /// Refresh physical phone GPS position
  Future<void> refreshDeviceLocation() async {
    _devicePosition = await _addressService.getCurrentDevicePosition();
    if (_devicePosition != null) {
      await _resolveGpsLocationName(_devicePosition!);
    }
    notifyListeners();
  }

  /// Select active delivery address
  Future<void> selectAddress(AddressModel address) async {
    _selectedAddress = address;
    notifyListeners();
    await _checkCoverageForSelected();
  }

  /// Save new address
  Future<bool> addAddress(AddressModel address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _addressService.createAddress(address);
      if (created.isDefault) {
        _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      }
      _addresses.insert(0, created);
      _selectedAddress = created;
      await _checkCoverageForSelected();
      return true;
    } catch (e) {
      AppLogger.e('Failed to add address: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edit address
  Future<bool> updateAddress(int id, Map<String, dynamic> patch) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _addressService.updateAddress(id, patch);
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updated;
        if (updated.isDefault) {
          _addresses = _addresses
              .map((a) => a.id == id ? a : a.copyWith(isDefault: false))
              .toList();
        }
      }
      if (_selectedAddress?.id == id) {
        _selectedAddress = updated;
        await _checkCoverageForSelected();
      }
      return true;
    } catch (e) {
      AppLogger.e('Failed to update address: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete address
  Future<bool> deleteAddress(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _addressService.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);

      if (_selectedAddress?.id == id) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
        if (_selectedAddress != null) {
          await _checkCoverageForSelected();
        } else {
          _currentCoverage = null;
        }
      }
      return true;
    } catch (e) {
      AppLogger.e('Failed to delete address: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update instant vs scheduled delivery time preference
  void setTimePreference(TimePreferenceModel preference) {
    _timePreference = preference;
    notifyListeners();
  }

  /// Quick distance calculation for any address model
  double getDistanceFor(AddressModel address) {
    return _addressService.calculateDistanceToSupermarketKm(
      address.latitude,
      address.longitude,
    );
  }

  /// Check coverage for selected address
  Future<void> _checkCoverageForSelected() async {
    if (_selectedAddress == null) return;
    try {
      _currentCoverage = await _addressService.checkCoverage(
        _selectedAddress!.latitude,
        _selectedAddress!.longitude,
      );
    } catch (e) {
      AppLogger.w('Coverage check error: $e');
    }
    notifyListeners();
  }
}
