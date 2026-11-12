// lib/features/address/screens/sections/address_form_dialog.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/address_model.dart';
import '../../models/delivery_zone_model.dart';

class AddressFormDialog extends StatefulWidget {
  final AddressModel? initialAddress;
  final List<DeliveryZoneModel> zones;
  final Future<bool> Function(AddressModel) onSave;

  const AddressFormDialog({
    super.key,
    this.initialAddress,
    required this.zones,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    AddressModel? initialAddress,
    required List<DeliveryZoneModel> zones,
    required Future<bool> Function(AddressModel) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormDialog(
        initialAddress: initialAddress,
        zones: zones,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _label;
  late final TextEditingController _recipientNameController;
  late final TextEditingController _recipientPhoneController;
  late final TextEditingController _areaController;
  late final TextEditingController _streetController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _directionsController;

  late int _zoneId;
  late double _latitude;
  late double _longitude;
  late bool _isDefault;
  bool _isSaving = false;

  static const List<String> _labels = ['Home', 'Work', 'Other'];

  // Presets around Nairobi & Bansi Mega Supermarket (-1.286389, 36.817222)
  static const List<Map<String, dynamic>> _locationPresets = [
    {
      'title': 'Upper Hill (1.2 km)',
      'area': 'Upper Hill',
      'lat': -1.295000,
      'lon': 36.815000,
    },
    {
      'title': 'CBD Core (0.5 km)',
      'area': 'CBD Central',
      'lat': -1.284000,
      'lon': 36.820000,
    },
    {
      'title': 'Westlands (3.8 km)',
      'area': 'Westlands',
      'lat': -1.265000,
      'lon': 36.802000,
    },
    {
      'title': 'Kileleshwa (4.5 km)',
      'area': 'Kileleshwa',
      'lat': -1.278000,
      'lon': 36.782000,
    },
    {
      'title': 'Outskirts (12 km - Outside 7km)',
      'area': 'Rongai',
      'lat': -1.396000,
      'lon': 36.758000,
    },
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _label = a?.label ?? 'Home';
    _recipientNameController = TextEditingController(text: a?.recipientName ?? '');
    _recipientPhoneController = TextEditingController(text: a?.recipientPhone ?? '+254');
    _areaController = TextEditingController(text: a?.area ?? 'Upper Hill');
    _streetController = TextEditingController(text: a?.streetAddress ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _directionsController = TextEditingController(text: a?.directions ?? '');

    _zoneId = a?.zoneId ?? (widget.zones.isNotEmpty ? widget.zones.first.id : 1);
    _latitude = a?.latitude ?? AppConfig.supermarketLatitude;
    _longitude = a?.longitude ?? AppConfig.supermarketLongitude;
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _directionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final newOrUpdated = AddressModel(
      id: widget.initialAddress?.id ?? 0,
      label: _label,
      recipientName: _recipientNameController.text.trim(),
      recipientPhone: _recipientPhoneController.text.trim(),
      zoneId: _zoneId,
      area: _areaController.text.trim(),
      streetAddress: _streetController.text.trim().isNotEmpty ? _streetController.text.trim() : null,
      landmark: _landmarkController.text.trim().isNotEmpty ? _landmarkController.text.trim() : null,
      directions: _directionsController.text.trim().isNotEmpty ? _directionsController.text.trim() : null,
      latitude: _latitude,
      longitude: _longitude,
      isDefault: _isDefault,
    );

    final success = await widget.onSave(newOrUpdated);
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialAddress != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal pill handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Delivery Address' : 'Add New Address',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Label Chips (Home, Work, Other)
              Text('Address Label', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: _labels.map((l) {
                  final isSelected = _label == l;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.slateDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _label = l);
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Recipient Name & Phone
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient Name *',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'Name required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _recipientPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      validator: (val) =>
                          (val == null || val.trim().length < 9) ? 'Valid phone required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Area / Neighborhood
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Neighborhood *',
                  hintText: 'e.g. Upper Hill, Westlands, Wasweta',
                  prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Area required' : null,
              ),

              const SizedBox(height: 14),

              // Street Address / Apartment
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address & Apartment',
                  hintText: 'e.g. Kilimani Road, Block B Apt 4',
                  prefixIcon: Icon(Icons.signpost_outlined, size: 20),
                ),
              ),

              const SizedBox(height: 14),

              // Landmark & Directions
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _landmarkController,
                      decoration: const InputDecoration(
                        labelText: 'Nearby Landmark',
                        hintText: 'e.g. Opposite City Hall',
                        prefixIcon: Icon(Icons.flag_outlined, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _directionsController,
                      decoration: const InputDecoration(
                        labelText: 'Rider Directions',
                        hintText: 'e.g. Gate 2, call guard',
                        prefixIcon: Icon(Icons.directions_outlined, size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location Pin / Coordinate Presets
              Text(
                'Map Coordinate Presets (OpenStreetMap snaps)',
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Selected GPS: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _locationPresets.map((preset) {
                    final lat = preset['lat'] as double;
                    final lon = preset['lon'] as double;
                    final isCurrent = (_latitude - lat).abs() < 0.001 && (_longitude - lon).abs() < 0.001;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: Icon(
                          isCurrent ? Icons.check_circle : Icons.pin_drop_outlined,
                          size: 16,
                          color: isCurrent ? Colors.white : AppColors.primaryDark,
                        ),
                        label: Text(preset['title'] as String),
                        backgroundColor: isCurrent ? AppColors.primaryDark : Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color: isCurrent ? Colors.white : AppColors.slateDark,
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                        onPressed: () {
                          setState(() {
                            _latitude = lat;
                            _longitude = lon;
                            _areaController.text = preset['area'] as String;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Set as default switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Default Address', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Used automatically during checkout', style: TextStyle(fontSize: 12)),
                value: _isDefault,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isDefault = val),
              ),

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEdit ? 'Save Changes' : 'Save Address',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
