// lib/features/orders/models/order_model.dart

enum OrderTabType { ongoing, history }

class CustomerOrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String fulfilmentType;
  final double total;
  final DateTime createdAt;

  const CustomerOrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.fulfilmentType,
    required this.total,
    required this.createdAt,
  });

  String get formattedTotal => 'KES ${total.toStringAsFixed(2)}';

  factory CustomerOrderModel.fromJson(Map<String, dynamic> json) {
    final rawTotal = json['total'] ?? json['adjusted_total'];
    final double parsedTotal = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '0') ?? 0.0;

    DateTime date = DateTime.now();
    if (json['created_at'] != null) {
      date = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return CustomerOrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending_payment',
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? 'mpesa',
      fulfilmentType: json['fulfilment_type']?.toString() ?? 'delivery',
      total: parsedTotal,
      createdAt: date,
    );
  }
}
