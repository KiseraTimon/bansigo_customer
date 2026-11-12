// lib/features/home/widgets/explore_tab_view.dart

import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../catalogue/models/category_model.dart';
import '../../catalogue/providers/catalogue_provider.dart';
import '../../catalogue/screens/category_products_screen.dart';
import '../../catalogue/screens/search_products_screen.dart';

class ExploreTabView extends StatefulWidget {
  final VoidCallback onBackToHome;

  const ExploreTabView({
    super.key,
    required this.onBackToHome,
  });

  @override
  State<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  final PageController _bannerController = PageController();
  int _activePromoIndex = 0;
  Timer? _promoTimer;

  final List<_PromoBannerData> _promoBanners = const [
    _PromoBannerData(
      tag: 'PHARMACY SPECIAL',
      title: 'Health & Wellness Days',
      subtitle: 'Up to 20% OFF Daily Vitamins & Pain Care',
      gradient: [Color(0xFF065F46), Color(0xFF059669)],
      icon: Icons.local_pharmacy_rounded,
      targetSlug: 'pharmacy-healthcare',
    ),
    _PromoBannerData(
      tag: 'OVEN FRESH',
      title: 'Artisan Bakery Morning',
      subtitle: 'Buy 2 Get 1 Free on Fresh Croissants & Buns',
      gradient: [Color(0xFFB45309), Color(0xFFD97706)],
      icon: Icons.bakery_dining_rounded,
      targetSlug: 'bakery-pastries',
    ),
    _PromoBannerData(
      tag: 'DELI HOUR',
      title: 'Sizzling Deli Deals',
      subtitle: 'Hot Rotisserie Chicken & Farmer\'s Sausages',
      gradient: [Color(0xFFC2410C), Color(0xFFEA580C)],
      icon: Icons.restaurant_rounded,
      targetSlug: 'meat-poultry-fresh-produce',
    ),
    _PromoBannerData(
      tag: 'MEGA SAVER',
      title: 'Electronics & Home Appliances',
      subtitle: 'Instant 15-20 min Delivery on Ramtons & Sayona',
      gradient: [Color(0xFF1E40AF), Color(0xFF2563EB)],
      icon: Icons.devices_other_rounded,
      targetSlug: 'electronics-appliances',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_bannerController.hasClients) {
          final nextPage = (_activePromoIndex + 1) % _promoBanners.length;
          _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _openCategoryBySlug(BuildContext context, String slug) {
    final provider = Provider.of<CatalogueProvider>(context, listen: false);
    final cat = CategoryModel.findMatchingCategory(provider.categories, slug);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(category: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = Provider.of<CatalogueProvider>(context);
    final allCats = catalogue.categories;

    // Filter major priority departments
    final majorDepartments = allCats.where((c) => c.isMajorDepartment).toList();
    final otherDepartments = allCats.where((c) => !c.isMajorDepartment).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
          // 1. Header with back and title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: widget.onBackToHome,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.slateDark,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Store Aisles',
                              style: AppTextStyles.h1.copyWith(fontSize: 20),
                            ),
                            Text(
                              'Bansi Mega Supermarket • 15 Departments',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Search bar trigger (navigates to full SearchProductsScreen)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchProductsScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.primaryDark, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search pharmacy, bakery, drinks, gadgets...',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: const Text(
                              'Filter',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slateDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Running Deals & Promotional Banners
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEA580C), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Running Store Deals & Promos',
                            style: AppTextStyles.h2.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                      Text(
                        '${_activePromoIndex + 1}/${_promoBanners.length}',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 130,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (idx) => setState(() => _activePromoIndex = idx),
                    itemCount: _promoBanners.length,
                    itemBuilder: (context, index) {
                      final banner = _promoBanners[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: () => _openCategoryBySlug(context, banner.targetSlug),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: banner.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: banner.gradient.first.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          banner.tag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        banner.subtitle,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 11.5,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(banner.icon, color: Colors.white, size: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Section Title: Major Priority Store Departments
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Major Store Departments',
                    style: AppTextStyles.h2.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // 4. Priority Department Showcase (Depth Cards in 2-column grid)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dept = majorDepartments[index];
                  return _buildMajorDepartmentCard(context, dept);
                },
                childCount: majorDepartments.length,
              ),
            ),
          ),

          // 5. Section Title: Other Aisles & Essentials
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.category_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'All Supermarket Aisles',
                    style: AppTextStyles.h2.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // 6. Other Departments List / Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dept = otherDepartments[index];
                  return _buildStandardAisleCard(context, dept);
                },
                childCount: otherDepartments.length,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMajorDepartmentCard(BuildContext context, CategoryModel dept) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: dept),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: dept.color.withValues(alpha: 0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: dept.color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dept.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: dept.color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(dept.icon, color: Colors.white, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: dept.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dept.badgeText,
                    style: TextStyle(
                      color: dept.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: AppTextStyles.bodySemiBold.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slateDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${dept.itemCount}+ items in store',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardAisleCard(BuildContext context, CategoryModel dept) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: dept),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dept.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(dept.icon, color: dept.color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dept.name,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${dept.itemCount}+ items',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerData {
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;
  final String targetSlug;

  const _PromoBannerData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    required this.targetSlug,
  });
}
