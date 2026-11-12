// lib/features/wishlist/providers/wishlist_provider.dart

import 'package:flutter/foundation.dart';
import '../../home/models/product_model.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service;
  List<ProductModel> _items = [];

  WishlistProvider(this._service) {
    _items = _service.loadWishlist();
  }

  List<ProductModel> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool isWishlisted(String productId) {
    return _items.any((item) => item.id == productId);
  }

  Future<void> toggle(ProductModel product) async {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
    notifyListeners();
    await _service.saveWishlist(_items);
  }

  Future<void> remove(String productId) async {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
    await _service.saveWishlist(_items);
  }

  Future<void> add(ProductModel product) async {
    if (!isWishlisted(product.id)) {
      _items.add(product);
      notifyListeners();
      await _service.saveWishlist(_items);
    }
  }
}
