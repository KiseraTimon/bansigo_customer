// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login/login_flow_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../models/category_model.dart';
import '../widgets/category_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/home_header.dart';
import '../widgets/location_selector.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<CategoryItem> _categories = const [
    CategoryItem(
      id: 'fruits_veg',
      title: 'Fruits & Vegetables',
      illustration: AvocadoIllustration(size: 78),
    ),
    CategoryItem(
      id: 'breakfast',
      title: 'Breakfast',
      illustration: BreakfastIllustration(size: 78),
    ),
    CategoryItem(
      id: 'beverages',
      title: 'Beverages',
      illustration: BeveragesIllustration(size: 78),
    ),
    CategoryItem(
      id: 'meat_fish',
      title: 'Meat & Fish',
      illustration: MeatFishIllustration(size: 78),
    ),
    CategoryItem(
      id: 'snacks',
      title: 'Snacks',
      illustration: SnacksIllustration(size: 78),
    ),
    CategoryItem(
      id: 'dairy',
      title: 'Dairy',
      illustration: DairyIllustration(size: 78),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTapped(CategoryItem category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected category: ${category.title}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMenuModal() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    final rootNavigator = Navigator.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    rootNavigator.push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          user != null && user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : 'B',
                          style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName
                                  : 'Guest Shopper',
                              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 16),
                            ),
                            Text(
                              user?.email ?? 'Sign in for AI recommendations',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: AppColors.slateDark),
                  title: const Text('My Profile'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    rootNavigator.push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppColors.slateDark),
                  title: const Text('Order History'),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined, color: AppColors.slateDark),
                  title: const Text('Help & Support'),
                  onTap: () => Navigator.pop(bottomSheetContext),
                ),
                const SizedBox(height: 12),
                if (auth.isAuthenticated)
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    onTap: () async {
                      Navigator.pop(bottomSheetContext);
                      await auth.logout();
                      rootNavigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
                        (route) => false,
                      );
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.login, color: AppColors.primary),
                    title: const Text('Sign In / Register', style: TextStyle(color: AppColors.primary)),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      rootNavigator.push(
                        MaterialPageRoute(builder: (_) => const LoginFlowScreen()),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNavChanged(int index) {
    if (index == 3) {
      _showMenuModal();
      return;
    }
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle warm peach glow at top-right background matching inspo
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFEDD5).withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: "BansiGo" + Notification Bell
                const HomeHeader(),

                // Location Selector: Lime Green Pin + Wasweta 1, Migori
                const LocationSelector(),

                const SizedBox(height: 4),

                // Search Bar: "Search Anything"
                SearchBarWidget(
                  controller: _searchController,
                  onChanged: (val) {
                    // Search hook
                  },
                ),

                const SizedBox(height: 8),

                // Category Grid (2 columns, 3 rows)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 8,
                      bottom: 20,
                    ),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.98,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final item = _categories[index];
                      return CategoryCard(
                        item: item,
                        onTap: () => _onCategoryTapped(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: _onNavChanged,
      ),
    );
  }
}
