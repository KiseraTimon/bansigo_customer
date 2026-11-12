// lib/features/wishlist/services/wishlist_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/storage/local_storage.dart';
import '../../home/models/product_model.dart';
import '../../../shared/illustrations/vector_illustrations.dart';

class WishlistService {
  final LocalStorage _storage;

  WishlistService(this._storage);

  static List<ProductModel> get defaultWishlistSeed => [
        const ProductModel(
          id: 'seed-nido-1',
          name: 'Nestle Nido Full Cream Milk Powder Instant',
          unit: '400g',
          price: 270.00,
          originalPrice: 342.00,
          category: 'Dairy Products',
          description:
              'Et quidem faciunt, ut summum bonum sit extremum et rationibus conquisitis de voluptate. Sed ut summum bonum sit id,',
          illustration: MilkPowderCanIllustration(size: 80),
        ),
        const ProductModel(
          id: 'seed-dano-2',
          name: 'Nestle Nido Full Cream Milk Powder Instant',
          unit: '1 KG',
          price: 270.00,
          originalPrice: 342.00,
          category: 'Dairy Products',
          description:
              'Et quidem faciunt, ut summum bonum sit extremum et rationibus conquisitis de voluptate. Sed ut summum bonum sit id,',
          illustration: MilkPowderPouchIllustration(size: 80),
        ),
      ];

  List<ProductModel> loadWishlist() {
    final rawJson = _storage.getWishlistJson();
    if (rawJson == null || rawJson.trim().isEmpty) {
      return defaultWishlistSeed;
    }
    try {
      final List decoded = jsonDecode(rawJson);
      final List<ProductModel> list = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final p = ProductModel.fromJson(item);
          // Restore illustrations for matching names
          Widget? ill;
          if (p.name.contains('Nido')) {
            ill = const MilkPowderCanIllustration(size: 80);
          } else if (p.name.contains('DANO') || p.name.contains('Dano')) {
            ill = const MilkPowderPouchIllustration(size: 80);
          }
          list.add(ProductModel(
            id: p.id,
            name: p.name,
            unit: p.unit,
            price: p.price,
            originalPrice: p.originalPrice,
            discountPercentage: p.discountPercentage,
            category: p.category,
            description: p.description,
            imageUrl: p.imageUrl,
            illustration: ill,
          ));
        }
      }
      return list.isNotEmpty ? list : defaultWishlistSeed;
    } catch (_) {
      return defaultWishlistSeed;
    }
  }

  Future<void> saveWishlist(List<ProductModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _storage.saveWishlistJson(encoded);
  }
}
