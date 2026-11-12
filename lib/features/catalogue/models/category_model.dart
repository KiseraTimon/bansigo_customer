// lib/features/catalogue/models/category_model.dart

import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int itemCount;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<Color> gradient;
  final bool isMajorDepartment;
  final String badgeText;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.itemCount = 20,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.gradient,
    this.isMajorDepartment = false,
    this.badgeText = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Category';
    final id = json['id'] is num ? (json['id'] as num).toInt() : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    final styling = _resolveCategoryVisuals(slug, name);

    return CategoryModel(
      id: id,
      name: name,
      slug: slug,
      description: json['description']?.toString(),
      itemCount: json['product_count'] is num ? (json['product_count'] as num).toInt() : 25,
      icon: styling.icon,
      color: styling.color,
      bgColor: styling.bgColor,
      gradient: styling.gradient,
      isMajorDepartment: styling.isMajor,
      badgeText: styling.badgeText,
    );
  }

  static _VisualProps _resolveCategoryVisuals(String slug, String name) {
    final lower = (slug + name).toLowerCase();

    if (lower.contains('pharmacy') || lower.contains('health')) {
      return const _VisualProps(
        icon: Icons.local_pharmacy_rounded,
        color: Color(0xFF059669),
        bgColor: Color(0xFFD1FAE5),
        gradient: [Color(0xFF059669), Color(0xFF10B981)],
        isMajor: true,
        badgeText: 'Healthcare',
      );
    } else if (lower.contains('bakery') || lower.contains('pastr')) {
      return const _VisualProps(
        icon: Icons.bakery_dining_rounded,
        color: Color(0xFFD97706),
        bgColor: Color(0xFFFEF3C7),
        gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
        isMajor: true,
        badgeText: 'Fresh Daily',
      );
    } else if (lower.contains('deli') || lower.contains('meat') || lower.contains('poultry')) {
      return const _VisualProps(
        icon: Icons.restaurant_rounded,
        color: Color(0xFFEA580C),
        bgColor: Color(0xFFFFEDD5),
        gradient: [Color(0xFFEA580C), Color(0xFFF97316)],
        isMajor: true,
        badgeText: 'Hot & Fresh',
      );
    } else if (lower.contains('drink') || lower.contains('beverag') || lower.contains('spirit')) {
      return const _VisualProps(
        icon: Icons.local_bar_rounded,
        color: Color(0xFF0891B2),
        bgColor: Color(0xFFCFFAFE),
        gradient: [Color(0xFF0891B2), Color(0xFF06B6D4)],
        isMajor: true,
        badgeText: 'Chilled',
      );
    } else if (lower.contains('electronic') || lower.contains('appliance')) {
      return const _VisualProps(
        icon: Icons.devices_other_rounded,
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFDBEAFE),
        gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        isMajor: true,
        badgeText: 'Appliances',
      );
    } else if (lower.contains('furniture') || lower.contains('living')) {
      return const _VisualProps(
        icon: Icons.chair_rounded,
        color: Color(0xFF9333EA),
        bgColor: Color(0xFFF3E8FF),
        gradient: [Color(0xFF7E22CE), Color(0xFFA855F7)],
        isMajor: true,
        badgeText: 'Home Living',
      );
    } else if (lower.contains('ice') || lower.contains('frozen')) {
      return const _VisualProps(
        icon: Icons.icecream_rounded,
        color: Color(0xFFEC4899),
        bgColor: Color(0xFFFCE7F3),
        gradient: [Color(0xFFDB2777), Color(0xFFF472B6)],
        isMajor: false,
        badgeText: 'Frozen',
      );
    } else if (lower.contains('snack') || lower.contains('confect')) {
      return const _VisualProps(
        icon: Icons.cookie_rounded,
        color: Color(0xFFF59E0B),
        bgColor: Color(0xFFFEF3C7),
        gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
        isMajor: false,
        badgeText: 'Munchies',
      );
    } else if (lower.contains('baby') || lower.contains('kid') || lower.contains('toy')) {
      return const _VisualProps(
        icon: Icons.child_care_rounded,
        color: Color(0xFF06B6D4),
        bgColor: Color(0xFFE0F2FE),
        gradient: [Color(0xFF0891B2), Color(0xFF38BDF8)],
        isMajor: false,
        badgeText: 'Baby & Kids',
      );
    } else if (lower.contains('dairy') || lower.contains('egg')) {
      return const _VisualProps(
        icon: Icons.egg_outlined,
        color: Color(0xFF0284C7),
        bgColor: Color(0xFFE0F2FE),
        gradient: [Color(0xFF0369A1), Color(0xFF38BDF8)],
        isMajor: false,
        badgeText: 'Pure Dairy',
      );
    } else if (lower.contains('house') || lower.contains('clean')) {
      return const _VisualProps(
        icon: Icons.cleaning_services_rounded,
        color: Color(0xFF7C3AED),
        bgColor: Color(0xFFEDE9FE),
        gradient: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
        isMajor: false,
        badgeText: 'Clean Home',
      );
    }

    return const _VisualProps(
      icon: Icons.storefront_rounded,
      color: Color(0xFF16A34A),
      bgColor: Color(0xFFDCFCE7),
      gradient: [Color(0xFF15803D), Color(0xFF22C55E)],
      isMajor: false,
      badgeText: 'Supermarket',
    );
  }

  static int? resolveCanonicalCategoryId(String input) {
    final s = input.trim().toLowerCase().replaceAll('&', ' ').replaceAll('-', ' ').replaceAll('_', ' ');
    if (s.contains('snack') || s.contains('confectionery') || s.contains('biscuit') || s.contains('crisp')) return 1;
    if (s.contains('bakery') || s.contains('pastr') || s.contains('bread') || s.contains('oven')) return 2;
    if (s.contains('drink') || s.contains('juice') || s.contains('beverag') || s.contains('soda')) return 3;
    if (s.contains('alcohol') || s.contains('spirit') || s.contains('wine') || s.contains('beer')) return 4;
    if (s.contains('oil') || s.contains('spice') || s.contains('seasoning') || s.contains('condiment')) return 8;
    if (s.contains('dairy') || s.contains('egg') || s.contains('milk') || s.contains('butter') || s.contains('cheese')) return 5;
    if (s.contains('ice cream') || s.contains('frozen') || s.contains('dessert') || s.contains('gelato') || s.split(' ').contains('ice')) return 6;
    if (s.contains('grain') || s.contains('flour') || s.contains('staple') || s.contains('rice') || s.contains('wholesale') || s.contains('pantry')) return 7;
    if (s.contains('vegetable') || s.contains('fruit') || s.contains('produce') || s.contains('meat') || s.contains('poultry') || s.contains('farm') || s.contains('butcher') || s.contains('deli')) return 9;
    if (s.contains('personal') || s.contains('groom') || s.contains('wellness')) return 10;
    if (s.contains('house') || s.contains('clean') || s.contains('detergent')) return 11;
    if (s.contains('baby') || s.contains('kid') || s.contains('toy') || s.contains('diaper')) return 12;
    if (s.contains('electr') || s.contains('appliance') || s.contains('gadget')) return 13;
    if (s.contains('furnit') || s.contains('living') || s.contains('decor')) return 14;
    if (s.contains('pharm') || s.contains('health') || s.contains('med')) return 15;
    return null;
  }

  static CategoryModel findMatchingCategory(List<CategoryModel> categories, String input) {
    if (categories.isEmpty) {
      return const CategoryModel(
        id: 0,
        name: 'All Departments',
        slug: 'all',
        icon: Icons.apps_rounded,
        color: Color(0xFF16A34A),
        bgColor: Color(0xFFDCFCE7),
        gradient: [Color(0xFF15803D), Color(0xFF22C55E)],
      );
    }

    final canonicalId = resolveCanonicalCategoryId(input);
    if (canonicalId != null) {
      final match = categories.where((c) => c.id == canonicalId);
      if (match.isNotEmpty) return match.first;
    }

    final lower = input.trim().toLowerCase();
    // Try exact slug
    final exactSlug = categories.where((c) => c.slug.toLowerCase() == lower);
    if (exactSlug.isNotEmpty) return exactSlug.first;

    // Try partial name or slug
    final partial = categories.where(
      (c) => c.slug.toLowerCase().contains(lower) || c.name.toLowerCase().contains(lower),
    );
    if (partial.isNotEmpty) return partial.first;

    return categories.first;
  }
}

class _VisualProps {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<Color> gradient;
  final bool isMajor;
  final String badgeText;

  const _VisualProps({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.gradient,
    required this.isMajor,
    required this.badgeText,
  });
}
