// lib/features/catalogue/screens/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/templates/screen_template.dart';
import '../../../shared/widgets/select_cart_bottom_sheet.dart';
import '../../home/models/product_model.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../services/catalogue_service.dart';
import '../../../core/network/api_client.dart';
import 'sections/product_gallery_section.dart';
import 'sections/product_info_section.dart';
import 'sections/related_products_section.dart';
import 'sections/add_to_bag_bar.dart';
import '../../reviews/widgets/product_reviews_section.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductModel _product;
  List<ProductModel> _relatedProducts = [];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _fetchDetailsAndRelated();
  }

  Future<void> _fetchDetailsAndRelated() async {
    final catService = CatalogueService(context.read<ApiClient>());
    final int? productId = int.tryParse(_product.id);
    if (productId != null) {
      final detail = await catService.getProductDetail(productId);
      if (detail != null && mounted) {
        setState(() => _product = detail);
      }
      final related = await catService.getRelatedProducts(productId);
      if (mounted) {
        setState(() {
          _relatedProducts = related;
        });
      }
    } else {
      final related = await catService.getRelatedProducts(1);
      if (mounted) {
        setState(() {
          _relatedProducts = related;
        });
      }
    }
  }

  void _onAddToBag() {
    SelectCartBottomSheet.show(context: context, product: _product);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, _) {
        final isWishlisted = wishlistProvider.isWishlisted(_product.id);

        return ScreenTemplate(
          header: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.slateDark),
                        splashRadius: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Product Details',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slateDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => wishlistProvider.toggle(_product),
                    icon: Icon(
                      isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isWishlisted ? const Color(0xFFEF4444) : AppColors.slateDark,
                    ),
                    splashRadius: 22,
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductGallerySection(product: _product),
                const SizedBox(height: 24),
                ProductInfoSection(product: _product),
                const SizedBox(height: 24),
                ProductReviewsSection(
                  productId: int.tryParse(_product.id),
                  productName: _product.name,
                ),
                const SizedBox(height: 28),
                RelatedProductsSection(items: _relatedProducts),
              ],
            ),
          ),
          bottomNavigationBar: AddToBagBar(onAddToBag: _onAddToBag),
        );
      },
    );
  }
}
