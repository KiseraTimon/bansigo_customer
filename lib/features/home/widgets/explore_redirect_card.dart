// lib/features/home/widgets/explore_redirect_card.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ExploreRedirectCard extends StatelessWidget {
  final VoidCallback onExploreTap;

  const ExploreRedirectCard({
    super.key,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          children: [
            // Compass / Shopping bag icon in green circle
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.explore_rounded,
                color: AppColors.primaryDark,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // Headline
            Text(
              'Looking for something else?',
              style: AppTextStyles.h2.copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColors.slateDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Body
            Text(
              'Explore 5,000+ items across all departments including pharmacy, electronics, fresh produce, and home goods.',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Redirection Button to Explore Page
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onExploreTap,
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text(
                  'Explore Full Catalog',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
