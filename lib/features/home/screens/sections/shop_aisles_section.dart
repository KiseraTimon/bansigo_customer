// lib/features/home/screens/sections/shop_aisles_section.dart

import 'package:flutter/material.dart';
import '../../widgets/shop_aisles_section.dart';

class HomeShopAislesSection extends StatelessWidget {
  final ValueChanged<AisleData>? onAisleTap;

  const HomeShopAislesSection({
    super.key,
    this.onAisleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShopAislesSection(
      onAisleTap: onAisleTap,
    );
  }
}
