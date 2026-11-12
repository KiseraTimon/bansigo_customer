// lib/features/address/models/coverage_model.dart

class CoverageModel {
  final bool isCovered;
  final double distanceToStoreM;
  final double maxRadiusKm;
  final String supermarketName;
  final double supermarketLatitude;
  final double supermarketLongitude;

  const CoverageModel({
    required this.isCovered,
    required this.distanceToStoreM,
    required this.maxRadiusKm,
    required this.supermarketName,
    required this.supermarketLatitude,
    required this.supermarketLongitude,
  });

  double get distanceInKm => distanceToStoreM / 1000.0;

  factory CoverageModel.fromJson(Map<String, dynamic> json) {
    final coords = json['supermarket_coords'] as Map<String, dynamic>? ?? {};
    return CoverageModel(
      isCovered: json['is_covered'] as bool? ?? false,
      distanceToStoreM: double.tryParse(json['distance_to_store_m']?.toString() ?? '0') ?? 0.0,
      maxRadiusKm: double.tryParse(json['max_radius_km']?.toString() ?? '7.0') ?? 7.0,
      supermarketName: json['supermarket_name'] as String? ?? 'Bansi Mega Supermarket',
      supermarketLatitude: double.tryParse(coords['latitude']?.toString() ?? '-1.286389') ?? -1.286389,
      supermarketLongitude: double.tryParse(coords['longitude']?.toString() ?? '36.817222') ?? 36.817222,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_covered': isCovered,
      'distance_to_store_m': distanceToStoreM,
      'max_radius_km': maxRadiusKm,
      'supermarket_name': supermarketName,
      'supermarket_coords': {
        'latitude': supermarketLatitude,
        'longitude': supermarketLongitude,
      },
    };
  }
}
