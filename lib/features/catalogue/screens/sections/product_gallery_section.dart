// lib/features/catalogue/screens/sections/product_gallery_section.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/product_category_placeholder.dart';
import '../../../home/models/product_model.dart';

class ProductGallerySection extends StatefulWidget {
  final ProductModel product;

  const ProductGallerySection({super.key, required this.product});

  @override
  State<ProductGallerySection> createState() => _ProductGallerySectionState();
}

class _ProductGallerySectionState extends State<ProductGallerySection> {
  int _selectedIndex = 0;

  List<Widget> _buildPreviews() {
    final List<Widget> list = [];

    if (widget.product.illustration != null) {
      list.add(widget.product.illustration!);
    } else if (widget.product.imageUrl != null && widget.product.imageUrl!.trim().isNotEmpty) {
      list.add(
        Image.network(
          widget.product.imageUrl!.trim(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => ProductCategoryPlaceholder(
            product: widget.product,
            size: 200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    // Category placeholder is always available as a companion or primary view
    list.add(
      ProductCategoryPlaceholder(
        product: widget.product,
        size: 200,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final previews = _buildPreviews();

    return Column(
      children: [
        // Main Product Image Card
        Container(
          width: double.infinity,
          height: 280,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: previews[_selectedIndex % previews.length],
          ),
        ),
        const SizedBox(height: 16),

        // Thumbnail selectors
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(previews.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 54,
                  height: 54,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: FittedBox(child: previews[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
