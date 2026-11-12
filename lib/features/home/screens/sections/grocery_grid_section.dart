// lib/features/home/screens/sections/grocery_grid_section.dart

import 'package:flutter/material.dart';
import '../../widgets/grocery_grid_section.dart';

class GrocerySection extends StatelessWidget {
  final ValueChanged<GroceryItemData>? onItemTap;

  const GrocerySection({
    super.key,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GroceryGridSection(
      onItemTap: onItemTap,
    );
  }
}
