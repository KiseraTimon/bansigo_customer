// lib/features/notifications/models/notification_model.dart

import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // "order", "promo", "delivery", "system"
  final String createdAt;
  final bool isRead;
  final String? actionType;
  final String? actionPayload;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionType,
    this.actionPayload,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      createdAt: json['created_at']?.toString() ?? '',
      isRead: json['is_read'] == true,
      actionType: json['action_type']?.toString(),
      actionPayload: json['action_payload']?.toString(),
    );
  }

  IconData get icon {
    switch (type) {
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'delivery':
        return Icons.two_wheeler_rounded;
      case 'promo':
        return Icons.local_offer_outlined;
      case 'system':
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'order':
        return const Color(0xFF2563EB);
      case 'delivery':
        return const Color(0xFF16A34A);
      case 'promo':
        return const Color(0xFFEA580C);
      case 'system':
      default:
        return const Color(0xFF7C3AED);
    }
  }

  Color get iconBgColor {
    switch (type) {
      case 'order':
        return const Color(0xFFDBEAFE);
      case 'delivery':
        return const Color(0xFFDCFCE7);
      case 'promo':
        return const Color(0xFFFFEDD5);
      case 'system':
      default:
        return const Color(0xFFEDE9FE);
    }
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actionType: actionType,
      actionPayload: actionPayload,
    );
  }
}
