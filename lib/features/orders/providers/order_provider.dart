// lib/features/orders/providers/order_provider.dart

import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final CustomerOrderService _service;

  OrderTabType _activeTab = OrderTabType.ongoing;
  bool _isLoading = false;
  List<CustomerOrderModel> _ongoingOrders = [];
  List<CustomerOrderModel> _historyOrders = [];
  int _loadEpoch = 0;

  OrderProvider(this._service);

  OrderTabType get activeTab => _activeTab;
  bool get isLoading => _isLoading;
  List<CustomerOrderModel> get currentOrders =>
      _activeTab == OrderTabType.ongoing ? _ongoingOrders : _historyOrders;

  void setTab(OrderTabType tab) {
    if (_activeTab != tab) {
      _activeTab = tab;
      notifyListeners();
      loadOrders(tab: tab);
    }
  }

  Future<void> loadOrders({OrderTabType? tab}) async {
    final targetTab = tab ?? _activeTab;
    final epoch = ++_loadEpoch;
    _isLoading = true;
    notifyListeners();
    try {
      final orders = await _service.fetchOrders(targetTab);
      if (targetTab == OrderTabType.ongoing) {
        _ongoingOrders = orders;
      } else {
        _historyOrders = orders;
      }
    } finally {
      if (epoch == _loadEpoch) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void clearOnLogout() {
    _loadEpoch++;
    _ongoingOrders = [];
    _historyOrders = [];
    _isLoading = false;
    notifyListeners();
  }

  CustomerOrderService get service => _service;

  /// Fetches detailed order information including line items
  Future<Map<String, dynamic>?> fetchOrderDetail(int orderId) =>
      _service.fetchOrderDetail(orderId);

  /// Cancels an order and refreshes the current orders list
  Future<bool> cancelOrder(int orderId, {String reason = 'Cancelled by customer'}) async {
    final success = await _service.cancelOrder(orderId, reason: reason);
    if (success) {
      await loadOrders();
    }
    return success;
  }
}
