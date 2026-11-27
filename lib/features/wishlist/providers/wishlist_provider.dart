// lib/features/wishlist/providers/wishlist_provider.dart

import 'package:flutter/foundation.dart';
import '../../home/models/product_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service;
  List<ProductModel> _items = [];
  bool _isLoading = false;

  WishlistProvider(this._service) {
    _items = _service.loadWishlist();
  }

  List<ProductModel> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isLoading => _isLoading;

  bool isWishlisted(String productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      final remote = await _service.fetchRemoteWishlist();
      if (remote != null) {
        _items = remote;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncOnLogin() async {
    final localIds = _items
        .map((p) => int.tryParse(p.id))
        .whereType<int>()
        .toList();
    _isLoading = true;
    notifyListeners();
    try {
      final synced = localIds.isEmpty
          ? await _service.fetchRemoteWishlist()
          : await _service.syncRemote(localIds);
      if (synced != null) {
        _items = synced;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearOnLogout() async {
    _items = [];
    notifyListeners();
    await _service.clearLocalWishlist();
  }

  Future<void> toggle(ProductModel product) async {
    final index = _items.indexWhere((item) => item.id == product.id);
    final bool wasPresent = index >= 0;
    if (wasPresent) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
    await _service.saveWishlist(_items);

    final numericId = int.tryParse(product.id);
    if (numericId != null) {
      final remote = wasPresent
          ? await _service.removeFromRemote(numericId)
          : await _service.addToRemote(numericId);
      if (remote != null) {
        _items = remote;
        notifyListeners();
      }
    }
  }

  Future<void> remove(String productId) async {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
    await _service.saveWishlist(_items);

    final numericId = int.tryParse(productId);
    if (numericId != null) {
      final remote = await _service.removeFromRemote(numericId);
      if (remote != null) {
        _items = remote;
        notifyListeners();
      }
    }
  }

  Future<void> add(ProductModel product) async {
    if (isWishlisted(product.id)) return;
    _items.add(product);
    notifyListeners();
    await _service.saveWishlist(_items);

    final numericId = int.tryParse(product.id);
    if (numericId != null) {
      final remote = await _service.addToRemote(numericId);
      if (remote != null) {
        _items = remote;
        notifyListeners();
      }
    }
  }
}
