// lib/features/catalogue/screens/search_products_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/illustrations/vector_illustrations.dart';
import '../../../shared/widgets/floating_cart_bar.dart';
import '../../../shared/widgets/select_cart_bottom_sheet.dart';
import '../../home/models/product_model.dart';
import '../../home/widgets/product_card.dart';
import '../providers/catalogue_provider.dart';
import 'product_details_screen.dart';

class SearchProductsScreen extends StatefulWidget {
  final String? initialQuery;
  final int? initialCategoryId;

  const SearchProductsScreen({
    super.key,
    this.initialQuery,
    this.initialCategoryId,
  });

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  late final TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  int? _selectedCategoryId;
  double? _selectedMaxPrice;
  bool _inStockOnly = false;

  final List<String> _popularSuggestions = const [
    'Milk',
    'Bread',
    'Avocado',
    'Sausages',
    'Crisps',
    'Juice',
    'Kettle',
    'Panadol',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedCategoryId = widget.initialCategoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (_searchController.text.isNotEmpty || _selectedCategoryId != null) {
        _performSearch();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final provider = Provider.of<CatalogueProvider>(context, listen: false);
    provider.search(
      _searchController.text,
      categoryId: _selectedCategoryId,
      maxPrice: _selectedMaxPrice,
      inStockOnly: _inStockOnly,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedCategoryId = null;
      _selectedMaxPrice = null;
      _inStockOnly = false;
    });
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    final catalogue = Provider.of<CatalogueProvider>(context);
    final results = catalogue.searchResults;
    final isSearching = catalogue.isSearching;
    final hasActiveFilter = _searchController.text.trim().isNotEmpty ||
        _selectedCategoryId != null ||
        _selectedMaxPrice != null ||
        _inStockOnly;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
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
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _focusNode.hasFocus ? AppColors.primary : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.primaryDark, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onChanged: _onQueryChanged,
                              style: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search items, brands, groceries...',
                                hintStyle: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13.5,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            InkWell(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All Departments',
                    isSelected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      _performSearch();
                    },
                  ),
                  ...catalogue.categories.map((cat) {
                    final isSel = _selectedCategoryId == cat.id;
                    return _buildFilterChip(
                      label: cat.name.split(' ').first,
                      isSelected: isSel,
                      icon: cat.icon,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = isSel ? null : cat.id;
                        });
                        _performSearch();
                      },
                    );
                  }),
                  _buildFilterChip(
                    label: 'Under KES 200',
                    isSelected: _selectedMaxPrice == 200,
                    onTap: () {
                      setState(() {
                        _selectedMaxPrice = _selectedMaxPrice == 200 ? null : 200;
                      });
                      _performSearch();
                    },
                  ),
                  _buildFilterChip(
                    label: 'In Stock Only',
                    isSelected: _inStockOnly,
                    icon: Icons.check_circle_outline_rounded,
                    onTap: () {
                      setState(() => _inStockOnly = !_inStockOnly);
                      _performSearch();
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Body Area
            Expanded(
              child: isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : !hasActiveFilter
                      ? _buildSuggestionsView()
                      : results.isEmpty
                          ? _buildEmptyState()
                          : _buildResultsGrid(results),
            ),
          ],
        ),
      ),
      const FloatingCartBar(bottomOffset: 16),
    ],
  ),
);
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: icon != null
            ? Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.slateDark,
              )
            : null,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.slateDark,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        showCheckmark: false,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildSuggestionsView() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Popular Searches',
          style: AppTextStyles.h2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: _popularSuggestions.map((query) {
            return InkWell(
              onTap: () {
                _searchController.text = query;
                _performSearch();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      query,
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'Quick Shop Departments',
          style: AppTextStyles.h2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Consumer<CatalogueProvider>(
          builder: (context, catProvider, _) {
            final majorCats = catProvider.categories.where((c) => c.isMajorDepartment).toList();
            return Column(
              children: majorCats.map((cat) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cat.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 20),
                  ),
                  title: Text(cat.name, style: AppTextStyles.bodySemiBold),
                  subtitle: Text(cat.badgeText, style: AppTextStyles.caption),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                  onTap: () {
                    setState(() => _selectedCategoryId = cat.id);
                    _performSearch();
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const EmptySearchIllustration(size: 150),
            const SizedBox(height: 20),
            Text(
              'No Products Found',
              style: AppTextStyles.h2.copyWith(fontSize: 19),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'We couldn\'t find any items matching "${_searchController.text}". Check your spelling or try different keywords.'
                  : 'No items match your active filters. Try adjusting price or categories.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _clearSearch,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.slateDark,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Clear Filters'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Explore Aisles'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsGrid(List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Found ${products.length} products',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            physics: const BouncingScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onAddToCart: () {
                  SelectCartBottomSheet.show(context: context, product: product);
                },
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
        ),
      ],
    );
  }
}
