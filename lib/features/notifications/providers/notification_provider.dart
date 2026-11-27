// lib/features/notifications/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service;

  List<NotificationModel> _notifications = List.from(NotificationService.defaultNotifications);
  bool _isLoading = false;
  String _activeFilter = 'all';

  NotificationProvider(this._service) {
    _initAndLoad();
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get activeFilter => _activeFilter;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _initAndLoad() async {
    _notifications = await _service.getCachedNotifications(filterType: _activeFilter);
    notifyListeners();
    await loadNotifications();
  }

  Future<void> loadNotifications({String? filterType}) async {
    _isLoading = true;
    if (filterType != null) _activeFilter = filterType;
    notifyListeners();

    try {
      final items = await _service.getNotifications(filterType: _activeFilter);
      _notifications = items;
    } catch (_) {
      // Cached/fallback notifications kept
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      if (_activeFilter == 'all') {
        await _service.saveCachedNotifications(_notifications);
      }
      await _service.markAsRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    if (_activeFilter == 'all') {
      await _service.saveCachedNotifications(_notifications);
    }
    await _service.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    if (_activeFilter == 'all') {
      await _service.saveCachedNotifications(_notifications);
    }
    await _service.deleteNotification(id);
  }

  Future<void> clearReadNotifications() async {
    _notifications.removeWhere((n) => n.isRead);
    notifyListeners();
    if (_activeFilter == 'all') {
      await _service.saveCachedNotifications(_notifications);
    }
    await _service.clearReadNotifications();
  }

  Future<void> resetOnLogout() async {
    await _service.clearCache();
    _notifications = List.from(NotificationService.defaultNotifications);
    _activeFilter = 'all';
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    loadNotifications(filterType: filter);
  }
}
