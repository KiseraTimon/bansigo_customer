// lib/features/home/widgets/spotlight_section.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';
import '../models/product_model.dart';

class SpotlightSection extends StatelessWidget {
  final ProductModel? product;
  final bool hasCountdown;
  final String? countdownText;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const SpotlightSection({
    super.key,
    this.product,
    this.hasCountdown = false,
    this.countdownText,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = product?.name ?? 'Pure Kenyan Highland Wild Honey';
    final unit = product?.unit ?? '500g Glass Jar';
    final price = product?.price ?? 450.0;
    final originalPrice = product?.originalPrice ?? (product == null ? 600.0 : null);
    final discount = product?.discountPercentage ?? 25;
    final imageUrl = product?.imageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with Flame icon
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFEA580C),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                'Spotlight Deal',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
              const Spacer(),
              // Countdown timer pill (only rendered if explicitly configured)
              if (hasCountdown && countdownText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        countdownText!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Spotlight Card
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFFBEB),
                    Color(0xFFFEF3C7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Product Artwork or Network image
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    height: 96,
                                    width: 96,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const HoneyPotIllustration(size: 96),
                                  ),
                                )
                              : const HoneyPotIllustration(size: 96),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Discount Tag
                            if (discount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SAVE $discount% TODAY',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9.5,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 6),

                            // Product Title
                            Text(
                              title,
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF78350F),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            // Unit & rating
                            Row(
                              children: [
                                Text(
                                  '$unit • ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: const Color(0xFF92400E),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 15,
                                  color: Color(0xFFD97706),
                                ),
                                Text(
                                  ' 4.9',
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'KSh ${price.toStringAsFixed(0)}',
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                                if (originalPrice != null && originalPrice > price) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'KSh ${originalPrice.toStringAsFixed(0)}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Express delivery notice + Add to basket CTA button
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '15 min delivery',
                            style: AppTextStyles.caption.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: const Text(
                          'Add to Basket',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
