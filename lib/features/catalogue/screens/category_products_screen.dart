// lib/features/catalogue/screens/category_products_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/select_cart_bottom_sheet.dart';
import '../../home/models/product_model.dart';
import '../../home/widgets/product_card.dart';
import '../models/category_model.dart';
import '../providers/catalogue_provider.dart';
import 'product_details_screen.dart';
import 'search_products_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _activeFilter = 'all'; // 'all', 'deals', 'under200', 'instock'

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<CatalogueProvider>(context, listen: false);
    final items = await provider.getProductsForCategory(widget.category.id);
    if (mounted) {
      setState(() {
        _products = items;
        _isLoading = false;
      });
    }
  }

  List<ProductModel> get _filteredProducts {
    switch (_activeFilter) {
      case 'deals':
        return _products.where((p) => (p.discountPercentage ?? 0) > 0).toList();
      case 'under200':
        return _products.where((p) => p.price <= 200).toList();
      case 'instock':
        return _products.where((p) => p.inStock).toList();
      case 'all':
      default:
        return _products;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final displayedProducts = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadCategoryProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. Department App Bar & Banner
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: cat.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: cat.color.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + Search + Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  cat.badgeText.isNotEmpty ? cat.badgeText : 'Supermarket Aisle',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SearchProductsScreen(initialCategoryId: cat.id),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Department Title & Icon
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cat.description ?? 'Freshly stocked inventory from Bansi Mega Supermarket',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Promotional Deal Highlight Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: cat.color.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cat.bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.percent_rounded, color: cat.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aisle Special Promo',
                                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13, color: cat.color),
                              ),
                              Text(
                                'Up to 20% off select ${cat.name} items this week • 15 min delivery',
                                style: AppTextStyles.caption.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Filter Chips (All, Best Deals, Under KES 200, In Stock)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPill(
                        label: 'All Items (${_products.length})',
                        isActive: _activeFilter == 'all',
                        onTap: () => setState(() => _activeFilter = 'all'),
                      ),
                      _buildPill(
                        label: '🔥 Best Deals',
                        isActive: _activeFilter == 'deals',
                        onTap: () => setState(() => _activeFilter = 'deals'),
                      ),
                      _buildPill(
                        label: 'Under KES 200',
                        isActive: _activeFilter == 'under200',
                        onTap: () => setState(() => _activeFilter = 'under200'),
                      ),
                      _buildPill(
                        label: 'In Stock Only',
                        isActive: _activeFilter == 'instock',
                        onTap: () => setState(() => _activeFilter = 'instock'),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Products Grid
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (displayedProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No items currently in this filter',
                          style: AppTextStyles.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try clearing filter pills above to view all items',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = displayedProducts[index];
                        return ProductCard(
                          product: product,
                          onAddToCart: () {
                            SelectCartBottomSheet.show(context: context, product: product);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                      childCount: displayedProducts.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 72),
              ),
            ],
          ),
        ),
      ),
      const FloatingCartBar(bottomOffset: 16),
    ],
  ),
);
  }

  Widget _buildPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.slateDark,
            ),
          ),
        ),
      ),
    );
  }
}
