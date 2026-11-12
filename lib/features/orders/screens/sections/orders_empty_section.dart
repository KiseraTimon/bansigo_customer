// lib/features/orders/screens/sections/orders_empty_section.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/illustrations/vector_illustrations.dart';
import '../../models/order_model.dart';

class OrdersEmptySection extends StatelessWidget {
  final OrderTabType activeTab;
  final VoidCallback onOrderHere;

  const OrdersEmptySection({
    super.key,
    required this.activeTab,
    required this.onOrderHere,
  });

  @override
  Widget build(BuildContext context) {
    final isOngoing = activeTab == OrderTabType.ongoing;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Courier packing boxes illustration
            const OrderPackingIllustration(size: 240),
            const SizedBox(height: 28),

            // Exact text from attached mockup
            if (isOngoing)
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'There are no ongoing order right\nnow. You can order from ',
                    ),
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onOrderHere,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
            else
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'No past order receipts found.\nStart your fresh basket ',
                    ),
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = onOrderHere,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
