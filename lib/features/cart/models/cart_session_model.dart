// lib/features/cart/models/cart_session_model.dart

import 'cart_item_model.dart';

class CartSessionModel {
  final String id;
  String name;
  final DateTime createdAt;
  DateTime updatedAt;
  final Map<String, CartItemModel> items;

  CartSessionModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    Map<String, CartItemModel>? items,
  }) : items = items ?? {};

  int get totalQuantity => items.values.fold(0, (sum, i) => sum + i.quantity);
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  double get subtotal => items.values.fold(0.0, (sum, i) => sum + i.lineTotal);
  String get formattedSubtotal => 'KES ${subtotal.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'items': items.values.map((i) => i.toJson()).toList(),
      };

  factory CartSessionModel.fromJson(Map<String, dynamic> json) {
    final itemMap = <String, CartItemModel>{};
    if (json['items'] is List) {
      for (final raw in json['items'] as List) {
        if (raw is Map<String, dynamic>) {
          final item = CartItemModel.fromJson(raw);
          itemMap[item.product.id] = item;
        }
      }
    }
    return CartSessionModel(
      id: json['id'] as String? ?? 'cart_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Cart',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      items: itemMap,
    );
  }
}
