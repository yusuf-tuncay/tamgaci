// ========== ENHANCED PRODUCTS LIST PAGE ==========
// lib/features/products/presentation/pages/enhanced_products_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/product_providers.dart';
import '../../domain/entities/product.dart';

/// Gelişmiş ürün listesi sayfası
class EnhancedProductsListPage extends ConsumerStatefulWidget {
  const EnhancedProductsListPage({super.key});

  @override
  ConsumerState<EnhancedProductsListPage> createState() =>
      _EnhancedProductsListPageState();
}

class _EnhancedProductsListPageState
    extends ConsumerState<EnhancedProductsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Tümü';
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _sortBy = 'name';
  bool _showOnlyLowStock = false;

  final List<String> _categories = [
    'Tümü',
    'Elektronik',
    'Gıda',
    'Tekstil',
    'İnşaat',
    'Diğer'
  ];
  final List<String> _types = ['Tümü', 'Ürün', 'Hizmet', 'Hammadde', 'Mamul'];
  final List<String> _statuses = [
    'Tümü',
    'Aktif',
    'Pasif',
    'Kritik Stok',
    'Stokta Yok'
  ];
  final List<String> _sortOptions = [
    'name',
    'category',
    'unitPrice',
    'stockQuantity',
    'createdAt'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProducts();
  }

  void _loadProducts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(productOperationsProvider);
      if (operationsState.products.isEmpty && !operationsState.isLoading) {
        ref.read(productOperationsProvider.notifier).loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _navigateToCreate() {
    Navigator.of(context).pushNamed('/product/create');
  }

  void _navigateToDetail(String productId) {
    Navigator.of(context).pushNamed('/products/detail', arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(productOperationsProvider);
    final searchQuery = _searchController.text;

    Theme.of(context);

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Ürünler',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showExportDialog,
            icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Column(
        children: [
          // Arama ve filtre çubuğu
          _buildSearchAndFilterBar(),

          // İstatistik kartları
          _buildStatsCards(operationsState.products),

          // Ürün listesi
          Expanded(child: _buildProductsList(operationsState, searchQuery)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      child: Column(
        children: [
          // Arama çubuğu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ürün ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filtre çipleri
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Kategori', _selectedCategory, _categories,
                    (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Tür', _selectedType, _types, (value) {
                  setState(() {
                    _selectedType = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Durum', _selectedStatus, _statuses, (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Sırala', _getSortDisplayName(_sortBy),
                    _sortOptions.map(_getSortDisplayName).toList(), (value) {
                  setState(() {
                    _sortBy = _getSortKeyFromDisplayName(value);
                  });
                }),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Kritik Stok'),
                  selected: _showOnlyLowStock,
                  onSelected: (selected) {
                    setState(() {
                      _showOnlyLowStock = selected;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue,
      List<String> options, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selectedValue == options.first
            ? AppColors.primary
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: selectedValue == options.first
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _getSortDisplayName(String key) {
    switch (key) {
      case 'name':
        return 'İsim';
      case 'category':
        return 'Kategori';
      case 'unitPrice':
        return 'Fiyat';
      case 'stockQuantity':
        return 'Stok';
      case 'createdAt':
        return 'Tarih';
      default:
        return 'İsim';
    }
  }

  String _getSortKeyFromDisplayName(String displayName) {
    switch (displayName) {
      case 'İsim':
        return 'name';
      case 'Kategori':
        return 'category';
      case 'Fiyat':
        return 'unitPrice';
      case 'Stok':
        return 'stockQuantity';
      case 'Tarih':
        return 'createdAt';
      default:
        return 'name';
    }
  }

  Widget _buildStatsCards(List<Product> products) {
    final activeProducts = products.where((p) => p.isActive).length;
    final lowStockProducts = products.where((p) => p.isLowStock).length;
    final outOfStockProducts =
        products.where((p) => p.totalStockQuantity <= 0).length;
    final totalValue = products.fold<double>(
        0, (sum, p) => sum + (p.salesPrice * p.totalStockQuantity));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Aktif Ürün',
              activeProducts.toString(),
              Icons.inventory,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Kritik Stok',
              lowStockProducts.toString(),
              Icons.warning,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Stokta Yok',
              outOfStockProducts.toString(),
              Icons.error,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Değer',
              CurrencyHelper.formatCurrency(totalValue, 'TRY'),
              Icons.attach_money,
              AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(
      ProductOperationsState operationsState, String searchQuery) {
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
    List<Product> filteredProducts = _applyFilters(products, searchQuery);

    if (filteredProducts.isEmpty && !operationsState.isLoading) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'Ürün Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedCategory != 'Tümü' ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü'
            ? 'Arama kriterlerinize uygun ürün bulunamadı.'
            : 'Henüz ürün kaydı bulunmuyor.\nYeni ürün eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedCategory == 'Tümü' &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Ürün Ekle'),
              )
            : null,
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildProductCard(product),
          );
        },
      ),
    );
  }

  List<Product> _applyFilters(List<Product> products, String searchQuery) {
    List<Product> filtered = products;

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (product.description
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (product.sku?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (product.barcode
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((product) => product.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered.where((product) {
        switch (_selectedStatus) {
          case 'Aktif':
            return product.isActive;
          case 'Pasif':
            return !product.isActive;
          case 'Kritik Stok':
            return product.isLowStock;
          case 'Stokta Yok':
            return product.totalStockQuantity <= 0;
          default:
            return true;
        }
      }).toList();
    }

    // Kritik stok filtresi
    if (_showOnlyLowStock) {
      filtered = filtered.where((product) => product.isLowStock).toList();
    }

    // Sıralama - yeni mutable liste oluştur
    final sortedList = List<Product>.from(filtered);
    sortedList.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'category':
          return (a.category ?? '').compareTo(b.category ?? '');
        case 'unitPrice':
          return b.salesPrice.compareTo(a.salesPrice);
        case 'stockQuantity':
          return b.totalStockQuantity.compareTo(a.totalStockQuantity);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return sortedList;
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.isLowStock;
    final isOutOfStock = product.totalStockQuantity <= 0;
    final stockColor = isOutOfStock
        ? AppColors.error
        : (isLowStock ? AppColors.warning : AppColors.success);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(product.id),
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
                      color: stockColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      _getProductTypeIcon(product.type),
                      color: stockColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Ürün bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (product.sku != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.sku!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (product.category != null)
                          Text(
                            product.category!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primary,
                            ),
                          ),
                        Text(
                          product.type.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Stok durumu
                  _buildStockStatusChip(product),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Fiyat ve stok bilgileri
              Row(
                children: [
                  // Fiyat
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Satış Fiyatı',
                      value: CurrencyHelper.formatCurrency(
                          product.salesPrice, product.salesCurrency),
                      color: AppColors.primary,
                      icon: Icons.attach_money,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Stok
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Stok',
                      value: '${product.totalStockQuantity} adet',
                      color: stockColor,
                      icon: Icons.inventory,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Depo bilgisi
                  if (product.shelfLocation != null)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Depo',
                        value: product.shelfLocation!,
                        color: AppColors.info,
                        icon: Icons.warehouse,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProductTypeIcon(ProductType type) {
    switch (type) {
      case ProductType.stocked:
        return Icons.inventory;
      case ProductType.nonStocked:
        return Icons.room_service;
    }
  }

  Widget _buildStockStatusChip(Product product) {
    Color color;
    String text;

    if (product.totalStockQuantity <= 0) {
      color = AppColors.error;
      text = 'Stokta Yok';
    } else if (product.isLowStock) {
      color = AppColors.warning;
      text = 'Kritik';
    } else {
      color = AppColors.success;
      text = 'Stokta';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gelişmiş Filtreler'),
        content: const Text('Gelişmiş filtre özellikleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dışa Aktar'),
        content:
            const Text('Excel/PDF dışa aktarım özellikleri yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
