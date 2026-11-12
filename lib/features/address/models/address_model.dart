// lib/features/address/models/address_model.dart

import 'delivery_zone_model.dart';

class AddressModel {
  final int id;
  final String label;
  final String recipientName;
  final String recipientPhone;
  final int zoneId;
  final DeliveryZoneModel? zone;
  final String area;
  final String? streetAddress;
  final String? landmark;
  final String? directions;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime? createdAt;

  const AddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.recipientPhone,
    required this.zoneId,
    this.zone,
    required this.area,
    this.streetAddress,
    this.landmark,
    this.directions,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.createdAt,
  });

  String get displayAddress {
    // Determine the primary location name from area or streetAddress
    String mainLocation = '';
    if (area.trim().isNotEmpty) {
      mainLocation = area.trim();
    } else if (streetAddress != null && streetAddress!.trim().isNotEmpty) {
      mainLocation = streetAddress!.trim();
    }

    if (mainLocation.isEmpty) {
      return 'Migori Location';
    }

    // Clean up duplicates and extraneous tokens
    final rawTokens = mainLocation
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final distinctTokens = <String>[];
    for (final token in rawTokens) {
      if (!distinctTokens.any((t) => t.toLowerCase() == token.toLowerCase())) {
        distinctTokens.add(token);
      }
    }

    // Take the primary location name (first 1-2 distinct tokens)
    final locName = distinctTokens.take(2).join(', ');

    // Always ensure county (Migori) is present if not already in locName
    final hasMigori = locName.toLowerCase().contains('migori');
    final formatted = hasMigori ? locName : '$locName, Migori';

    return formatted;
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String? ?? 'Home',
      recipientName: json['recipient_name'] as String? ?? '',
      recipientPhone: json['recipient_phone'] as String? ?? '',
      zoneId: json['zone_id'] as int? ?? 1,
      zone: json['zone'] != null ? DeliveryZoneModel.fromJson(json['zone'] as Map<String, dynamic>) : null,
      area: json['area'] as String? ?? '',
      streetAddress: json['street_address'] as String?,
      landmark: json['landmark'] as String?,
      directions: json['directions'] as String?,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson({bool forCreation = false}) {
    final map = <String, dynamic>{
      'label': label,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'zone_id': zoneId,
      'area': area,
      'street_address': streetAddress,
      'landmark': landmark,
      'directions': directions,
      'latitude': double.parse(latitude.toStringAsFixed(6)),
      'longitude': double.parse(longitude.toStringAsFixed(6)),
      'is_default': isDefault,
    };
    if (!forCreation) {
      map['id'] = id;
      if (zone != null) {
        map['zone'] = zone!.toJson();
      }
      if (createdAt != null) {
        map['created_at'] = createdAt!.toIso8601String();
      }
    }
    return map;
  }

  AddressModel copyWith({
    int? id,
    String? label,
    String? recipientName,
    String? recipientPhone,
    int? zoneId,
    DeliveryZoneModel? zone,
    String? area,
    String? streetAddress,
    String? landmark,
    String? directions,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      zoneId: zoneId ?? this.zoneId,
      zone: zone ?? this.zone,
      area: area ?? this.area,
      streetAddress: streetAddress ?? this.streetAddress,
      landmark: landmark ?? this.landmark,
      directions: directions ?? this.directions,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
