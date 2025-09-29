// ========== PRODUCTS LIST PAGE ==========
// lib/features/products/presentation/pages/products_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom_error;
import '../../../../shared/widgets/search_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';
import 'create_product_page.dart';
import 'product_detail_page.dart';

/// Ürünler listesi sayfası
class ProductsListPage extends ConsumerStatefulWidget {
  const ProductsListPage({super.key});

  @override
  ConsumerState<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends ConsumerState<ProductsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  ProductType? _selectedType;
  bool _showLowStockOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Ürünler',
        showBackButton: false,
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
          ),
          IconButton(
            onPressed: () => _showCreateProductPage(),
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Ürün',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama ve filtre çubuğu
          _buildSearchAndFilterBar(),

          // Ürün listesi
          Expanded(
            child: _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProductPage(),
        backgroundColor: TamgaciConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arama çubuğu
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Ürün ara...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Filtre çipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Kategori: $_selectedCategory',
                  onTap: _showCategoryFilter,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _selectedType?.displayName ?? 'Tüm Türler',
                  onTap: _showTypeFilter,
                ),
                const SizedBox(width: 8),
                if (_showLowStockOnly)
                  _buildFilterChip(
                    label: 'Kritik Stok',
                    onTap: () {
                      setState(() {
                        _showLowStockOnly = false;
                      });
                    },
                    isSelected: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? TamgaciConstants.primaryColor
              : (isDark ? TamgaciConstants.cardColorDark : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? TamgaciConstants.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? TamgaciConstants.textPrimaryDark
                        : TamgaciConstants.textPrimary),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 16, color: Colors.white),
            ] else ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Consumer(
      builder: (context, ref, child) {
        // Ürünleri al
        final productsAsync = ref.watch(productsStreamProvider);

        return productsAsync.when(
          data: (products) {
            final filteredProducts = _getFilteredProducts(products);

            if (filteredProducts.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildProductCard(product);
              },
            );
          },
          loading: () => const LoadingWidget(),
          error: (error, stack) => custom_error.ErrorWidget(
            error: error.toString(),
            onRetry: () => ref.refresh(productsStreamProvider),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? TamgaciConstants.cardColorDark : Colors.white,
      child: InkWell(
        onTap: () => _showProductDetail(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ürün resmi
              _buildProductImage(product),

              const SizedBox(width: 12),

              // Ürün bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün adı
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? TamgaciConstants.textPrimaryDark
                            : TamgaciConstants.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Ürün kodu ve barkod
                    if (product.productCode != null || product.barcode != null)
                      Text(
                        'Kod: ${product.productCode ?? product.barcode}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? TamgaciConstants.textSecondaryDark
                              : TamgaciConstants.textSecondary,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Fiyat ve stok bilgisi
                    Row(
                      children: [
                        // Satış fiyatı
                        Text(
                          '${product.salesPrice.toStringAsFixed(2)} ${product.salesCurrency}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TamgaciConstants.primaryColor,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Stok durumu
                        _buildStockStatus(product),
                      ],
                    ),
                  ],
                ),
              ),

              // Ürün türü ve aksiyonlar
              Column(
                children: [
                  // Ürün türü
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(product.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _getTypeColor(product.type).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      product.type.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(product.type),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Aksiyon butonu
                  IconButton(
                    onPressed: () => _showProductActions(product),
                    icon: const Icon(Icons.more_vert),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: TamgaciConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: TamgaciConstants.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: product.images.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultProductIcon();
                },
              ),
            )
          : _buildDefaultProductIcon(),
    );
  }

  Widget _buildDefaultProductIcon() {
    return const Icon(
      Icons.inventory_2_outlined,
      color: TamgaciConstants.primaryColor,
      size: 24,
    );
  }

  Widget _buildStockStatus(Product product) {
    final status = product.stockStatus;
    final color = _getStockStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Ürün bulunamadı',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TamgaciConstants.textPrimaryDark
                  : TamgaciConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni ürün eklemek için + butonuna tıklayın',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getTypeColor(ProductType type) {
    switch (type) {
      case ProductType.stocked:
        return Colors.green;
      case ProductType.nonStocked:
        return Colors.orange;
      case ProductType.service:
        return Colors.blue;
      case ProductType.digital:
        return Colors.purple;
    }
  }

  Color _getStockStatusColor(String status) {
    switch (status) {
      case 'Stokta Var':
        return Colors.green;
      case 'Kritik Stok':
        return Colors.orange;
      case 'Stokta Yok':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Provider'lar
  List<Product> _getFilteredProducts(List<Product> products) {
    var filteredProducts = products;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (product.productCode
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            (product.barcode?.contains(_searchQuery) ?? false);
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filteredProducts = filteredProducts.where((product) {
        return product.category == _selectedCategory;
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != null) {
      filteredProducts = filteredProducts.where((product) {
        return product.type == _selectedType;
      }).toList();
    }

    // Kritik stok filtresi
    if (_showLowStockOnly) {
      filteredProducts = filteredProducts.where((product) {
        return product.isLowStock;
      }).toList();
    }

    return filteredProducts;
  }

  // Navigation methods
  void _showCreateProductPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateProductPage(),
      ),
    );
  }

  void _showProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _showProductActions(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildProductActionsSheet(product),
    );
  }

  Widget _buildProductActionsSheet(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Düzenle'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Edit product page
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Kopyala'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Copy product
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Sil', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(product);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content:
            Text('${product.name} ürününü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(product);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildFilterDialog(),
    );
  }

  Widget _buildFilterDialog() {
    return AlertDialog(
      title: const Text('Filtrele'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kategori filtresi
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: ['Tümü', 'Elektronik', 'Giyim', 'Gıda', 'Kozmetik']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value ?? 'Tümü';
              });
            },
          ),

          const SizedBox(height: 16),

          // Tür filtresi
          DropdownButtonFormField<ProductType?>(
            initialValue: _selectedType,
            decoration: const InputDecoration(labelText: 'Ürün Türü'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tümü')),
              ...ProductType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Kritik stok filtresi
          CheckboxListTile(
            title: const Text('Sadece kritik stoklu ürünler'),
            value: _showLowStockOnly,
            onChanged: (value) {
              setState(() {
                _showLowStockOnly = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategory = 'Tümü';
              _selectedType = null;
              _showLowStockOnly = false;
            });
            Navigator.pop(context);
          },
          child: const Text('Temizle'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Uygula'),
        ),
      ],
    );
  }

  void _showCategoryFilter() {
    // TODO: Implement category filter
  }

  void _showTypeFilter() {
    // TODO: Implement type filter
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await ref
          .read(productOperationsProvider.notifier)
          .deleteProduct(product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün başarıyla silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
