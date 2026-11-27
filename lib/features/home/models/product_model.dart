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
  final int ratingCount;
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
    this.rating = 0.0,
    this.ratingCount = 0,
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

    final rawCompare = json['compare_at_price'] ?? json['originalPrice'];
    final double? parsedOriginalPrice = rawCompare != null
        ? (rawCompare is num ? rawCompare.toDouble() : double.tryParse(rawCompare.toString()))
        : null;

    int? discount = json['discountPercentage'] is num
        ? (json['discountPercentage'] as num).toInt()
        : null;
    if (discount == null && parsedOriginalPrice != null && parsedOriginalPrice > parsedPrice) {
      discount = (((parsedOriginalPrice - parsedPrice) / parsedOriginalPrice) * 100).round();
    }

    final rawGallery = json['gallery_images'] ?? json['galleryImages'];
    final List<String> gallery = [];
    if (rawGallery is List) {
      for (final img in rawGallery) {
        if (img != null && img.toString().isNotEmpty) {
          gallery.add(img.toString());
        }
      }
    }

    final rawRating = json['rating'] ?? json['average_rating'];
    final double parsedRating = rawRating is num
        ? rawRating.toDouble()
        : (double.tryParse(rawRating?.toString() ?? '') ?? 0.0);

    final rawRatingCount = json['rating_count'] ?? json['ratingCount'];
    final int parsedRatingCount = rawRatingCount is num
        ? rawRatingCount.toInt()
        : (int.tryParse(rawRatingCount?.toString() ?? '') ?? 0);

    final rawCatId = json['category_id'] ?? json['categoryId'];
    final rawInStock = json['in_stock'] ?? json['inStock'];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      unit: json['pack_size_label']?.toString() ?? json['unit']?.toString() ?? '1 Item',
      price: parsedPrice,
      originalPrice: parsedOriginalPrice,
      discountPercentage: discount,
      rating: parsedRating,
      ratingCount: parsedRatingCount,
      category: json['category'] is Map
          ? (json['category']['name']?.toString() ?? 'Grocery')
          : (json['category']?.toString() ?? json['brand']?['name']?.toString() ?? 'Grocery'),
      categoryId: rawCatId is num ? rawCatId.toInt() : int.tryParse(rawCatId?.toString() ?? ''),
      description: json['description']?.toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'])?.toString(),
      galleryImages: gallery,
      inStock: rawInStock == null ? true : (rawInStock == true),
      icon: Icons.shopping_bag_outlined,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'pack_size_label': unit,
        'price': price,
        'compare_at_price': originalPrice,
        'originalPrice': originalPrice,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'rating_count': ratingCount,
        'category': category,
        'category_id': categoryId,
        'description': description,
        'image_url': imageUrl,
        'imageUrl': imageUrl,
        'gallery_images': galleryImages,
        'galleryImages': galleryImages,
        'in_stock': inStock,
        'inStock': inStock,
      };
}
