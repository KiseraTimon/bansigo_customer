// lib/features/notifications/services/notification_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../models/notification_model.dart';

class NotificationService {
  static const _prefsKey = 'cached_customer_notifications';
  final ApiClient _apiClient;
  final LocalStorage? _storage;

  NotificationService(this._apiClient, {LocalStorage? storage}) : _storage = storage;

  Future<List<NotificationModel>> getCachedNotifications({String? filterType}) async {
    try {
      String? raw;
      if (_storage != null) {
        raw = _storage.getCachedNotificationsJson();
      } else {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_prefsKey);
      }
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        var list = decoded
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (filterType != null && filterType != 'all') {
          list = list.where((n) => n.type == filterType).toList();
        }
        return list;
      }
    } catch (e) {
      AppLogger.w('Failed to read cached notifications: $e');
    }
    if (filterType != null && filterType != 'all') {
      return defaultNotifications.where((n) => n.type == filterType).toList();
    }
    return List.from(defaultNotifications);
  }

  Future<void> saveCachedNotifications(List<NotificationModel> items) async {
    try {
      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      if (_storage != null) {
        await _storage.saveCachedNotificationsJson(encoded);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, encoded);
      }
    } catch (e) {
      AppLogger.w('Failed to persist cached notifications: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      if (_storage != null) {
        await _storage.clearCachedNotifications();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefsKey);
      }
    } catch (_) {}
  }

  Future<List<NotificationModel>> getNotifications({String? filterType}) async {
    try {
      final params = <String, dynamic>{};
      if (filterType != null && filterType != 'all') {
        params['filter_type'] = filterType;
      }
      final res = await _apiClient.get(ApiEndpoints.notifications, queryParameters: params);
      final List? rawItems = res is Map<String, dynamic> && res['items'] is List
          ? res['items'] as List
          : (res is List ? res : null);
      if (rawItems != null) {
        final list = rawItems
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (filterType == null || filterType == 'all') {
          await saveCachedNotifications(list);
        }
        return list;
      }
    } catch (e) {
      AppLogger.w('Could not fetch notifications from server: $e');
    }
    return getCachedNotifications(filterType: filterType);
  }

  Future<bool> markAsRead(String id) async {
    try {
      await _apiClient.patchJson(ApiEndpoints.notificationRead(id), {});
      return true;
    } catch (e) {
      AppLogger.w('Could not mark notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _apiClient.postJson(ApiEndpoints.notificationsReadAll, {});
      return true;
    } catch (e) {
      AppLogger.w('Could not mark all notifications as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.notificationDelete(id));
      return true;
    } catch (e) {
      AppLogger.w('Could not delete notification: $e');
      return false;
    }
  }

  Future<bool> clearReadNotifications() async {
    try {
      await _apiClient.delete(ApiEndpoints.notificationsClearRead);
      return true;
    } catch (e) {
      AppLogger.w('Could not clear read notifications: $e');
      return false;
    }
  }

  static final List<NotificationModel> defaultNotifications = [
    const NotificationModel(
      id: 'notif-1',
      title: 'Welcome to BansiGo Mega Store!',
      message: 'Enjoy 15-20 min lightning delivery right to your door in Wasweta & Migori.',
      type: 'system',
      createdAt: '10 mins ago',
      isRead: false,
      actionType: 'explore',
      actionPayload: 'all',
    ),
    const NotificationModel(
      id: 'notif-2',
      title: 'Flash Sale: Up to 25% OFF Deli & Bakery',
      message: 'Freshly baked bread, savory meat pies and deli specials are on discount today.',
      type: 'promo',
      createdAt: '1 hour ago',
      isRead: false,
      actionType: 'category',
      actionPayload: 'bakery-pastries',
    ),
    const NotificationModel(
      id: 'notif-3',
      title: 'Delivery Zone Active • 7KM Supermarket Radius',
      message: 'Instant delivery available across all zones from Bansi Mega Supermarket.',
      type: 'delivery',
      createdAt: '3 hours ago',
      isRead: false,
      actionType: 'address',
      actionPayload: 'map',
    ),
    const NotificationModel(
      id: 'notif-4',
      title: 'Highland Honey Deal Live',
      message: 'Pure Kenyan Highland Honey 500g is today\'s featured deal with extra reward points.',
      type: 'promo',
      createdAt: 'Yesterday',
      isRead: true,
      actionType: 'product',
      actionPayload: 'fresh_honey',
    ),
  ];
}
