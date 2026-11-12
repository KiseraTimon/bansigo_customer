// lib/features/address/screens/sections/current_address_preview_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/address_model.dart';

class CurrentAddressPreviewSection extends StatelessWidget {
  final AddressModel? address;
  final double distanceKm;
  final bool isFarApart;
  final VoidCallback? onChangeAddressTap;

  const CurrentAddressPreviewSection({
    super.key,
    required this.address,
    required this.distanceKm,
    required this.isFarApart,
    this.onChangeAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_off_rounded, size: 44, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No Delivery Address Selected', style: AppTextStyles.h2.copyWith(fontSize: 16)),
            const SizedBox(height: 6),
            Text(
              'Add an address within the 7km delivery radius of Bansi Mega Supermarket.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final storeLatLng = const LatLng(
      AppConfig.supermarketLatitude,
      AppConfig.supermarketLongitude,
    );
    final destLatLng = LatLng(address!.latitude, address!.longitude);

    // Compute center point between supermarket and customer
    final centerLat = (storeLatLng.latitude + destLatLng.latitude) / 2;
    final centerLon = (storeLatLng.longitude + destLatLng.longitude) / 2;
    final centerLatLng = LatLng(centerLat, centerLon);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isFarApart ? AppColors.error.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: isFarApart ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Information
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            address!.label.toLowerCase().contains('work')
                                ? Icons.work_outline_rounded
                                : Icons.home_outlined,
                            size: 14,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            address!.label.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (address!.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (onChangeAddressTap != null)
                      TextButton(
                        onPressed: onChangeAddressTap,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'CHANGE',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  address!.displayAddress,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    fontSize: 15,
                    color: AppColors.slateDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address!.recipientName} • ${address!.recipientPhone}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 2. OpenStreetMap Interactive Live Preview
          SizedBox(
            height: 185,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: centerLatLng,
                    initialZoom: 12.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    // OSM Standard Map Tiles
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bansigo.customer',
                    ),

                    // 7km Supermarket Delivery Radius Circle
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: storeLatLng,
                          radius: AppConfig.maxDeliveryRadiusKm * 1000,
                          useRadiusInMeter: true,
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderColor: AppColors.primary,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                    // Polyline connecting Supermarket to Destination
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [storeLatLng, destLatLng],
                          color: isFarApart ? AppColors.error : AppColors.primaryDark,
                          strokeWidth: 3.0,
                        ),
                      ],
                    ),

                    // Markers for Supermarket and Customer
                    MarkerLayer(
                      markers: [
                        // Bansi Mega Supermarket Marker
                        Marker(
                          point: storeLatLng,
                          width: 90,
                          height: 62,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                                child: const Text(
                                  'Bansi Mega',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primaryDark,
                                size: 26,
                              ),
                            ],
                          ),
                        ),

                        // Customer Destination Marker
                        Marker(
                          point: destLatLng,
                          width: 90,
                          height: 62,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isFarApart ? AppColors.error : AppColors.slateDark,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                                child: Text(
                                  address!.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.location_pin,
                                color: isFarApart ? AppColors.error : AppColors.primary,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Map Legend Overlay Pill
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '7km Radius Zone',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Proximity Status Banner / Warning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFarApart
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.primaryLight.withValues(alpha: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isFarApart ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                  color: isFarApart ? AppColors.error : AppColors.primaryDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFarApart
                            ? 'Warning: Delivery Address Out of Range'
                            : 'Within 7km Delivery Radius',
                        style: AppTextStyles.bodySemiBold.copyWith(
                          color: isFarApart ? AppColors.error : AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFarApart
                            ? 'This location is ${distanceKm.toStringAsFixed(1)} km from Bansi Mega Supermarket, which exceeds our 7.0 km radius. Delivery cannot be guaranteed to this point.'
                            : '${distanceKm.toStringAsFixed(1)} km from ${AppConfig.supermarketName}. Standard delivery within 15–25 minutes.',
                        style: AppTextStyles.caption.copyWith(
                          color: isFarApart ? AppColors.error : AppColors.slateDark,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
