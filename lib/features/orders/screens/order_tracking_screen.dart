// lib/features/orders/screens/order_tracking_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../reviews/widgets/order_review_sheet.dart';
import '../providers/order_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _tracking;
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchTracking();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchTracking(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTracking({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }
    final provider = context.read<OrderProvider>();
    final data = await provider.service.fetchTracking(widget.orderId);
    if (!mounted) return;
    setState(() {
      if (data != null) {
        _tracking = data;
      }
      _isLoading = false;
    });
    if (data != null && data['is_delivered'] == true) {
      _pollTimer?.cancel();
      provider.loadOrders();
    }
  }

  String _formatDeliveryStatus(String status) {
    switch (status.toLowerCase()) {
      case 'unassigned':
        return 'Finding Best Rider';
      case 'assigned':
        return 'Rider Matched (Confirming)';
      case 'accepted':
        return 'Rider Heading to Store';
      case 'picked_up':
        return 'On the Way to You';
      case 'arrived':
        return 'Rider Arrived at Gate';
      case 'delivered':
        return 'Delivered';
      case 'failed':
        return 'Reassigning Delivery';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  int _stepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'unassigned':
      case 'assigned':
        return 0;
      case 'accepted':
        return 1;
      case 'picked_up':
        return 2;
      case 'arrived':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracking = _tracking;
    final deliveryStatus = tracking?['status']?.toString() ?? 'unassigned';
    final isOverdue = tracking?['is_overdue'] == true;
    final handoverCode = tracking?['handover_code']?.toString();
    final estimatedMins = (tracking?['estimated_minutes'] as num?)?.toInt();
    final rider = tracking?['rider'] as Map<String, dynamic>?;
    final riderLoc = tracking?['rider_location'] as Map<String, dynamic>?;
    final storeLoc = tracking?['supermarket_location'] as Map<String, dynamic>?;
    final dropLoc = tracking?['delivery_location'] as Map<String, dynamic>?;
    final rawWaypoints = tracking?['route_waypoints'] as List<dynamic>? ?? [];

    final storePoint = LatLng(
      (storeLoc?['latitude'] as num?)?.toDouble() ?? AppConfig.supermarketLatitude,
      (storeLoc?['longitude'] as num?)?.toDouble() ?? AppConfig.supermarketLongitude,
    );
    final dropPoint = LatLng(
      (dropLoc?['latitude'] as num?)?.toDouble() ?? AppConfig.supermarketLatitude,
      (dropLoc?['longitude'] as num?)?.toDouble() ?? AppConfig.supermarketLongitude,
    );
    final riderPoint = riderLoc != null && riderLoc['latitude'] != null && riderLoc['longitude'] != null
        ? LatLng((riderLoc['latitude'] as num).toDouble(), (riderLoc['longitude'] as num).toDouble())
        : null;

    final polylinePoints = rawWaypoints
        .whereType<List>()
        .where((p) => p.length >= 2)
        .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();

    final mapCenter = riderPoint ?? dropPoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track ${widget.orderNumber}',
              style: AppTextStyles.h2.copyWith(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              _formatDeliveryStatus(deliveryStatus),
              style: AppTextStyles.caption.copyWith(
                fontSize: 11.5,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.slateDark),
            onPressed: () => _fetchTracking(),
          ),
        ],
      ),
      body: _isLoading && tracking == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : tracking == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Live delivery details will appear once payment is confirmed.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchTracking(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => _fetchTracking(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (isOverdue)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_off_rounded, color: AppColors.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'This delivery is running past its estimated SLA. Dispatch operations has been alerted.',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12.5,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 1. Live Map
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 240,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: mapCenter,
                              initialZoom: 14.2,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.bansigo.customer',
                              ),
                              if (polylinePoints.isNotEmpty)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: polylinePoints,
                                      strokeWidth: 4.5,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: storePoint,
                                    width: 38,
                                    height: 38,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDark,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  Marker(
                                    point: dropPoint,
                                    width: 38,
                                    height: 38,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.warning,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  if (riderPoint != null)
                                    Marker(
                                      point: riderPoint,
                                      width: 44,
                                      height: 44,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withValues(alpha: 0.35),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 22),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Customer Handover PIN Card (BansiGo Customer Brand Green)
                      if (handoverCode != null && handoverCode.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryDark, AppColors.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.pin_rounded, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Handover PIN',
                                      style: AppTextStyles.bodyBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Share this code with the rider at your door to confirm parcel receipt.',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primarySubtle,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  handoverCode,
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 3. Status Timeline Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Live Delivery Progress',
                                  style: AppTextStyles.bodyBold.copyWith(fontSize: 14.5),
                                ),
                                if (estimatedMins != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySubtle,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '~$estimatedMins mins ETA',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryDark,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildStepRow('Order Paid & Matching Rider', 0, _stepIndex(deliveryStatus)),
                            _buildStepRow('Rider Accepted & Heading to Store', 1, _stepIndex(deliveryStatus)),
                            _buildStepRow('Picked Up & On the Way', 2, _stepIndex(deliveryStatus)),
                            _buildStepRow('Rider Arrived at Location', 3, _stepIndex(deliveryStatus)),
                            _buildStepRow('Delivered & Handover Verified', 4, _stepIndex(deliveryStatus), isLast: true),
                          ],
                        ),
                      ),

                      // 4. Rider Info Card
                      if (rider != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primarySubtle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.two_wheeler_rounded, color: AppColors.primaryDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Rider #${rider['id']}',
                                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                                    ),
                                    Text(
                                      '${(rider['vehicle_type'] ?? 'motorcycle').toString().toUpperCase()} • ${rider['vehicle_plate'] ?? 'BansiGo Fleet'}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (rider['rating_average'] != null)
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${rider['rating_average']}',
                                      style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (tracking['is_delivered'] == true) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () => OrderReviewSheet.show(
                              context,
                              orderId: widget.orderId,
                              orderNumber: widget.orderNumber,
                            ),
                            icon: const Icon(Icons.star_rate_rounded, size: 18),
                            label: const Text(
                              'Rate Rider & Order Items',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildStepRow(String label, int index, int currentIndex, {bool isLast = false}) {
    final completed = currentIndex >= index;
    final active = currentIndex == index;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: completed ? AppColors.primary : AppColors.divider,
                shape: BoxShape.circle,
                border: active ? Border.all(color: AppColors.primaryLight, width: 3) : null,
              ),
              child: completed
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
                color: currentIndex > index ? AppColors.primary : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : (completed ? FontWeight.w600 : FontWeight.w400),
              color: completed ? AppColors.slateDark : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
