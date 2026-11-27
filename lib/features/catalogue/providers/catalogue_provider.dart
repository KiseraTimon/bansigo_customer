// lib/features/catalogue/providers/catalogue_provider.dart

import 'package:flutter/material.dart';
import '../../home/models/product_model.dart';
import '../models/category_model.dart';
import '../services/catalogue_service.dart';

class CatalogueProvider with ChangeNotifier {
  final CatalogueService _service;

  List<CategoryModel> _categories = List.from(CatalogueService.defaultStoreCategories);
  List<ProductModel> _allProducts = List.from(CatalogueService.defaultFallbackProducts);
  List<ProductModel> _freshGroceryProducts = [];
  List<ProductModel> _householdProducts = [];
  List<ProductModel> _snacksProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _categoryProducts = [];
  List<ProductModel> _searchResults = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String _selectedCategorySlug = 'all';
  String _currentSearchQuery = '';

  CatalogueProvider(this._service) {
    _partitionProducts();
    loadInitialData();
  }

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get freshGroceryProducts => _freshGroceryProducts;
  List<ProductModel> get householdProducts => _householdProducts;
  List<ProductModel> get snacksProducts => _snacksProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get categoryProducts => _categoryProducts;
  List<ProductModel> get searchResults => _searchResults;

  static const ProductModel defaultSpotlightProduct = ProductModel(
    id: 'spotlight_honey',
    name: 'Pure Kenyan Highland Wild Honey',
    unit: '500g Glass Jar',
    price: 450,
    originalPrice: 600,
    discountPercentage: 25,
    category: 'Natural Essentials',
    description: '100% Raw unprocessed floral honey harvest from the pristine Kenyan highlands.',
  );

  ProductModel get spotlightProduct {
    try {
      // 1. Check if explicit spotlight honey item is present
      final spotlightMatches = _allProducts.where((p) => p.name.contains('Wild Honey') || p.id == 'spotlight_honey');
      if (spotlightMatches.isNotEmpty) {
        return spotlightMatches.first;
      }

      // 2. Look for a real backend deal from server SKU (numeric ID)
      final backendDeals = _allProducts.where(
        (p) => p.originalPrice != null && p.originalPrice! > p.price && int.tryParse(p.id) != null,
      );
      if (backendDeals.isNotEmpty) {
        return backendDeals.first;
      }
    } catch (_) {}

    return defaultSpotlightProduct;
  }

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get selectedCategorySlug => _selectedCategorySlug;
  String get currentSearchQuery => _currentSearchQuery;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getCategories(),
        _service.getProducts(perPage: 60),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _allProducts = results[1] as List<ProductModel>;

      _partitionProducts();
    } catch (_) {
      // Keep fallbacks active
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _partitionProducts() {
    if (_allProducts.isEmpty) {
      _freshGroceryProducts = CatalogueService.defaultFallbackProducts
          .where((p) => p.category.toLowerCase().contains('fresh') || p.category.toLowerCase().contains('produce') || p.categoryId == 9)
          .toList();
      _householdProducts = CatalogueService.defaultFallbackProducts
          .where((p) => p.category.toLowerCase().contains('house') || p.categoryId == 11)
          .toList();
      _snacksProducts = CatalogueService.defaultFallbackProducts
          .where((p) => p.category.toLowerCase().contains('snack') || p.categoryId == 1)
          .toList();
      _featuredProducts = List.from(CatalogueService.defaultFallbackProducts);
      return;
    }

    _freshGroceryProducts = _allProducts
        .where((p) =>
            p.category.toLowerCase().contains('fresh') ||
            p.category.toLowerCase().contains('produce') ||
            p.categoryId == 9)
        .take(10)
        .toList();

    _householdProducts = _allProducts
        .where((p) =>
            p.category.toLowerCase().contains('house') ||
            p.category.toLowerCase().contains('clean') ||
            p.categoryId == 11)
        .take(10)
        .toList();

    _snacksProducts = _allProducts
        .where((p) =>
            p.category.toLowerCase().contains('snack') ||
            p.category.toLowerCase().contains('biscuit') ||
            p.categoryId == 1)
        .take(10)
        .toList();

    _featuredProducts = _allProducts.take(12).toList();
  }

  Future<void> refreshCatalog() async {
    _isLoading = true;
    notifyListeners();

    // Fetch refreshed list from backend with a small variation or fresh page
    try {
      final fresh = await _service.getProducts(page: 1, perPage: 60);
      if (fresh.isNotEmpty) {
        // Shuffle slightly for a refreshed discovery feel
        fresh.shuffle();
        _allProducts = fresh;
        _partitionProducts();
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String slugOrName) async {
    _selectedCategorySlug = slugOrName;
    if (slugOrName == 'all') {
      _categoryProducts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final cat = CategoryModel.findMatchingCategory(_categories, slugOrName);

    try {
      final items = await _service.getProducts(
        categoryId: cat.id > 0 ? cat.id : null,
        perPage: 40,
      );
      _categoryProducts = items;
    } catch (_) {
      _categoryProducts = _allProducts.where((p) => p.categoryId == cat.id).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ProductModel>> getProductsForCategory(int categoryId) async {
    try {
      return await _service.getProducts(categoryId: categoryId, perPage: 40);
    } catch (_) {
      return _allProducts.where((p) => p.categoryId == categoryId).toList();
    }
  }

  Future<void> search(String query, {int? categoryId, double? maxPrice, bool inStockOnly = false}) async {
    _currentSearchQuery = query;
    if (query.trim().isEmpty && categoryId == null && maxPrice == null && !inStockOnly) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final results = await _service.getProducts(
        q: query.trim().isNotEmpty ? query.trim() : null,
        categoryId: categoryId,
        maxPrice: maxPrice,
        inStockOnly: inStockOnly,
        perPage: 50,
      );
      _searchResults = results;
    } catch (_) {
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
}
