// lib/features/home/screens/sections/header_section.dart

import 'package:flutter/material.dart';
import '../../../../shared/widgets/email_verification_banner.dart';
import '../../widgets/category_slider.dart';
import '../../widgets/home_header.dart';
import '../../widgets/location_selector.dart';
import '../../widgets/search_bar_widget.dart';

class HeaderSection extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onSearchTap;
  final bool hasUnreadNotifications;
  final String location;
  final String supermarketDistanceNote;
  final bool isFarApart;

  const HeaderSection({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.onNotificationTap,
    this.onLocationTap,
    this.onSearchTap,
    this.hasUnreadNotifications = true,
    this.location = 'Upper Hill, Nairobi',
    this.supermarketDistanceNote = '15–20 mins delivery • 1.2 km from Bansi Mega Supermarket',
    this.isFarApart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Title & Notification Bell
        HomeHeader(
          onNotificationTap: onNotificationTap,
          hasUnreadNotifications: hasUnreadNotifications,
        ),

        // 2. Location Selector with supermarket distance note
        LocationSelector(
          location: location,
          supermarketDistanceNote: supermarketDistanceNote,
          isFarApart: isFarApart,
          onTap: onLocationTap,
        ),

        // Email Verification Warning Banner if customer email is unverified
        const EmailVerificationBanner(),

        const SizedBox(height: 4),

        // 3. Search Bar (tap expands into full search screen)
        GestureDetector(
          onTap: onSearchTap,
          child: AbsorbPointer(
            absorbing: onSearchTap != null,
            child: SearchBarWidget(
              controller: searchController,
              onTap: onSearchTap,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 4. Horizontally sliding category filter with transparent background
        CategorySlider(
          selectedCategory: selectedCategory,
          onCategorySelected: onCategorySelected,
        ),
      ],
    );
  }
}
