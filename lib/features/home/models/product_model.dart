// lib/features/home/models/product_model.dart

import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final double rating;
  final String category;
  final int? categoryId;
  final String? description;
  final String? imageUrl;
  final List<String> galleryImages;
  final bool inStock;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Widget? illustration;

  const ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.rating = 4.8,
    required this.category,
    this.categoryId,
    this.description,
    this.imageUrl,
    this.galleryImages = const [],
    this.inStock = true,
    this.icon = Icons.shopping_basket_rounded,
    this.iconColor = const Color(0xFF16A34A),
    this.iconBgColor = const Color(0xFFDCFCE7),
    this.illustration,
  });

  String get formattedPrice => 'KES ${price.toStringAsFixed(2)}';
  String? get formattedOriginalPrice =>
      originalPrice != null ? 'KES ${originalPrice!.toStringAsFixed(2)}' : null;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

    final rawCompare = json['compare_at_price'];
    final double? parsedOriginalPrice = rawCompare != null
        ? (rawCompare is num ? rawCompare.toDouble() : double.tryParse(rawCompare.toString()))
        : null;

    int? discount;
    if (parsedOriginalPrice != null && parsedOriginalPrice > parsedPrice) {
      discount = (((parsedOriginalPrice - parsedPrice) / parsedOriginalPrice) * 100).round();
    }

    final List<String> gallery = [];
    if (json['gallery_images'] is List) {
      for (final img in json['gallery_images']) {
        if (img != null) gallery.add(img.toString());
      }
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      unit: json['pack_size_label']?.toString() ?? json['unit']?.toString() ?? '1 Item',
      price: parsedPrice,
      originalPrice: parsedOriginalPrice,
      discountPercentage: discount,
      rating: 4.8,
      category: json['category'] is Map
          ? (json['category']['name']?.toString() ?? 'Grocery')
          : (json['category']?.toString() ?? json['brand']?['name']?.toString() ?? 'Grocery'),
      categoryId: json['category_id'] is num
          ? (json['category_id'] as num).toInt()
          : int.tryParse(json['category_id']?.toString() ?? ''),
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(),
      galleryImages: gallery,
      inStock: json['in_stock'] == null ? true : (json['in_stock'] == true),
      icon: Icons.shopping_bag_outlined,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'price': price,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'category': category,
        'description': description,
        'imageUrl': imageUrl,
        'galleryImages': galleryImages,
        'inStock': inStock,
      };
}
