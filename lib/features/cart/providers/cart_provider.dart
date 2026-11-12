// lib/features/cart/providers/cart_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/cart_session_model.dart';

class CartProvider extends ChangeNotifier {
  final LocalStorage _storage;
  final List<CartSessionModel> _sessions = [];
  String? _activeSessionId;

  CartProvider(this._storage) {
    _loadFromStorage();
  }

  // Multi-cart sessions getters
  List<CartSessionModel> get sessions => List.unmodifiable(_sessions);
  List<CartSessionModel> get activeSessionsWithItems =>
      _sessions.where((s) => s.isNotEmpty).toList();
  int get ongoingCartsCount => activeSessionsWithItems.length;

  CartSessionModel get activeSession {
    if (_sessions.isEmpty) {
      final initial = CartSessionModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cart #1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _sessions.add(initial);
      _activeSessionId = initial.id;
      return initial;
    }
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  String get activeSessionId => activeSession.id;
  String get activeSessionName => activeSession.name;

  // Single active-cart convenience getters (maintains backwards compatibility)
  List<CartItemModel> get items => activeSession.items.values.toList();
  Map<String, CartItemModel> get itemsMap => Map.unmodifiable(activeSession.items);

  int get totalQuantity => activeSession.totalQuantity;
  int get itemCount => activeSession.itemCount;
  bool get isEmpty => activeSession.isEmpty;
  bool get isNotEmpty => activeSession.isNotEmpty;

  double get subtotal => activeSession.subtotal;
  String get formattedSubtotal => activeSession.formattedSubtotal;

  int getQuantity(String productId) => activeSession.items[productId]?.quantity ?? 0;
  bool contains(String productId) => activeSession.items.containsKey(productId);

  CartSessionModel? getSessionById(String id) {
    try {
      return _sessions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new ongoing cart
  CartSessionModel createNewSession({String? name}) {
    final nextNumber = _sessions.length + 1;
    final newSession = CartSessionModel(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Cart #$nextNumber',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _sessions.add(newSession);
    _activeSessionId = newSession.id;
    _saveToStorage();
    notifyListeners();
    return newSession;
  }

  /// Switch active ongoing cart session
  void switchSession(String sessionId) {
    if (_sessions.any((s) => s.id == sessionId)) {
      _activeSessionId = sessionId;
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Delete an ongoing cart session
  void deleteSession(String sessionId) {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_sessions.isEmpty) {
      final initial = CartSessionModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Cart #1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _sessions.add(initial);
      _activeSessionId = initial.id;
    } else if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.first.id;
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Rename an ongoing cart session
  void renameSession(String sessionId, String newName) {
    final session = getSessionById(sessionId);
    if (session != null && newName.trim().isNotEmpty) {
      session.name = newName.trim();
      session.updatedAt = DateTime.now();
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Add item directly into a specific cart session
  void addItemToSession(String sessionId, ProductModel product, {int quantity = 1}) {
    if (quantity <= 0) return;
    final session = getSessionById(sessionId) ?? activeSession;
    if (session.items.containsKey(product.id)) {
      session.items[product.id]!.quantity += quantity;
    } else {
      session.items[product.id] = CartItemModel(product: product, quantity: quantity);
    }
    session.updatedAt = DateTime.now();
    _activeSessionId = session.id;
    _saveToStorage();
    notifyListeners();
  }

  /// Add item to current active cart session
  void addItem(ProductModel product, {int quantity = 1}) {
    addItemToSession(activeSession.id, product, quantity: quantity);
  }

  /// Loads items from an existing order into an ongoing cart session.
  /// If [createDedicatedSession] is true, creates a new cart session (e.g. "Order #1234"),
  /// otherwise appends to the current active session.
  CartSessionModel loadOrderItemsIntoCart({
    required List<dynamic> items,
    String? sessionName,
    bool createDedicatedSession = false,
  }) {
    CartSessionModel session;
    if (createDedicatedSession) {
      session = createNewSession(name: sessionName ?? 'Order Items');
    } else {
      session = activeSession;
    }

    for (final raw in items) {
      if (raw is! Map<String, dynamic>) continue;
      final pid = raw['product_id']?.toString() ?? '0';
      final name = raw['product_name']?.toString() ?? 'Item';
      final price = (raw['unit_price'] is num)
          ? (raw['unit_price'] as num).toDouble()
          : double.tryParse(raw['unit_price']?.toString() ?? '0') ?? 0.0;
      final qty = (raw['quantity'] is num)
          ? (raw['quantity'] as num).toInt()
          : int.tryParse(raw['quantity']?.toString() ?? '1') ?? 1;
      final unit = raw['unit']?.toString() ?? 'piece';

      final product = ProductModel(
        id: pid,
        name: name,
        price: price,
        unit: unit,
        category: 'Grocery',
      );

      if (session.items.containsKey(pid)) {
        session.items[pid]!.quantity += qty;
      } else {
        session.items[pid] = CartItemModel(product: product, quantity: qty);
      }
    }

    session.updatedAt = DateTime.now();
    _activeSessionId = session.id;
    _saveToStorage();
    notifyListeners();
    return session;
  }

  void decrementItem(String productId) {
    final session = activeSession;
    if (!session.items.containsKey(productId)) return;
    if (session.items[productId]!.quantity > 1) {
      session.items[productId]!.quantity -= 1;
    } else {
      session.items.remove(productId);
    }
    session.updatedAt = DateTime.now();
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(String productId) {
    final session = activeSession;
    if (session.items.remove(productId) != null) {
      session.updatedAt = DateTime.now();
      _saveToStorage();
      notifyListeners();
    }
  }

  void updateQuantity(String productId, int quantity) {
    final session = activeSession;
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    if (session.items.containsKey(productId)) {
      session.items[productId]!.quantity = quantity;
      session.updatedAt = DateTime.now();
      _saveToStorage();
      notifyListeners();
    }
  }

  void incrementItem(String productId) {
    final session = activeSession;
    if (session.items.containsKey(productId)) {
      session.items[productId]!.quantity += 1;
      session.updatedAt = DateTime.now();
      _saveToStorage();
      notifyListeners();
    }
  }

  void clear() => clearCart();

  void clearCart() {
    activeSession.items.clear();
    activeSession.updatedAt = DateTime.now();
    _saveToStorage();
    notifyListeners();
  }

  /// Called after successful checkout: removes the checked out cart session if multiple exist
  void checkoutCompleted() {
    if (_sessions.length > 1) {
      final currentId = activeSession.id;
      _sessions.removeWhere((s) => s.id == currentId);
      _activeSessionId = _sessions.first.id;
    } else {
      activeSession.items.clear();
      activeSession.updatedAt = DateTime.now();
    }
    _saveToStorage();
    notifyListeners();
  }

  void _loadFromStorage() {
    try {
      // 1. Try loading all multi-cart sessions
      final sessionsJson = _storage.getCartSessionsJson();
      if (sessionsJson != null && sessionsJson.isNotEmpty) {
        final decoded = jsonDecode(sessionsJson);
        if (decoded is List) {
          _sessions.clear();
          for (final raw in decoded) {
            if (raw is Map<String, dynamic>) {
              _sessions.add(CartSessionModel.fromJson(raw));
            }
          }
        }
      }

      // 2. Migration fallback: check legacy single cart storage if sessions empty
      if (_sessions.isEmpty) {
        final legacyCartJson = _storage.getCartJson();
        final legacyItems = <String, CartItemModel>{};
        if (legacyCartJson != null && legacyCartJson.isNotEmpty) {
          final decoded = jsonDecode(legacyCartJson);
          if (decoded is List) {
            for (final raw in decoded) {
              if (raw is Map<String, dynamic>) {
                final item = CartItemModel.fromJson(raw);
                legacyItems[item.product.id] = item;
              }
            }
          }
        }

        final initial = CartSessionModel(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Cart #1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          items: legacyItems,
        );
        _sessions.add(initial);
      }

      // 3. Restore active cart session ID
      _activeSessionId = _storage.getActiveCartId();
      if (_activeSessionId == null || !_sessions.any((s) => s.id == _activeSessionId)) {
        _activeSessionId = _sessions.first.id;
      }
    } catch (e) {
      AppLogger.w('Failed to load multi-cart from storage: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final rawSessions = _sessions.map((s) => s.toJson()).toList();
      await _storage.saveCartSessionsJson(jsonEncode(rawSessions));
      if (_activeSessionId != null) {
        await _storage.setActiveCartId(_activeSessionId!);
      }
      // Also sync active items to legacy key for backwards compatibility
      final rawActiveItems = activeSession.items.values.map((i) => i.toJson()).toList();
      await _storage.saveCartJson(jsonEncode(rawActiveItems));
    } catch (e) {
      AppLogger.w('Failed to persist multi-cart to storage: $e');
    }
  }
}
