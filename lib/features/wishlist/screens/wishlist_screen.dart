// lib/features/wishlist/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/templates/screen_template.dart';
import '../providers/wishlist_provider.dart';
import 'sections/wishlist_item_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      isScrollable: false,
      header: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.slateDark),
                splashRadius: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Wishlist',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slateDark,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, _) {
          final items = provider.items;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: AppTextStyles.bodySemiBold.copyWith(
                      fontSize: 16,
                      color: AppColors.slateDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore items and tap the heart icon to save them here.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFFF1F5F9),
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final product = items[index];
              return WishlistItemCard(
                product: product,
                onRemove: () => provider.remove(product.id),
              );
            },
          );
        },
      ),
    );
  }
}
