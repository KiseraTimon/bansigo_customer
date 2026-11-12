// lib/features/home/screens/home.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/templates/screen_template.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/select_cart_bottom_sheet.dart';
import '../../address/providers/address_provider.dart';
import '../../address/screens/address_screen.dart';
import '../../catalogue/models/category_model.dart';
import '../../catalogue/providers/catalogue_provider.dart';
import '../../catalogue/services/catalogue_service.dart';
import '../../catalogue/screens/category_products_screen.dart';
import '../../catalogue/screens/product_details_screen.dart';
import '../../catalogue/screens/search_products_screen.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/more_options_screen.dart';
import '../models/product_model.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/explore_tab_view.dart';
import '../widgets/orders_tab_view.dart';
import '../widgets/product_card.dart';

import 'sections/advert_slider_section.dart';
import 'sections/explore_redirect_section.dart';
import 'sections/featured_section.dart';
import 'sections/fresh_grocery_section.dart';
import 'sections/grocery_grid_section.dart';
import 'sections/header_section.dart';
import 'sections/household_section.dart';
import 'sections/recommendations_section.dart';
import 'sections/shop_aisles_section.dart';
import 'sections/snacks_section.dart';
import 'sections/spotlight_section.dart';
import 'sections/trust_banner_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(ProductModel product) {
    SelectCartBottomSheet.show(context: context, product: product);
  }

  void _navigateToCategory(BuildContext context, String slugOrName) {
    final provider = Provider.of<CatalogueProvider>(context, listen: false);
    final cat = CategoryModel.findMatchingCategory(provider.categories, slugOrName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(category: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tab 1: Explore / Departments
    if (_currentNavIndex == 1) {
      return ScreenTemplate(
        isScrollable: false,
        body: ExploreTabView(
          onBackToHome: () {
            setState(() {
              _currentNavIndex = 0;
            });
          },
        ),
        floatingOverlay: const FloatingCartBar(bottomOffset: 12),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentNavIndex,
          onIndexChanged: (idx) => setState(() => _currentNavIndex = idx),
        ),
      );
    }

    // Tab 2: Orders
    if (_currentNavIndex == 2) {
      return ScreenTemplate(
        isScrollable: false,
        body: OrdersTabView(
          onStartShopping: () {
            setState(() {
              _currentNavIndex = 0;
            });
          },
        ),
        floatingOverlay: const FloatingCartBar(bottomOffset: 12),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentNavIndex,
          onIndexChanged: (idx) => setState(() => _currentNavIndex = idx),
        ),
      );
    }

    // Tab 3: More Options (Full Page as requested in Requirement 7)
    if (_currentNavIndex == 3) {
      return Scaffold(
        body: const MoreOptionsScreen(),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentNavIndex,
          onIndexChanged: (idx) => setState(() => _currentNavIndex = idx),
        ),
      );
    }

    // Address state from AddressProvider
    final addressProvider = Provider.of<AddressProvider?>(context);
    final addressText = addressProvider?.currentDisplayLocation ?? 'Select delivery location';
    final distanceNote = addressProvider?.deliveryDistanceNote ??
        '15–20 mins delivery • 2.4 km from Migori Supermarket';
    final isFarApart = addressProvider?.isFarApart ?? false;

    // Catalogue and Notification Providers
    final catalogue = Provider.of<CatalogueProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final freshProducts = catalogue.freshGroceryProducts.isNotEmpty
        ? catalogue.freshGroceryProducts
        : CatalogueService.defaultFallbackProducts.take(6).toList();
    final householdProducts = catalogue.householdProducts.isNotEmpty
        ? catalogue.householdProducts
        : CatalogueService.defaultFallbackProducts.skip(2).take(6).toList();
    final snacksProducts = catalogue.snacksProducts.isNotEmpty
        ? catalogue.snacksProducts
        : CatalogueService.defaultFallbackProducts.skip(4).take(6).toList();
    final featuredProducts = catalogue.featuredProducts.isNotEmpty
        ? catalogue.featuredProducts
        : CatalogueService.defaultFallbackProducts;

    final isCategoryFiltered = _selectedCategory != 'all';

    return ScreenTemplate(
      onRefresh: () async {
        await catalogue.refreshCatalog();
      },
      sections: [
        // 1. Header (Title, Notification, Location with distance note, Search, Category Slider)
        HeaderSection(
          searchController: _searchController,
          selectedCategory: _selectedCategory,
          location: addressText,
          supermarketDistanceNote: distanceNote,
          isFarApart: isFarApart,
          hasUnreadNotifications: notificationProvider.unreadCount > 0,
          onNotificationTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          onSearchTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchProductsScreen()),
            );
          },
          onLocationTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            );
          },
          onCategorySelected: (catId) {
            setState(() {
              _selectedCategory = catId;
            });
            catalogue.selectCategory(catId);
          },
        ),
        const SizedBox(height: 14),

        // If category is filtered, show direct category products feed on Homepage!
        if (isCategoryFiltered) ...[
          _buildCategoryFilterFeed(context, catalogue),
        ] else ...[
          // Default Home Layout (All Aisles)
          // 2. Multi-page transitioning advert banner
          AdvertSliderSection(
            onSlideTap: (slideIndex) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchProductsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),

          // 3. Grocery Grid Section (6 departments)
          GrocerySection(
            onItemTap: (item) => _navigateToCategory(context, item.title),
          ),
          const SizedBox(height: 20),

          // 4. Trust & Delivery Guarantee Banner
          const TrustBannerSection(),
          const SizedBox(height: 24),

          // 5. Fresh Grocery Carousel
          FreshGrocerySection(
            products: freshProducts,
            onAddToCart: (p) => _addToCart(p),
            onProductTap: (p) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
              );
            },
            onSeeAllTap: () => _navigateToCategory(context, 'produce'),
          ),
          const SizedBox(height: 24),

          // 6. Spotlight Deal of the Day (Real Product from Backend)
          Builder(
            builder: (context) {
              final spotlight = catalogue.spotlightProduct;

              return HomeSpotlightSection(
                product: spotlight,
                hasCountdown: false, // Timer hidden unless configured in backend
                onAddToCart: () => _addToCart(spotlight),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: spotlight),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // 7. Household Essentials Carousel
          HouseholdSection(
            products: householdProducts,
            onAddToCart: (p) => _addToCart(p),
            onProductTap: (p) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
              );
            },
            onSeeAllTap: () => _navigateToCategory(context, 'household'),
          ),
          const SizedBox(height: 24),

          // 8. Snacks & Munchies Carousel
          SnacksSection(
            products: snacksProducts,
            onAddToCart: (p) => _addToCart(p),
            onProductTap: (p) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
              );
            },
            onSeeAllTap: () => _navigateToCategory(context, 'snacks'),
          ),
          const SizedBox(height: 24),

          // 9. AI Recommendations Carousel (Apriori / FP-Growth)
          const RecommendationsSection(),
          const SizedBox(height: 24),

          // 10. Featured Items Carousel
          FeaturedSection(
            products: featuredProducts,
            onAddToCart: (p) => _addToCart(p),
            onProductTap: (p) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
              );
            },
            onSeeAllTap: () => _navigateToCategory(context, 'bakery'),
          ),
          const SizedBox(height: 24),

          // 10. Shop by Store & Aisles Section
          HomeShopAislesSection(
            onAisleTap: (aisle) => _navigateToCategory(context, aisle.title),
          ),
          const SizedBox(height: 28),

          // 11. Explore Catalog Redirection Card (End of Page)
          ExploreRedirectSection(
            onExploreTap: () {
              setState(() {
                _currentNavIndex = 1;
              });
            },
          ),
          const SizedBox(height: 36),
        ],
      ],
      floatingOverlay: const FloatingCartBar(
        bottomOffset: 12,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (idx) => setState(() => _currentNavIndex = idx),
      ),
    );
  }

  Widget _buildCategoryFilterFeed(BuildContext context, CatalogueProvider catalogue) {
    final items = catalogue.categoryProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (catalogue.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text('No items currently in this aisle', style: AppTextStyles.h2.copyWith(fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = items[index];
                return ProductCard(
                  product: product,
                  onAddToCart: () => _addToCart(product),
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
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
