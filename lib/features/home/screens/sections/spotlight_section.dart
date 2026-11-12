// lib/features/home/screens/sections/spotlight_section.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/spotlight_section.dart';

class HomeSpotlightSection extends StatelessWidget {
  final ProductModel? product;
  final bool hasCountdown;
  final String? countdownText;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const HomeSpotlightSection({
    super.key,
    this.product,
    this.hasCountdown = false,
    this.countdownText,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpotlightSection(
      product: product,
      hasCountdown: hasCountdown,
      countdownText: countdownText,
      onAddToCart: onAddToCart,
      onTap: onTap,
    );
  }
}
