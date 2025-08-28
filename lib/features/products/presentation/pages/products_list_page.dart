// ========== PRODUCTS (ÜRÜNLER) FEATURE ==========
// lib/features/products/presentation/pages/products_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';

/// Ürün listesi sayfası
class ProductsListPage extends ConsumerStatefulWidget {
  const ProductsListPage({super.key});

  @override
  ConsumerState<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends ConsumerState<ProductsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _selectedCategory = 'Tümü';
  String _sortBy = 'name';
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  void _loadProducts() {
    // Ürünler zaten provider'da yüklü olmalı
    // Eğer yüklü değilse yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(productOperationsProvider);
      if (operationsState.products.isEmpty && !operationsState.isLoading) {
        ref.read(productOperationsProvider.notifier).loadProducts();
      }
    });
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _navigateToDetail(int productId) {
    Navigator.of(context).pushNamed('/products/detail', arguments: productId);
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/product/create');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(productOperationsProvider);
    final searchQuery = _searchController.text;

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Ürünler',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
          ),
          IconButton(
            onPressed: _showSortDialog,
            icon: const Icon(Icons.sort),
            tooltip: 'Sırala',
          ),
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Ürün',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            padding: TamgaciConstants.paddingMedium(context),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusMD,
                  ),
                ),
              ),
            ),
          ),

          // Ürün listesi
          Expanded(child: _buildProductsList(operationsState, searchQuery)),
        ],
      ),
    );
  }

  /// Ürün listesini oluşturur
  Widget _buildProductsList(
    ProductOperationsState operationsState,
    String searchQuery,
  ) {
    if (operationsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (operationsState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hata: ${operationsState.errorMessage}'),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final products = operationsState.products;

    // Filtreleme ve arama uygula
    List<Product> filteredProducts = products;

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ==
                true) ||
            (product.sku?.toLowerCase().contains(searchQuery.toLowerCase()) ==
                true) ||
            (product.barcode?.contains(searchQuery) == true);
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filteredProducts = filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Düşük stok filtresi
    if (_showOnlyLowStock) {
      filteredProducts = filteredProducts
          .where((product) => product.isLowStock)
          .toList();
    }

    // Sıralama - Web platformu için güvenli sıralama
    switch (_sortBy) {
      case 'name':
        filteredProducts = List.from(filteredProducts)
          ..sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price':
        filteredProducts = List.from(filteredProducts)
          ..sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
        break;
      case 'stock':
        filteredProducts = List.from(filteredProducts)
          ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case 'category':
        filteredProducts = List.from(filteredProducts)
          ..sort((a, b) => (a.category ?? '').compareTo(b.category ?? ''));
        break;
    }

    if (filteredProducts.isEmpty && !operationsState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: TamgaciConstants.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? '"$searchQuery" için sonuç bulunamadı'
                  : 'Henüz ürün eklenmemiş',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Ürün Ekle'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(productOperationsProvider.notifier).loadProducts();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  /// Ürün kartı oluşturur
  Widget _buildProductCard(Product product) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(product.id!),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Ürün adı ve durum
              Row(
                children: [
                  // Ürün ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? TamgaciConstants.errorColor.withValues(alpha: 0.1)
                          : isLowStock
                          ? TamgaciConstants.warningColor.withValues(alpha: 0.1)
                          : TamgaciConstants.successColor.withValues(
                              alpha: 0.1,
                            ),
                      borderRadius: BorderRadius.circular(
                        TamgaciConstants.radiusSM,
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: isOutOfStock
                          ? TamgaciConstants.errorColor
                          : isLowStock
                          ? TamgaciConstants.warningColor
                          : TamgaciConstants.successColor,
                      size: 24,
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceMD),

                  // Ürün bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: TamgaciConstants.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.category != null)
                          Text(
                            product.category!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: TamgaciConstants.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceSM),

                  // Stok durumu
                  _buildStockStatusChip(product),
                ],
              ),

              SizedBox(height: TamgaciConstants.spaceMD),

              // Fiyat ve stok bilgileri
              Row(
                children: [
                  // Fiyat
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Fiyat',
                      value: currencyFormat.format(product.unitPrice),
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),

                  SizedBox(width: TamgaciConstants.spaceMD),

                  // Stok miktarı
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Stok',
                      value: '${product.stockQuantity} ${product.unit}',
                      color: isOutOfStock
                          ? TamgaciConstants.errorColor
                          : isLowStock
                          ? TamgaciConstants.warningColor
                          : TamgaciConstants.successColor,
                    ),
                  ),
                ],
              ),

              // SKU ve barkod bilgileri
              if (product.sku != null || product.barcode != null) ...[
                SizedBox(height: TamgaciConstants.spaceSM),
                Row(
                  children: [
                    if (product.sku != null) ...[
                      Icon(
                        Icons.qr_code,
                        size: 16,
                        color: TamgaciConstants.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        product.sku!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TamgaciConstants.textSecondary,
                        ),
                      ),
                    ],
                    if (product.sku != null && product.barcode != null)
                      SizedBox(width: 16),
                    if (product.barcode != null) ...[
                      Icon(
                        Icons.barcode_reader,
                        size: 16,
                        color: TamgaciConstants.textSecondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        product.barcode!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TamgaciConstants.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Stok durumu chip'i oluşturur
  Widget _buildStockStatusChip(Product product) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.stockQuantity <= 0;

    Color backgroundColor;
    Color textColor;
    String text;

    if (isOutOfStock) {
      backgroundColor = TamgaciConstants.errorColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.errorColor;
      text = 'Stokta Yok';
    } else if (isLowStock) {
      backgroundColor = TamgaciConstants.warningColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.warningColor;
      text = 'Kritik Stok';
    } else {
      backgroundColor = TamgaciConstants.successColor.withValues(alpha: 0.1);
      textColor = TamgaciConstants.successColor;
      text = 'Stokta Var';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Bilgi öğesi widget'ı oluşturur
  Widget _buildInfoItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: TamgaciConstants.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Filtre dialog'u gösterir
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Sadece Düşük Stok'),
              value: _showOnlyLowStock,
              onChanged: (value) {
                setState(() {
                  _showOnlyLowStock = value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Sıralama dialog'u gösterir
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sırala'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('İsme Göre'),
              value: 'name',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Fiyata Göre'),
              value: 'price',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Stok Miktarına Göre'),
              value: 'stock',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Kategoriye Göre'),
              value: 'category',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }
}
