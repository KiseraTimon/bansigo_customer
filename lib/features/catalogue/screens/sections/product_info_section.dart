// lib/features/catalogue/screens/sections/product_info_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/models/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Title
          Text(
            product.name,
            style: AppTextStyles.h2.copyWith(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: AppColors.slateDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Weight & Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.unit.toUpperCase(),
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Text(
                product.formattedPrice,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Category Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.view_headline_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 12),
              Text(
                product.category,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF334155),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.notes_rounded,
                  size: 20,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (product.description != null && product.description!.trim().isNotEmpty)
                      ? product.description!
                      : 'Fresh ${product.category.toLowerCase()} stocked daily at Bansi Mega Supermarket, Migori.',
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF475569),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
