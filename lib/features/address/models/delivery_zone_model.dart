// lib/features/address/models/delivery_zone_model.dart

class DeliveryZoneModel {
  final int id;
  final String name;
  final double deliveryFee;
  final double minOrderAmount;
  final int? estimatedMinutes;
  final bool isActive;

  const DeliveryZoneModel({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.minOrderAmount,
    this.estimatedMinutes,
    this.isActive = true,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'General Zone',
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      minOrderAmount: double.tryParse(json['min_order_amount']?.toString() ?? '0') ?? 0.0,
      estimatedMinutes: json['estimated_minutes'] as int?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'delivery_fee': deliveryFee,
      'min_order_amount': minOrderAmount,
      'estimated_minutes': estimatedMinutes,
      'is_active': isActive,
    };
  }
}
