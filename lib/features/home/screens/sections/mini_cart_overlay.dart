// lib/features/home/screens/sections/mini_cart_overlay.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MiniCartOverlay extends StatelessWidget {
  final int itemCount;
  final double totalAmount;
  final VoidCallback onTap;

  const MiniCartOverlay({
    super.key,
    required this.itemCount,
    required this.totalAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 0) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: 12,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.slateDark,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'KSh ${totalAmount.toStringAsFixed(0)}',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'View Basket',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
