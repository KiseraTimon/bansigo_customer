// lib/shared/widgets/product_category_placeholder.dart

import 'package:flutter/material.dart';
import '../../features/catalogue/models/category_model.dart';
import '../../features/home/models/product_model.dart';
import '../illustrations/vector_illustrations.dart';

class ProductCategoryPlaceholder extends StatelessWidget {
  final ProductModel? product;
  final int? categoryId;
  final String? categoryName;
  final String? productName;
  final double size;
  final BorderRadius? borderRadius;

  const ProductCategoryPlaceholder({
    super.key,
    this.product,
    this.categoryId,
    this.categoryName,
    this.productName,
    this.size = 72,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final safeSize = (size.isFinite && size > 0) ? size : 72.0;
    final catId = categoryId ??
        product?.categoryId ??
        CategoryModel.resolveCanonicalCategoryId(
          '${categoryName ?? product?.category ?? ''} ${productName ?? product?.name ?? ''}',
        ) ??
        0;

    final nameLower = (productName ?? product?.name ?? '').toLowerCase();

    // Check specific milk powders first
    if (nameLower.contains('dano') || nameLower.contains('milk powder') || nameLower.contains('nido')) {
      return _buildContainer(
        bgColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFEF3C7),
        child: nameLower.contains('nido')
            ? MilkPowderCanIllustration(size: safeSize * 0.72)
            : MilkPowderPouchIllustration(size: safeSize * 0.72),
      );
    }

    switch (catId) {
      case 1: // Snacks & Confectionery
        return _buildContainer(
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFEE2E2),
          child: SnacksIllustration(size: safeSize * 0.70),
        );
      case 2: // Bakery & Pastries
        return _buildContainer(
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          child: BreakfastIllustration(size: safeSize * 0.70),
        );
      case 3: // Beverages & Soft Drinks
        return _buildContainer(
          bgColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFDBEAFE),
          child: BeveragesIllustration(size: safeSize * 0.70),
        );
      case 4: // Wines, Beers & Spirits
        return _buildContainer(
          bgColor: const Color(0xFFFAF5FF),
          borderColor: const Color(0xFFF3E8FF),
          child: _VectorIconPlaceholder(
            icon: Icons.wine_bar_rounded,
            color: const Color(0xFF9333EA),
            size: safeSize * 0.44,
          ),
        );
      case 5: // Dairy & Eggs
        return _buildContainer(
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          child: DairyIllustration(size: safeSize * 0.70),
        );
      case 6: // Ice Cream & Frozen Desserts
        return _buildContainer(
          bgColor: const Color(0xFFFDF2F8),
          borderColor: const Color(0xFFFCE7F3),
          child: IceCreamIllustration(size: safeSize * 0.70),
        );
      case 7: // Grains, Flours & Staple Foods
        return _buildContainer(
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          child: HoneyPotIllustration(size: safeSize * 0.70),
        );
      case 8: // Oils, Spices & Condiments
        return _buildContainer(
          bgColor: const Color(0xFFFFF7ED),
          borderColor: const Color(0xFFFFEDD5),
          child: SpicesIllustration(size: safeSize * 0.70),
        );
      case 9: // Meat, Poultry & Fresh Produce
        return _buildContainer(
          bgColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFDCFCE7),
          child: FreshProduceIllustration(size: safeSize * 0.72),
        );
      case 10: // Personal Care & Grooming
        return _buildContainer(
          bgColor: const Color(0xFFF0FDFA),
          borderColor: const Color(0xFFCCFBF1),
          child: _VectorIconPlaceholder(
            icon: Icons.spa_rounded,
            color: const Color(0xFF0D9488),
            size: safeSize * 0.44,
          ),
        );
      case 11: // Household & Cleaning
        return _buildContainer(
          bgColor: const Color(0xFFF5F3FF),
          borderColor: const Color(0xFFEDE9FE),
          child: _VectorIconPlaceholder(
            icon: Icons.cleaning_services_rounded,
            color: const Color(0xFF7C3AED),
            size: safeSize * 0.44,
          ),
        );
      case 12: // Baby Care & Toys
        return _buildContainer(
          bgColor: const Color(0xFFFFF1F2),
          borderColor: const Color(0xFFFFE4E6),
          child: _VectorIconPlaceholder(
            icon: Icons.child_friendly_rounded,
            color: const Color(0xFFE11D48),
            size: safeSize * 0.44,
          ),
        );
      case 13: // Electronics & Appliances
        return _buildContainer(
          bgColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
          child: _VectorIconPlaceholder(
            icon: Icons.devices_rounded,
            color: const Color(0xFF2563EB),
            size: safeSize * 0.44,
          ),
        );
      case 14: // Furniture & Home Living
        return _buildContainer(
          bgColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFEF3C7),
          child: _VectorIconPlaceholder(
            icon: Icons.chair_rounded,
            color: const Color(0xFFD97706),
            size: safeSize * 0.44,
          ),
        );
      case 15: // Pharmacy & Healthcare
        return _buildContainer(
          bgColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFDCFCE7),
          child: _VectorIconPlaceholder(
            icon: Icons.local_pharmacy_rounded,
            color: const Color(0xFF16A34A),
            size: safeSize * 0.44,
          ),
        );
      default:
        return _buildContainer(
          bgColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
          child: GroceryBasketIllustration(size: safeSize * 0.70),
        );
    }
  }

  Widget _buildContainer({
    required Color bgColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: size.isFinite ? size : null,
      height: size.isFinite ? size : null,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Center(child: child),
    );
  }
}

class _VectorIconPlaceholder extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _VectorIconPlaceholder({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (size.isFinite && size > 0) ? size : 28.0;
    return Container(
      width: iconSize * 1.6,
      height: iconSize * 1.6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: color,
        ),
      ),
    );
  }
}
