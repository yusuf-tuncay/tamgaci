import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/theme/constants.dart';
import 'create_product_page.dart';
import 'product_detail_page.dart';

/// Ürünler Ana Sayfası
class ProductsHomePage extends ConsumerStatefulWidget {
  const ProductsHomePage({super.key});

  @override
  ConsumerState<ProductsHomePage> createState() => _ProductsHomePageState();
}

class _ProductsHomePageState extends ConsumerState<ProductsHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _categorySearchQuery = ''; // Kategori dialog içinde arama
  ProductType? _selectedType;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final statisticsAsync = ref.watch(productStatisticsProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Ürünler', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: _buildMobileLayout(productsAsync, statisticsAsync),
    );
  }

  Widget _buildMobileLayout(
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildHeaderSection(),
            _buildStatisticsSection(statisticsAsync),
            _buildFiltersSection(),
            _buildProductsSection(productsAsync),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildFloatingActionButton(),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TamgaciConstants.primaryColor,
                      Color(0xFF4C6EF5),
                      TamgaciConstants.primaryColorDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color:
                          TamgaciConstants.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ürünler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ürün bilgilerini yönetin ve takip edin',
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsSection(
      AsyncValue<Map<String, dynamic>> statisticsAsync) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: statisticsAsync.when(
                  data: (stats) => _buildStatisticsCards(stats),
                  loading: () => _buildLoadingStatistics(),
                  error: (error, stack) => _buildErrorStatistics(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Toplam Ürün',
            stats['totalProducts']?.toString() ?? '0',
            Icons.inventory,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Stok Değeri',
            '₺${CurrencyHelper.formatNumber((stats['totalStockValue'] ?? 0).toDouble())}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatistics() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Toplam Ürün', '...', Icons.inventory, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Stok Değeri', '...', Icons.attach_money, Colors.green)),
      ],
    );
  }

  Widget _buildErrorStatistics() {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Toplam Ürün', '0', Icons.inventory, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Stok Değeri', '₺0', Icons.attach_money, Colors.green)),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtreler',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(),
                        ),
                        const SizedBox(width: 12),
                        _buildFilterButton('Kategori', _selectedCategory),
                        const SizedBox(width: 8),
                        _buildFilterButton(
                            'Tür', _selectedType?.displayName ?? 'Tümü'),
                      ],
                    ),
                    if (_showLowStockOnly)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.orange[600], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Sadece düşük stoklu ürünler gösteriliyor',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.orange[600],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showLowStockOnly = false;
                                });
                              },
                              child: Icon(Icons.close,
                                  color: Colors.orange[600], size: 16),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Ürün ara...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    return InkWell(
      onTap: () => _showFilterDialog(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection(AsyncValue<List<Product>> productsAsync) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.all(16),
                child: productsAsync.when(
                  data: (products) {
                    final filteredProducts = _filterProducts(products);

                    if (filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        ...filteredProducts.map((product) {
                          return AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () =>
                                        _navigateToProductDetail(product),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // FAB için alan bırak
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !(product.description?.toLowerCase().contains(query) ?? false) &&
            !(product.productCode?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'Tümü' &&
          product.category != _selectedCategory) {
        return false;
      }

      // Type filter
      if (_selectedType != null && product.type != _selectedType) {
        return false;
      }

      // Low stock filter
      if (_showLowStockOnly && !product.isLowStock) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz ürün yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk ürününüzü ekleyerek başlayın',
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
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Ürünler yüklenemedi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // ignore: unused_result
              ref.refresh(productsStreamProvider);
            },
            child: Text(
              'Tekrar Dene',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'bulk_update',
          onPressed: _navigateToBulkStockUpdate,
          backgroundColor: Colors.orange[600],
          tooltip: 'Toplu Stok Güncelleme',
          child: const Icon(Icons.edit_note, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add_product',
          onPressed: _navigateToCreateProduct,
          backgroundColor: const Color(0xFF6366F1),
          tooltip: 'Yeni Ürün',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  void _navigateToBulkStockUpdate() {
    Navigator.of(context).pushNamed(TamgaciRoutes.bulkStockUpdate);
  }

  void _showFilterDialog(String filterType) {
    // Dialog açılırken arama query'sini sıfırla
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
        content: _buildFilterContent(filterType),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _categorySearchQuery = ''; // Dialog kapatılırken temizle
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

  Widget _buildFilterContent(String filterType) {
    if (filterType == 'Kategori') {
      return _buildCategoryFilter();
    } else if (filterType == 'Tür') {
      return _buildTypeFilter();
    }
    return const SizedBox.shrink();
  }

  Widget _buildCategoryFilter() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        final productsAsync = ref.watch(productsStreamProvider);

        return productsAsync.when(
          data: (products) {
            // Kategorileri topla ve sırala
            final categories = products
                .where((p) => p.category != null && p.category!.isNotEmpty)
                .map((p) => p.category!)
                .toSet()
                .toList()
              ..sort();

            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Arama alanı
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
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
                  }),
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Kategoriler yüklenemedi'),
        );
      },
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Tümü', style: GoogleFonts.poppins()),
          leading: Icon(
            _selectedType == null
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color:
                _selectedType == null ? const Color(0xFF6366F1) : Colors.grey,
          ),
          onTap: () {
            setState(() {
              _selectedType = null;
            });
            Navigator.pop(context);
          },
        ),
        ...ProductType.values.map((type) {
          return ListTile(
            title: Text(type.displayName, style: GoogleFonts.poppins()),
            leading: Icon(
              _selectedType == type
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  _selectedType == type ? const Color(0xFF6366F1) : Colors.grey,
            ),
            onTap: () {
              setState(() {
                _selectedType = type;
              });
              Navigator.pop(context);
            },
          );
        }),
      ],
    );
  }

  void _navigateToCreateProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProductPage(),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }
}
