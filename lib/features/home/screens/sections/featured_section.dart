// lib/features/home/screens/sections/featured_section.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';

class FeaturedSection extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onAddToCart;
  final Function(ProductModel)? onProductTap;
  final VoidCallback? onSeeAllTap;

  const FeaturedSection({
    super.key,
    required this.products,
    required this.onAddToCart,
    this.onProductTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Featured & Best Sellers',
          subtitle: 'Shopper favorites and weekly high-demand staples',
          actionText: 'See All',
          onActionTap: onSeeAllTap,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 232,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: () => onAddToCart(product),
                onTap: () => onProductTap?.call(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
