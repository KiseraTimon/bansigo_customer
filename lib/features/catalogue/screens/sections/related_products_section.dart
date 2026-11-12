// lib/features/catalogue/screens/sections/related_products_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/models/product_model.dart';
import '../product_details_screen.dart';

class RelatedProductsSection extends StatelessWidget {
  final List<ProductModel> items;

  const RelatedProductsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You can also check this items',
            style: AppTextStyles.bodyBold.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.slateDark,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // Thumbnail Card
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: item.illustration ??
                              (item.imageUrl != null && item.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(
                                        item.icon,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                    )
                                  : Icon(item.icon, color: AppColors.primary, size: 32)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Item Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySemiBold.copyWith(
                                fontSize: 13.5,
                                color: AppColors.slateDark,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (item.originalPrice != null)
                              Text(
                                item.formattedOriginalPrice!,
                                style: AppTextStyles.caption.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              item.formattedPrice,
                              style: AppTextStyles.bodyBold.copyWith(
                                color: const Color(0xFFFF7A00),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
