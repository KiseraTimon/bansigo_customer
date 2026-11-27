// lib/features/wishlist/services/wishlist_service.dart

import 'dart:convert';
import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/models/product_model.dart';

class WishlistService {
  final LocalStorage _storage;
  final ApiClient? _apiClient;

  WishlistService(this._storage, {ApiClient? apiClient}) : _apiClient = apiClient;

  bool get hasRemoteClient => _apiClient != null;

  List<ProductModel> loadWishlist() {
    final rawJson = _storage.getWishlistJson();
    if (rawJson == null || rawJson.trim().isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) return [];
      final List<ProductModel> list = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          list.add(ProductModel.fromJson(item));
        } else if (item is Map) {
          list.add(ProductModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWishlist(List<ProductModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _storage.saveWishlistJson(encoded);
  }

  Future<void> clearLocalWishlist() async {
    await _storage.saveWishlistJson('[]');
  }

  List<ProductModel> _parseProductList(dynamic response) {
    if (response is! List) return [];
    final List<ProductModel> result = [];
    for (final raw in response) {
      if (raw is Map<String, dynamic>) {
        result.add(ProductModel.fromJson(raw));
      } else if (raw is Map) {
        result.add(ProductModel.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    return result;
  }

  Future<List<ProductModel>?> fetchRemoteWishlist() async {
    if (_apiClient == null) return null;
    try {
      final res = await _apiClient.get(ApiEndpoints.wishlist);
      final parsed = _parseProductList(res);
      await saveWishlist(parsed);
      return parsed;
    } catch (e) {
      AppLogger.w('Failed to fetch remote wishlist: $e');
      return null;
    }
  }

  Future<List<ProductModel>?> addToRemote(int productId) async {
    if (_apiClient == null) return null;
    try {
      final res = await _apiClient.postJson(ApiEndpoints.wishlistItem(productId), {});
      final parsed = _parseProductList(res);
      await saveWishlist(parsed);
      return parsed;
    } catch (e) {
      AppLogger.w('Failed to add product $productId to remote wishlist: $e');
      return null;
    }
  }

  Future<List<ProductModel>?> removeFromRemote(int productId) async {
    if (_apiClient == null) return null;
    try {
      final res = await _apiClient.delete(ApiEndpoints.wishlistItem(productId));
      final parsed = _parseProductList(res);
      await saveWishlist(parsed);
      return parsed;
    } catch (e) {
      AppLogger.w('Failed to remove product $productId from remote wishlist: $e');
      return null;
    }
  }

  Future<List<ProductModel>?> syncRemote(List<int> productIds) async {
    if (_apiClient == null) return null;
    try {
      final res = await _apiClient.postJson(
        ApiEndpoints.wishlistSync,
        {'product_ids': productIds},
      );
      final parsed = _parseProductList(res);
      await saveWishlist(parsed);
      return parsed;
    } catch (e) {
      AppLogger.w('Failed to sync wishlist on login: $e');
      return null;
    }
  }
}
