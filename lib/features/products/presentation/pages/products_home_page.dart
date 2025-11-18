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
import 'package:go_router/go_router.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/disposed_error_suppressor_mixin.dart';

/// Ürünler Ana Sayfası
class ProductsHomePage extends ConsumerStatefulWidget {
  const ProductsHomePage({super.key});

  @override
  ConsumerState<ProductsHomePage> createState() => _ProductsHomePageState();
}

class _ProductsHomePageState extends ConsumerState<ProductsHomePage>
    with TickerProviderStateMixin, ConsumerDisposedErrorSuppressorMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _categorySearchQuery = ''; // Kategori dialog içinde arama
  ProductType? _selectedType;
  bool _showLowStockOnly = false;
  String _sortBy = 'name';
  bool _sortAscending = true;

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
    // Widget dispose edildiyse boş widget döndür
    if (!mounted) return const SizedBox.shrink();

    final productsAsync = ref.watch(productsStreamProvider);
    final statisticsAsync = ref.watch(productStatisticsProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Ürünler', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Masaüstü için kompakt layout
          if (TamgaciConstants.isDesktop(context) ||
              TamgaciConstants.isWideDesktop(context)) {
            return _buildDesktopLayout(productsAsync, statisticsAsync);
          }

          // Mobil ve tablet için normal layout
          return _buildMobileLayout(productsAsync, statisticsAsync);
        },
      ),
    );
  }

  Widget _buildWelcomeCard(List<Product> products) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerTextColor = theme.colorScheme.onPrimary;
    final secondaryTextColor =
        headerTextColor.withValues(alpha: isDark ? 0.9 : 0.95);
    final dividerColor = headerTextColor.withValues(alpha: 0.14);
    final borderColor = headerTextColor.withValues(alpha: 0.12);
    final totalProducts = products.length;
    final activeProducts = products.where((p) => p.isActive == true).length;
    final categories = products.map((p) => p.category).toSet().length;
    final lowStockProducts =
        products.where((p) => p.stockQuantity <= 10).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: TamgaciConstants.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve açıklama
          Row(
            children: [
              Expanded(
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
                        color: headerTextColor,
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
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Özet istatistikler - sadece masaüstünde göster
              if (MediaQuery.of(context).size.width > 768)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildHeaderStatCard('Toplam', totalProducts.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Aktif', activeProducts.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Kategori', categories.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard(
                          'Düşük Stok', lowStockProducts.toString()),
                    ],
                  ),
                ),
            ],
          ),
          // Mobil için istatistikler
          if (MediaQuery.of(context).size.width <= 768) ...[
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildHeaderStatCard('Toplam', totalProducts.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Aktif', activeProducts.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Kategori', categories.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard(
                      'Düşük Stok', lowStockProducts.toString()),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: dividerColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün: ${DateFormat('dd MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now())}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Header içindeki istatistik kartı - banner timer gibi
  Widget _buildHeaderStatCard(String title, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onPrimary = theme.colorScheme.onPrimary;
    final backgroundColor = onPrimary.withValues(alpha: isDark ? 0.16 : 0.22);
    final labelColor = onPrimary.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Masaüstü için kompakt layout
  Widget _buildDesktopLayout(
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              // Header card
              _buildWelcomeCard(productsAsync.value ?? []),
              const SizedBox(height: 8),
              // Arama ve filtreler
              _buildSearchAndFilters(),
              // Ürün listesi - tam yükseklik
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: _buildDesktopProductsList(productsAsync),
              ),
            ],
          ),
        ),
        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildFloatingActionButton(),
        ),
      ],
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
              child: _buildWelcomeCard(
                  []), // Boş liste, mobilde istatistikler ayrı gösterilecek
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
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
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                child: Builder(builder: (context) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filtreler',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Arama çubuğu - tam genişlik
                        _buildSearchField(),
                        const SizedBox(height: 12),
                        // Filtreler - iki satır
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterButton(
                                  'Kategori', _selectedCategory),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterButton(
                                  'Tür', _selectedType?.displayName ?? 'Tümü'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // İkinci satır: Sıralama ve Export/Import
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterButton('Sırala', 'İsim'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _sortAscending = !_sortAscending;
                                });
                              },
                              icon: Icon(
                                _sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                              ),
                              tooltip: _sortAscending ? 'Artan' : 'Azalan',
                            ),
                            const SizedBox(width: 8),
                            // Export/Import butonları
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _exportToExcel,
                                  icon: const Icon(Icons.table_chart),
                                  tooltip: 'Excel\'e Aktar',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.withValues(alpha: 0.1),
                                    foregroundColor: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: _exportToCSV,
                                  icon: const Icon(Icons.description),
                                  tooltip: 'CSV\'ye Aktar',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.blue.withValues(alpha: 0.1),
                                    foregroundColor: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: _exportToPDF,
                                  icon: const Icon(Icons.picture_as_pdf),
                                  tooltip: 'PDF\'ye Aktar',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.red.withValues(alpha: 0.1),
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: _showImportDialog,
                                  icon: const Icon(Icons.upload_file),
                                  tooltip: 'Dosya İçe Aktar',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.orange.withValues(alpha: 0.1),
                                    foregroundColor: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
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
                  );
                })),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => _showFilterDialog(label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  /// Arama ve filtreler - masaüstünde tek satır
  Widget _buildSearchAndFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Arama çubuğu
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                hintStyle: GoogleFonts.poppins(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Kategori filtresi
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'Tümü', child: Text('Tümü')),
                DropdownMenuItem(
                    value: 'Elektronik', child: Text('Elektronik')),
                DropdownMenuItem(value: 'Gıda', child: Text('Gıda')),
                DropdownMenuItem(value: 'Tekstil', child: Text('Tekstil')),
                DropdownMenuItem(value: 'İnşaat', child: Text('İnşaat')),
                DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Tip filtresi
          Expanded(
            child: DropdownButtonFormField<ProductType?>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: 'Tip',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tümü')),
                DropdownMenuItem(
                    value: ProductType.stocked, child: Text('Ürün')),
                DropdownMenuItem(
                    value: ProductType.service, child: Text('Hizmet')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Sıralama
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _sortBy,
              decoration: InputDecoration(
                labelText: 'Sırala',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('İsim')),
                DropdownMenuItem(value: 'category', child: Text('Kategori')),
                DropdownMenuItem(value: 'stockQuantity', child: Text('Stok')),
                DropdownMenuItem(value: 'price', child: Text('Fiyat')),
                DropdownMenuItem(value: 'createdAt', child: Text('Tarih')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Sıralama yönü
          IconButton(
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: _sortAscending ? 'Artan' : 'Azalan',
          ),
          const SizedBox(width: 8),
          // Excel, CSV, PDF, Import butonları
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Excel Export
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.table_chart),
                tooltip: 'Excel\'e Aktar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  foregroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 4),
              // CSV Export
              IconButton(
                onPressed: _exportToCSV,
                icon: const Icon(Icons.description),
                tooltip: 'CSV\'ye Aktar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  foregroundColor: Colors.blue,
                ),
              ),
              const SizedBox(width: 4),
              // PDF Export
              IconButton(
                onPressed: _exportToPDF,
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'PDF\'ye Aktar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                ),
              ),
              const SizedBox(width: 4),
              // Import
              IconButton(
                onPressed: _showImportDialog,
                icon: const Icon(Icons.upload_file),
                tooltip: 'Dosya İçe Aktar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  foregroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Excel export
  void _exportToExcel() {
    // Excel export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Excel export başlatıldı')),
    );
  }

  /// CSV export
  void _exportToCSV() {
    // CSV export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export başlatıldı')),
    );
  }

  /// PDF export
  void _exportToPDF() {
    // PDF export logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF export başlatıldı')),
    );
  }

  /// Import dialog göster
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya İçe Aktar'),
        content:
            const Text('Ürünler Excel veya CSV dosyasından içe aktarılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Kompakt istatistikler

  /// Masaüstü ürün listesi
  Widget _buildDesktopProductsList(AsyncValue<List<Product>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final filteredProducts = _filterProducts(products);

        if (filteredProducts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildDesktopProductsTable(filteredProducts);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// Masaüstü ürün tablosu
  Widget _buildDesktopProductsTable(List<Product> products) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Tablo başlığı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildTableHeader('Ürün Adı')),
                  Expanded(flex: 1, child: _buildTableHeader('Kod')),
                  Expanded(flex: 1, child: _buildTableHeader('Kategori')),
                  Expanded(flex: 1, child: _buildTableHeader('Stok')),
                  Expanded(flex: 1, child: _buildTableHeader('Fiyat')),
                  Expanded(flex: 1, child: _buildTableHeader('Durum')),
                  Expanded(flex: 1, child: _buildTableHeader('İşlemler')),
                ],
              ),
            ),
            // Tablo satırları
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildDesktopProductRow(product, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Tablo başlığı widget'ı
  Widget _buildTableHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.grey[800],
      ),
    );
  }

  /// Masaüstü ürün satırı
  Widget _buildDesktopProductRow(Product product, bool isDark) {
    final stockColor = product.stockQuantity <= 0
        ? Colors.red
        : product.stockQuantity <= 10
            ? Colors.orange
            : Colors.green;

    return InkWell(
      onTap: () => _navigateToProductDetail(product),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ürün Adı
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: product.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Icon(
                      product.type == ProductType.service
                          ? Icons.room_service
                          : Icons.inventory_2,
                      size: 16,
                      color: product.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.description != null &&
                            product.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Kod
            Expanded(
              flex: 1,
              child: Text(
                product.productCode ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Kategori
            Expanded(
              flex: 1,
              child: Text(
                product.category ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Stok
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.stockQuantity.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: stockColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Fiyat
            Expanded(
              flex: 1,
              child: Text(
                CurrencyHelper.formatCurrency(product.salesPrice, 'TRY'),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Durum
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.isActive ? 'Aktif' : 'Pasif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: product.isActive ? Colors.green : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // İşlemler
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _navigateToProductDetail(product),
                    icon: const Icon(Icons.visibility, size: 18),
                    tooltip: 'Detayları Görüntüle',
                  ),
                  IconButton(
                    onPressed: () {
                      context.go('/products/edit/${product.id}');
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    tooltip: 'Düzenle',
                  ),
                ],
              ),
            ),
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
    final filtered = products.where((product) {
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

    // Sıralama
    filtered.sort((a, b) {
      int comparison = a.name.compareTo(b.name);
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
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
    context.go('/products/bulk-stock-update');
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
    context.go('/products/create');
  }

  void _navigateToProductDetail(Product product) {
    context.go('/products/detail/${product.id}');
  }
}
