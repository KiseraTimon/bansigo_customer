// lib/shared/widgets/product_image_widget.dart

import 'package:flutter/material.dart';
import '../../features/home/models/product_model.dart';
import 'product_category_placeholder.dart';

class ProductImageWidget extends StatelessWidget {
  final ProductModel product;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImageWidget({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = (height != null && height!.isFinite && height! > 0)
        ? height!
        : ((width != null && width!.isFinite && width! > 0) ? width! : 72.0);

    if (product.illustration != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(child: product.illustration!),
      );
    }

    if (product.imageUrl != null && product.imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl!.trim(),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => ProductCategoryPlaceholder(
            product: product,
            size: effectiveSize,
            borderRadius: borderRadius,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return ProductCategoryPlaceholder(
              product: product,
              size: effectiveSize,
              borderRadius: borderRadius,
            );
          },
        ),
      );
    }

    return ProductCategoryPlaceholder(
      product: product,
      size: effectiveSize,
      borderRadius: borderRadius,
    );
  }
}
