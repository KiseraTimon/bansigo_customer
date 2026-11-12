// lib/features/catalogue/services/catalogue_service.dart

import 'package:flutter/material.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';
import '../../home/models/product_model.dart';
import '../models/category_model.dart';
import '../../../shared/illustrations/vector_illustrations.dart';

class CatalogueService {
  final ApiClient _apiClient;

  CatalogueService(this._apiClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.categories);
      final List? rawList = res is List ? res : (res is Map<String, dynamic> && res['items'] is List ? res['items'] as List : null);
      if (rawList != null) {
        final list = rawList
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      AppLogger.w('Could not fetch categories from server: $e');
    }
    return defaultStoreCategories;
  }

  Future<List<ProductModel>> getProducts({
    String? q,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    bool inStockOnly = false,
    int page = 1,
    int perPage = 30,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page': page,
        'per_page': perPage,
        'in_stock_only': inStockOnly,
      };
      if (q != null && q.trim().isNotEmpty) params['q'] = q.trim();
      if (categoryId != null && categoryId > 0) params['category_id'] = categoryId;
      if (brandId != null) params['brand_id'] = brandId;
      if (minPrice != null) params['min_price'] = minPrice;
      if (maxPrice != null) params['max_price'] = maxPrice;

      final res = await _apiClient.get(ApiEndpoints.products, queryParameters: params);
      final List? rawItems = res is Map<String, dynamic> && res['items'] is List
          ? res['items'] as List
          : (res is List ? res : null);
      if (rawItems != null) {
        final list = rawItems
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      AppLogger.w('Could not fetch products from server: $e');
    }
    return _filterFallbackProducts(q: q, categoryId: categoryId, minPrice: minPrice, maxPrice: maxPrice);
  }

  Future<ProductModel?> getProductDetail(int id) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.productDetail(id));
      if (res is Map<String, dynamic>) {
        return ProductModel.fromJson(res);
      }
    } catch (e) {
      AppLogger.w('Could not fetch product detail from server: $e');
    }
    // Check fallback by id
    try {
      return defaultFallbackProducts.firstWhere((p) => p.id == id.toString());
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductModel>> getRelatedProducts(int id) async {
    try {
      final res = await _apiClient.get(ApiEndpoints.relatedProducts(id));
      final List? rawList = res is List ? res : (res is Map<String, dynamic> && res['items'] is List ? res['items'] as List : null);
      if (rawList != null) {
        final list = rawList
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      AppLogger.w('Could not fetch related products from server: $e');
    }

    return [
      const ProductModel(
        id: 'rec-nido-1',
        name: 'Nestle Nido Full Cream Milk Powder Instant',
        unit: '400g',
        price: 270.00,
        originalPrice: 342.00,
        category: 'Dairy Products',
        description:
            'Et quidem faciunt, ut summum bonum sit extremum et rationibus conquisitis de voluptate.',
        illustration: MilkPowderCanIllustration(size: 72),
      ),
      const ProductModel(
        id: 'rec-dano-2',
        name: 'Nestle Nido Full Cream Milk Powder Instant',
        unit: '1 KG',
        price: 270.00,
        originalPrice: 342.00,
        category: 'Dairy Products',
        description:
            'Et quidem faciunt, ut summum bonum sit extremum et rationibus conquisitis de voluptate.',
        illustration: MilkPowderPouchIllustration(size: 72),
      ),
    ];
  }

  List<ProductModel> _filterFallbackProducts({
    String? q,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) {
    List<ProductModel> list = List.from(defaultFallbackProducts);
    if (categoryId != null && categoryId > 0) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (q != null && q.trim().isNotEmpty) {
      final queryLower = q.trim().toLowerCase();
      list = list.where((p) =>
        p.name.toLowerCase().contains(queryLower) ||
        p.category.toLowerCase().contains(queryLower)
      ).toList();
    }
    if (minPrice != null) {
      list = list.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      list = list.where((p) => p.price <= maxPrice).toList();
    }
    return list;
  }

  static final List<CategoryModel> defaultStoreCategories = [
    const CategoryModel(
      id: 15,
      name: 'Pharmacy & Healthcare',
      slug: 'pharmacy-healthcare',
      description: 'Prescription refills, pain relief, vitamins & daily wellness',
      itemCount: 48,
      icon: Icons.local_pharmacy_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFD1FAE5),
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
      isMajorDepartment: true,
      badgeText: 'Health & Meds',
    ),
    const CategoryModel(
      id: 2,
      name: 'Bakery & Pastries',
      slug: 'bakery-pastries',
      description: 'Oven fresh loaves, sweet buns, croissants & birthday cakes',
      itemCount: 35,
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
      isMajorDepartment: true,
      badgeText: 'Oven Fresh',
    ),
    const CategoryModel(
      id: 9,
      name: 'Deli & Fresh Meat',
      slug: 'meat-poultry-fresh-produce',
      description: 'Butcher cuts, sausages, rotisserie chicken & cured meats',
      itemCount: 42,
      icon: Icons.restaurant_rounded,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
      gradient: [Color(0xFFEA580C), Color(0xFFF97316)],
      isMajorDepartment: true,
      badgeText: 'Hot & Sliced',
    ),
    const CategoryModel(
      id: 3,
      name: 'Drinks & Beverages',
      slug: 'beverages-soft-drinks',
      description: 'Chilled sodas, 100% pure juices, mineral water & energy drinks',
      itemCount: 60,
      icon: Icons.local_bar_rounded,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFCFFAFE),
      gradient: [Color(0xFF0891B2), Color(0xFF06B6D4)],
      isMajorDepartment: true,
      badgeText: 'Chilled Cold',
    ),
    const CategoryModel(
      id: 13,
      name: 'Electronics & Gadgets',
      slug: 'electronics-appliances',
      description: 'Blenders, electric kettles, headphones, chargers & batteries',
      itemCount: 28,
      icon: Icons.devices_other_rounded,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFDBEAFE),
      gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      isMajorDepartment: true,
      badgeText: 'Appliances',
    ),
    const CategoryModel(
      id: 14,
      name: 'Furniture & Living',
      slug: 'furniture-home-living',
      description: 'Storage boxes, cushions, plastic ware, mirrors & decor',
      itemCount: 22,
      icon: Icons.chair_rounded,
      color: Color(0xFF9333EA),
      bgColor: Color(0xFFF3E8FF),
      gradient: [Color(0xFF7E22CE), Color(0xFFA855F7)],
      isMajorDepartment: true,
      badgeText: 'Home Comfort',
    ),
    const CategoryModel(
      id: 5,
      name: 'Dairy & Eggs',
      slug: 'dairy-eggs',
      description: 'Fresh milk, butter, cheese blocks & farm eggs',
      itemCount: 38,
      icon: Icons.egg_outlined,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      gradient: [Color(0xFF0369A1), Color(0xFF38BDF8)],
      isMajorDepartment: false,
      badgeText: 'Farm Dairy',
    ),
    const CategoryModel(
      id: 6,
      name: 'Ice Cream & Frozen',
      slug: 'ice-cream-frozen-desserts',
      description: 'Creamy tubs, gelato sticks, frozen yogurt & dessert toppings',
      itemCount: 24,
      icon: Icons.icecream_rounded,
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFCE7F3),
      gradient: [Color(0xFFDB2777), Color(0xFFF472B6)],
      isMajorDepartment: false,
      badgeText: 'Frozen Treats',
    ),
    const CategoryModel(
      id: 1,
      name: 'Snacks & Confectionery',
      slug: 'snacks-confectionery',
      description: 'Crisps, salted nuts, chocolates, cookies & candy',
      itemCount: 55,
      icon: Icons.cookie_rounded,
      color: Color(0xFFF59E0B),
      bgColor: Color(0xFFFEF3C7),
      gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
      isMajorDepartment: false,
      badgeText: 'Quick Bites',
    ),
    const CategoryModel(
      id: 12,
      name: 'Baby Care & Toys',
      slug: 'baby-care-kids',
      description: 'Diapers, gentle wipes, baby food, formula & kids toys',
      itemCount: 30,
      icon: Icons.child_care_rounded,
      color: Color(0xFF06B6D4),
      bgColor: Color(0xFFE0F2FE),
      gradient: [Color(0xFF0891B2), Color(0xFF38BDF8)],
      isMajorDepartment: false,
      badgeText: 'Kids & Care',
    ),
    const CategoryModel(
      id: 11,
      name: 'Household & Cleaning',
      slug: 'household-cleaning',
      description: 'Detergents, floor cleaners, dish soaps & disinfectants',
      itemCount: 40,
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFEDE9FE),
      gradient: [Color(0xFF6D28D9), Color(0xFF8B5CF6)],
      isMajorDepartment: false,
      badgeText: 'Cleaning',
    ),
    const CategoryModel(
      id: 7,
      name: 'Grains & Staple Foods',
      slug: 'grains-flours-staple-foods',
      description: 'Maize flour, wheat flour, aromatic basmati rice & beans',
      itemCount: 45,
      icon: Icons.grain_rounded,
      color: Color(0xFFCA8A04),
      bgColor: Color(0xFFFEF08A),
      gradient: [Color(0xFFA16207), Color(0xFFEAB308)],
      isMajorDepartment: false,
      badgeText: 'Staples',
    ),
  ];

  static final List<ProductModel> defaultFallbackProducts = [
    // Pharmacy
    const ProductModel(
      id: 'pharm_panadol',
      name: 'Panadol Extra Paracetamol 500mg',
      unit: 'Pack of 16 Tablets',
      price: 180,
      originalPrice: 210,
      discountPercentage: 14,
      rating: 4.9,
      category: 'Pharmacy & Healthcare',
      categoryId: 15,
      description: 'Fast effective relief from tough headaches, back pain and body aches.',
      icon: Icons.local_pharmacy_rounded,
      iconColor: Color(0xFF059669),
      iconBgColor: Color(0xFFD1FAE5),
    ),
    const ProductModel(
      id: 'pharm_vitaminc',
      name: 'Ascorbic Acid Effervescent Vitamin C 1000mg',
      unit: 'Tube of 20 Tablets',
      price: 520,
      originalPrice: 600,
      discountPercentage: 13,
      rating: 4.8,
      category: 'Pharmacy & Healthcare',
      categoryId: 15,
      description: 'Immune support antioxidant drinkable fizzy tablets with orange flavor.',
      icon: Icons.medication_rounded,
      iconColor: Color(0xFF059669),
      iconBgColor: Color(0xFFD1FAE5),
    ),
    // Bakery
    const ProductModel(
      id: 'bake_croissant',
      name: 'Golden Flaky Butter Croissants',
      unit: 'Pack of 4',
      price: 240,
      originalPrice: 280,
      discountPercentage: 14,
      rating: 4.9,
      category: 'Bakery & Pastries',
      categoryId: 2,
      description: 'French style layered butter pastry baked fresh every single morning.',
      icon: Icons.bakery_dining_rounded,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
    ),
    const ProductModel(
      id: 'bake_festive_white',
      name: 'Festive Premium Sliced White Bread',
      unit: '400g freshly baked',
      price: 65,
      rating: 4.8,
      category: 'Bakery & Pastries',
      categoryId: 2,
      description: 'Soft, vitamin-enriched family sandwich bread.',
      icon: Icons.bakery_dining_rounded,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
    ),
    // Deli
    const ProductModel(
      id: 'deli_beef_sausages',
      name: 'Farmer\'s Choice Premium Beef Sausages',
      unit: '500g Chilled Pack',
      price: 360,
      originalPrice: 400,
      discountPercentage: 10,
      rating: 4.9,
      category: 'Deli & Fresh Meat',
      categoryId: 9,
      description: 'Kenya\'s favorite savory breakfast sausages, seasoned with select spices.',
      icon: Icons.kebab_dining_rounded,
      iconColor: Color(0xFFDC2626),
      iconBgColor: Color(0xFFFEE2E2),
      illustration: MeatFishIllustration(size: 44),
    ),
    const ProductModel(
      id: 'deli_bbq_chicken',
      name: 'Rotisserie Spiced Whole Roasted Chicken',
      unit: '1 Whole Hot Bird',
      price: 780,
      originalPrice: 850,
      discountPercentage: 8,
      rating: 4.9,
      category: 'Deli & Fresh Meat',
      categoryId: 9,
      description: 'Slow-roasted juicy rotisserie chicken marinated in garlic & rosemary herbs.',
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFEDD5),
    ),
    // Drinks
    const ProductModel(
      id: 'drink_minute_maid',
      name: 'Minute Maid Pulpy Orange Juice',
      unit: '1 Litre Chilled Bottle',
      price: 160,
      originalPrice: 190,
      discountPercentage: 15,
      rating: 4.8,
      category: 'Drinks & Beverages',
      categoryId: 3,
      description: 'Refreshing real orange fruit juice bursting with natural pulps.',
      icon: Icons.local_bar_rounded,
      iconColor: Color(0xFF0891B2),
      iconBgColor: Color(0xFFCFFAFE),
    ),
    const ProductModel(
      id: 'drink_coca_cola',
      name: 'Coca-Cola Original Taste Chilled Can',
      unit: '330ml Can',
      price: 80,
      rating: 4.9,
      category: 'Drinks & Beverages',
      categoryId: 3,
      description: 'The world classic bubbly crisp cola refreshment.',
      icon: Icons.sports_bar_rounded,
      iconColor: Color(0xFFDC2626),
      iconBgColor: Color(0xFFFEE2E2),
    ),
    // Electronics
    const ProductModel(
      id: 'elec_kettle',
      name: 'Ramtons Stainless Steel Fast Electric Kettle',
      unit: '1.8 Litre Capacity',
      price: 1850,
      originalPrice: 2200,
      discountPercentage: 16,
      rating: 4.8,
      category: 'Electronics & Gadgets',
      categoryId: 13,
      description: 'Auto-shutoff boil-dry protection with rapid boiling heating element.',
      icon: Icons.electric_bolt_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
    ),
    const ProductModel(
      id: 'elec_blender',
      name: 'Sayona 2-in-1 Glass Smoothie Blender & Grinder',
      unit: '1.5 Litre 400W',
      price: 2950,
      originalPrice: 3400,
      discountPercentage: 13,
      rating: 4.7,
      category: 'Electronics & Gadgets',
      categoryId: 13,
      description: 'Stainless steel blades for crushing ice, fresh smoothies, and milling spices.',
      icon: Icons.blender_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFDBEAFE),
    ),
    // Furniture & Living
    const ProductModel(
      id: 'furn_storage_box',
      name: 'Heavy Duty Transparent Storage Box with Lid',
      unit: '50 Litre Capacity',
      price: 950,
      originalPrice: 1150,
      discountPercentage: 17,
      rating: 4.7,
      category: 'Furniture & Living',
      categoryId: 14,
      description: 'Sturdy stackable home organizer box with clip lock handles.',
      icon: Icons.all_inbox_rounded,
      iconColor: Color(0xFF9333EA),
      iconBgColor: Color(0xFFF3E8FF),
    ),
    const ProductModel(
      id: 'furn_cushion',
      name: 'Velvet Soft Accent Living Room Cushion',
      unit: 'Set of 2 Cushions',
      price: 1200,
      rating: 4.8,
      category: 'Furniture & Living',
      categoryId: 14,
      description: 'Plush decorative throw pillows for sofa seating comfort.',
      icon: Icons.chair_rounded,
      iconColor: Color(0xFF9333EA),
      iconBgColor: Color(0xFFF3E8FF),
    ),
    // Fresh Groceries
    const ProductModel(
      id: 'fresh_avocado',
      name: 'Ripe Farm Hass Avocados',
      unit: 'Pack of 3',
      price: 120,
      originalPrice: 150,
      discountPercentage: 20,
      rating: 4.9,
      category: 'Fresh Grocery',
      categoryId: 9,
      icon: Icons.eco_rounded,
      iconColor: Color(0xFF16A34A),
      iconBgColor: Color(0xFFDCFCE7),
      illustration: AvocadoIllustration(size: 44),
    ),
    const ProductModel(
      id: 'fresh_sukuma',
      name: 'Farm Fresh Sukuma Wiki',
      unit: '1 Fresh Bunch',
      price: 40,
      originalPrice: 50,
      discountPercentage: 20,
      rating: 4.8,
      category: 'Fresh Grocery',
      categoryId: 9,
      icon: Icons.grass_rounded,
      iconColor: Color(0xFF15803D),
      iconBgColor: Color(0xFFDCFCE7),
    ),
    // Snacks
    const ProductModel(
      id: 'snack_crisps',
      name: 'Tropical Potato Crisps Salted',
      unit: '100g foil pack',
      price: 110,
      rating: 4.8,
      category: 'Snacks & Confectionery',
      categoryId: 1,
      icon: Icons.fastfood_rounded,
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFEDD5),
      illustration: SnacksIllustration(size: 44),
    ),
    const ProductModel(
      id: 'snack_cashews',
      name: 'Roasted & Salted Cashew Nuts',
      unit: '150g pouch',
      price: 290,
      originalPrice: 340,
      discountPercentage: 15,
      rating: 4.9,
      category: 'Snacks & Confectionery',
      categoryId: 1,
      icon: Icons.grain_rounded,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
    ),
    // Dairy
    const ProductModel(
      id: 'dairy_brookside_milk',
      name: 'Brookside Pure Whole Milk',
      unit: '500ml pouch',
      price: 65,
      rating: 4.9,
      category: 'Dairy & Eggs',
      categoryId: 5,
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF0284C7),
      iconBgColor: Color(0xFFE0F2FE),
      illustration: DairyIllustration(size: 44),
    ),
    const ProductModel(
      id: 'dairy_eggs_tray',
      name: 'Farm Fresh Grade-A Yellow Yolk Eggs',
      unit: 'Tray of 30 Eggs',
      price: 450,
      rating: 4.9,
      category: 'Dairy & Eggs',
      categoryId: 5,
      icon: Icons.egg_rounded,
      iconColor: Color(0xFFEA580C),
      iconBgColor: Color(0xFFFFEDD5),
    ),
  ];
}
