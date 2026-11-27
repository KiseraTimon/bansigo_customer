// lib/features/address/screens/map_location_picker_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

import '../../../shared/widgets/app_toast.dart';
class MapLocationPickerScreen extends StatefulWidget {
  final AddressModel? addressToEdit;

  const MapLocationPickerScreen({super.key, this.addressToEdit});

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _currentCenter;
  String _selectedLabel = 'Home';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounceTimer;

  final List<String> _labelChips = ['Home', 'Office', 'Other'];

  // Popular Migori landmark presets for instantaneous 1-tap positioning
  final List<Map<String, dynamic>> _migoriPresets = [
    {
      'display_name': 'Bansi Mega Supermarket, Migori Town Centre',
      'lat': -1.061219,
      'lon': 34.474196,
      'area': 'Bansi Supermarket, Town Centre',
    },
    {
      'display_name': 'Migori Bus Park & Matatu Stage, Central',
      'lat': -1.063400,
      'lon': 34.473100,
      'area': 'Migori Main Bus Park',
    },
    {
      'display_name': 'Nyasare Market & Residential Area',
      'lat': -1.058000,
      'lon': 34.469000,
      'area': 'Nyasare, Migori',
    },
    {
      'display_name': 'Kadika Primary & Estate, Migori',
      'lat': -1.072000,
      'lon': 34.482000,
      'area': 'Kadika Estate',
    },
    {
      'display_name': 'Migori County Referral Hospital',
      'lat': -1.066500,
      'lon': 34.478000,
      'area': 'Hospital Road, Migori',
    },
    {
      'display_name': 'Oruba Estate, Migori Town',
      'lat': -1.052000,
      'lon': 34.475000,
      'area': 'Oruba Estate',
    },
    {
      'display_name': 'Ombo Mission Hospital, Migori',
      'lat': -1.069000,
      'lon': 34.464000,
      'area': 'Ombo Area',
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    final authUser = context.read<AuthProvider>().currentUser;
    final defaultName = authUser?.fullName.isNotEmpty == true
        ? authUser!.fullName
        : (authUser?.email.split('@').first ?? 'Customer');
    final defaultPhone = authUser?.phone.isNotEmpty == true
        ? authUser!.phone
        : '0711000000';

    if (widget.addressToEdit != null) {
      final addr = widget.addressToEdit!;
      _currentCenter = LatLng(addr.latitude, addr.longitude);
      _selectedLabel = addr.label;
      _areaController.text = addr.area;
      _searchController.text = addr.area;
      _recipientNameController.text = addr.recipientName;
      _recipientPhoneController.text = addr.recipientPhone;
      _landmarkController.text = addr.landmark ?? addr.directions ?? '';
      _isDefault = addr.isDefault;
    } else {
      // Default to Migori Bansi Supermarket location
      _currentCenter = const LatLng(
        AppConfig.supermarketLatitude,
        AppConfig.supermarketLongitude,
      );
      _areaController.text = 'Migori Town Centre';
      _searchController.text = 'Migori Town Centre';
      _recipientNameController.text = defaultName;
      _recipientPhoneController.text = defaultPhone;
      _isDefault = true;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  double get _distanceToStoreKm {
    final provider = context.read<AddressProvider>();
    return provider.service.calculateDistanceToSupermarketKm(
      _currentCenter.latitude,
      _currentCenter.longitude,
    );
  }

  bool get _isWithinCoverage => _distanceToStoreKm <= AppConfig.maxDeliveryRadiusKm;

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentCenter = camera.center;
      });
      _debounceReverseGeocode();
    }
  }

  void _debounceReverseGeocode() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 700), () async {
      final provider = context.read<AddressProvider>();
      final placeName = await provider.service.reverseGeocode(
        _currentCenter.latitude,
        _currentCenter.longitude,
      );
      if (placeName != null && mounted) {
        setState(() {
          _areaController.text = placeName.split(',').take(2).join(', ');
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = true;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      final provider = context.read<AddressProvider>();
      final results = await provider.service.searchPlaces(query);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
          _showSuggestions = true;
        });
      }
    });
  }

  void _selectSearchResult(double lat, double lon, String name) {
    FocusScope.of(context).unfocus();
    final target = LatLng(lat, lon);
    setState(() {
      _currentCenter = target;
      _searchController.text = name;
      _areaController.text = name.split(',').take(2).join(', ');
      _showSuggestions = false;
      _searchResults = [];
    });
    _mapController.move(target, 16.0);
  }

  Future<void> _useCurrentDeviceGps() async {
    final provider = context.read<AddressProvider>();
    final pos = await provider.service.getCurrentDevicePosition();
    if (pos != null && mounted) {
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _currentCenter = target;
      });
      _mapController.move(target, 16.0);
      _debounceReverseGeocode();
    } else if (mounted) {
      AppToast.show(context, 'Could not fetch GPS. Please ensure location services are enabled.', type: AppToastType.error);
    }
  }

  Future<void> _handleSaveLocation() async {
    final areaText = _areaController.text.trim().isNotEmpty
        ? _areaController.text.trim()
        : (_searchController.text.trim().isNotEmpty ? _searchController.text.trim() : 'Migori, WFVH+P25');

    final nameText = _recipientNameController.text.trim();
    if (nameText.isEmpty) {
      AppToast.show(context, 'Please enter recipient name', type: AppToastType.error);
      return;
    }

    final phoneRaw = _recipientPhoneController.text.trim();
    final normPhone = Validators.normalisePhone(phoneRaw);
    if (normPhone == null || normPhone.isEmpty) {
      AppToast.show(context, 'Please enter a valid Kenyan phone number (e.g. 0712345678)', type: AppToastType.error);
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<AddressProvider>();

    // Select active zone matching distance or first active zone
    int selectedZoneId = 1;
    if (provider.zones.isNotEmpty) {
      selectedZoneId = provider.zones.first.id;
    }

    final isEditing = widget.addressToEdit != null;
    final landmarkText = _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null;

    final addressData = AddressModel(
      id: isEditing ? widget.addressToEdit!.id : 0,
      label: _selectedLabel,
      recipientName: nameText,
      recipientPhone: normPhone,
      zoneId: selectedZoneId,
      area: areaText,
      streetAddress: null,
      landmark: landmarkText,
      directions: landmarkText,
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      isDefault: _isDefault,
    );

    bool success = false;
    if (isEditing) {
      success = await provider.updateAddress(
        widget.addressToEdit!.id,
        addressData.toJson(),
      );
    } else {
      success = await provider.addAddress(addressData);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      AppToast.show(context, isEditing
                ? 'Address updated in database successfully!'
                : 'New delivery address saved to database!', type: AppToastType.success, duration: const Duration(seconds: 2));
      Navigator.of(context).pop(true);
    } else {
      AppToast.show(context, 'Failed to save location to server. Please try again.', type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dist = _distanceToStoreKm;
    final inCoverage = _isWithinCoverage;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Live Interactive OpenStreetMap
          Positioned.fill(
            bottom: 310,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 15.5,
                minZoom: 10.0,
                maxZoom: 18.0,
                onPositionChanged: _onPositionChanged,
                onTap: (tapPosition, point) {
                  setState(() => _currentCenter = point);
                  _mapController.move(point, _mapController.camera.zoom);
                  _debounceReverseGeocode();
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bansigo.customer',
                ),
                // Supermarket Location Marker
                MarkerLayer(
                  markers: [
                    Marker(
                      point: const LatLng(
                        AppConfig.supermarketLatitude,
                        AppConfig.supermarketLongitude,
                      ),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Centered Pin Marker
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 310,
            child: Center(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF7A00).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 4.5,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Floating Search Bar & Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Circular Back Button
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 22,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Search input
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onTap: () => setState(() => _showSuggestions = true),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Migori street or landmark...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                        _showSuggestions = false;
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Distance & Coverage Pill below search
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: inCoverage
                        ? const Color(0xFFEBF7ED)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: inCoverage
                          ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                          : const Color(0xFFEF4444).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        inCoverage ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                        size: 16,
                        color: inCoverage ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          inCoverage
                              ? 'Within 7km Zone • ${dist.toStringAsFixed(1)} km from store'
                              : '⚠️ Out of coverage • ${dist.toStringAsFixed(1)} km from store',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: inCoverage ? const Color(0xFF166534) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating 'My Current GPS' Button
          Positioned(
            right: 16,
            bottom: 386,
            child: FloatingActionButton.small(
              heroTag: 'gps_fab',
              onPressed: _useCurrentDeviceGps,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.my_location_rounded, size: 22),
            ),
          ),

          // 5. Search Suggestions Overlay
          if (_showSuggestions)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              right: 16,
              bottom: 370,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchResults.isNotEmpty
                                ? 'Search Results'
                                : 'Popular Migori Locations',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showSuggestions = false),
                            child: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    Expanded(
                      child: _isSearching
                          ? const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _searchResults.isNotEmpty
                                  ? _searchResults.length
                                  : _migoriPresets.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, color: Color(0xFFF8FAFC)),
                              itemBuilder: (context, idx) {
                                if (_searchResults.isNotEmpty) {
                                  final item = _searchResults[idx];
                                  final name = item['display_name']?.toString() ?? 'Location';
                                  final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
                                  final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;

                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                    title: Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                                    ),
                                    onTap: () => _selectSearchResult(lat, lon, name),
                                  );
                                } else {
                                  final preset = _migoriPresets[idx];
                                  final name = preset['display_name'] as String;
                                  final lat = preset['lat'] as double;
                                  final lon = preset['lon'] as double;

                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.storefront, color: Color(0xFFFF7A00), size: 20),
                                    title: Text(
                                      name,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      preset['area'] as String,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                    ),
                                    onTap: () => _selectSearchResult(lat, lon, name),
                                  );
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

          // 6. Bottom Sheet Form (Scrollable with detailed fields)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 370,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Area / Estate input - spacious, nicely padded with clear label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'LOCATION / AREA NAME',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  TextField(
                                    controller: _areaController,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'e.g. Nyasare, Migori',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Label chips (Home, Office, Other)
                      Row(
                        children: _labelChips.map((chip) {
                          final isSelected = _selectedLabel.toLowerCase() == chip.toLowerCase();
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedLabel = chip),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    chip,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryDark : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Recipient Name & Phone in Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: _recipientNameController,
                                style: const TextStyle(fontSize: 13.5),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Recipient Name',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: _recipientPhoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 13.5),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Phone (07XXXXXXXX)',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 11),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Landmark / Rider directions
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _landmarkController,
                          style: const TextStyle(fontSize: 13.5),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Landmark / Rider directions (e.g. Near Posta, Blue Gate)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 11),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Save Location Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSaveLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Save This Location',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 19,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
