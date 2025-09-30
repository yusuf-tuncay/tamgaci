// ========== PRODUCT VARIANTS PAGE ==========
// lib/features/products/presentation/pages/product_variants_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import '../widgets/variant_edit_dialog.dart';

/// Ürün varyantları sayfası
class ProductVariantsPage extends ConsumerStatefulWidget {
  const ProductVariantsPage({super.key});

  @override
  ConsumerState<ProductVariantsPage> createState() => _ProductVariantsPageState();
}

class _ProductVariantsPageState extends ConsumerState<ProductVariantsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _categorySearchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Ürün Varyantları', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      body: productsAsync.when(
        data: (products) {
          // Varyantlı ürünleri filtrele
          final productsWithVariants = products
              .where((product) => product.variants != null && product.variants!.isNotEmpty)
              .toList();

          if (productsWithVariants.isEmpty) {
            return _buildEmptyState(isDark);
          }

          return Column(
            children: [
              _buildHeader(isDark),
              _buildFiltersSection(isDark),
              Expanded(
                child: _buildVariantsList(productsWithVariants, isDark),
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dashboard_customize,
              color: Colors.purple[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Ürün Varyantları',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? TamgaciConstants.textPrimaryDark : TamgaciConstants.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Aktif',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.purple[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchField(isDark),
          ),
          const SizedBox(width: 12),
          _buildFilterButton('Kategori', _selectedCategory, isDark),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Ürün ara...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildFilterButton(String label, String value, bool isDark) {
    return InkWell(
      onTap: () => _showFilterDialog(label, isDark),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantsList(List<Product> products, bool isDark) {
    // Arama ve kategori filtresi uygula
    final filteredProducts = products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'Tümü' ||
          product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product, isDark);
      },
    );
  }

  Widget _buildProductCard(Product product, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ürün başlığı
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey[800],
                        ),
                      ),
                      if (product.category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          product.category!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.variants!.length} varyant',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Varyantlar
            ...product.variants!.map((variant) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                child: InkWell(
                  onTap: () => _showVariantEditDialog(context, product, variant, product.variants!.indexOf(variant)),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              variant.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.grey[800],
                              ),
                            ),
                            if (variant.shelfLocation != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Raf: ${variant.shelfLocation}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                            if (variant.barcode != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Barkod: ${variant.barcode}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: variant.stockQuantity > 0
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${CurrencyHelper.formatNumber(variant.stockQuantity.toDouble()).replaceAll(',00', '')} adet',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz varyantlı ürün yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ürünlerinize varyant ekleyerek daha detaylı stok takibi yapabilirsiniz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Varyantlar yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(String filterType, bool isDark) {
    setState(() {
      _categorySearchQuery = '';
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '$filterType Filtresi',
          style: GoogleFonts.poppins(),
        ),
        content: _buildCategoryFilter(isDark),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _categorySearchQuery = '';
              });
              Navigator.pop(context);
            },
            child: Text(
              'Kapat',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    final productsAsync = ref.watch(productsStreamProvider);
    
    return productsAsync.when(
      data: (products) {
        final categories = products
            .where((p) => p.category != null && p.category!.isNotEmpty)
            .map((p) => p.category!)
            .toSet()
            .toList()
          ..sort();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arama alanı
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Kategori ara...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _categorySearchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  // Tümü seçeneği
                  ListTile(
                    title: Text('Tümü', style: GoogleFonts.poppins()),
                    leading: Icon(
                      _selectedCategory == 'Tümü'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedCategory == 'Tümü'
                          ? const Color(0xFF6366F1)
                          : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Tümü';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1),
                  // Kategoriler (filtrelenmiş)
                  ...categories
                      .where((category) =>
                          _categorySearchQuery.isEmpty ||
                          category.toLowerCase().contains(_categorySearchQuery))
                      .map((category) {
                    return ListTile(
                      title: Text(category, style: GoogleFonts.poppins()),
                      leading: Icon(
                        _selectedCategory == category
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _selectedCategory == category
                            ? const Color(0xFF6366F1)
                            : Colors.grey,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${products.where((p) => p.category == category).length}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Kategoriler yüklenemedi'),
    );
  }

  void _showVariantEditDialog(BuildContext context, Product product, ProductVariant variant, int variantIndex) {
    showDialog(
      context: context,
      builder: (context) => VariantEditDialog(
        product: product,
        variant: variant,
        variantIndex: variantIndex,
      ),
    );
  }
}
