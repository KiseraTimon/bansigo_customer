// lib/features/wishlist/screens/sections/wishlist_item_card.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/product_image_widget.dart';
import '../../../../shared/widgets/select_cart_bottom_sheet.dart';
import '../../../home/models/product_model.dart';
import '../../../catalogue/screens/product_details_screen.dart';

class WishlistItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToCart;

  const WishlistItemCard({
    super.key,
    required this.product,
    this.onRemove,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image card container
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: ProductImageWidget(
                    product: product,
                    width: 82,
                    height: 82,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Product Details (Title, Compare at price, Deal price, stock)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      fontSize: 14.5,
                      color: AppColors.slateDark,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (product.originalPrice != null) ...[
                    Text(
                      product.formattedOriginalPrice!,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Text(
                        product.formattedPrice,
                        style: AppTextStyles.bodyBold.copyWith(
                          color: const Color(0xFFFF7A00),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!product.inStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Out of stock',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Actions (Add to Cart & Remove from Wishlist)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onRemove != null)
                  IconButton(
                    tooltip: 'Remove from wishlist',
                    onPressed: onRemove,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFEF4444),
                      size: 21,
                    ),
                  ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: product.inStock
                      ? (onAddToCart ??
                          () => SelectCartBottomSheet.show(
                                context: context,
                                product: product,
                              ))
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: product.inStock
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 14,
                          color: product.inStock ? Colors.white : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: product.inStock ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
