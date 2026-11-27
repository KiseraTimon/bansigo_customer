// lib/features/orders/services/order_service.dart

import 'dart:math';
import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../models/order_model.dart';

class CustomerOrderService {
  final ApiClient _apiClient;

  CustomerOrderService(this._apiClient);

  Future<List<CustomerOrderModel>> fetchOrders(OrderTabType tab) async {
    final tabParam = tab == OrderTabType.ongoing ? 'ongoing' : 'history';
    try {
      final res = await _apiClient.get('${ApiEndpoints.orders}?tab=$tabParam');
      final List? rawItems = res is Map<String, dynamic> && res['items'] is List
          ? res['items'] as List
          : (res is List ? res : null);
      if (rawItems != null) {
        return rawItems
            .map((item) => CustomerOrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.w('Could not fetch customer orders from server: $e');
    }
    return [];
  }

  /// Places a new order from cart basket
  Future<Map<String, dynamic>> checkout({
    required List<Map<String, dynamic>> items,
    int? addressId,
    String? customerNote,
    String? scheduledFor,
    String fulfilmentType = 'delivery',
    String paymentMethod = 'mpesa',
  }) async {
    final idempotencyKey = 'order_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    final payload = {
      'idempotency_key': idempotencyKey,
      'items': items,
      'fulfilment_type': fulfilmentType,
      'payment_method': paymentMethod,
      if (addressId != null) 'address_id': addressId,
      if (customerNote != null && customerNote.trim().isNotEmpty) 'customer_note': customerNote.trim(),
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
    };

    AppLogger.i('Submitting checkout payload: $payload');
    final res = await _apiClient.postJson(ApiEndpoints.checkout, payload);
    return res as Map<String, dynamic>;
  }

  /// Initiates M-Pesa STK push prompt for an order
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required int orderId,
    required String phone,
  }) async {
    final idempotencyKey = 'pay_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    final payload = {
      'idempotency_key': idempotencyKey,
      'phone': phone,
    };

    AppLogger.i('Initiating M-Pesa STK push for order #$orderId');
    final res = await _apiClient.postJson(ApiEndpoints.payOrderMpesa(orderId), payload);
    return res as Map<String, dynamic>;
  }

  /// Submits manual M-Pesa transaction code fallback
  Future<Map<String, dynamic>> confirmManualMpesa({
    required int orderId,
    required String transactionCode,
  }) async {
    final payload = {
      'transaction_code': transactionCode.trim().toUpperCase(),
    };

    AppLogger.i('Verifying manual M-Pesa code $transactionCode for order #$orderId');
    final res = await _apiClient.postJson(ApiEndpoints.payOrderManual(orderId), payload);
    return res as Map<String, dynamic>;
  }

  /// Checks latest payment status for an order
  Future<Map<String, dynamic>?> checkPaymentStatus(int orderId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.orderPaymentStatus(orderId));
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (e) {
      AppLogger.w('Payment status check failed: $e');
    }
    return null;
  }

  /// Fetches live delivery tracking state, rider GPS, route waypoints, and customer handover PIN
  Future<Map<String, dynamic>?> fetchTracking(int orderId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.deliveryTracking(orderId));
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch delivery tracking: $e');
    }
    return null;
  }

  /// Fetches complete order detail including line items
  Future<Map<String, dynamic>?> fetchOrderDetail(int orderId) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.orderDetail(orderId));
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch order detail: $e');
    }
    return null;
  }

  /// Cancels an order before preparation and releases reserved stock
  Future<bool> cancelOrder(int orderId, {String reason = 'Cancelled by customer'}) async {
    try {
      final res = await _apiClient.postJson(
        ApiEndpoints.cancelOrder(orderId),
        {'reason': reason},
      );
      return res is Map<String, dynamic>;
    } catch (e) {
      AppLogger.e('Failed to cancel order: $e');
      return false;
    }
  }
}
