import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/warehouse.dart';
import '../providers/warehouse_providers.dart';
import '../widgets/warehouse_card.dart';
import '../../data/services/warehouse_initialization_service.dart';
import 'create_warehouse_page.dart';
import 'warehouse_detail_page.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../core/theme/constants.dart';

/// Depolar Ana Sayfası
class WarehousesHomePage extends ConsumerStatefulWidget {
  const WarehousesHomePage({super.key});

  @override
  ConsumerState<WarehousesHomePage> createState() => _WarehousesHomePageState();
}

class _WarehousesHomePageState extends ConsumerState<WarehousesHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _searchQuery = '';
  WarehouseType? _selectedType;
  WarehouseStatus? _selectedStatus;
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

    // Varsayılan depo oluştur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaultWarehouse();
    });
  }

  Future<void> _initializeDefaultWarehouse() async {
    try {
      final warehouseService = WarehouseInitializationService();
      await warehouseService.createDefaultWarehouseForUser();
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehousesAsync = ref.watch(warehouseNotifierProvider);
    final statisticsAsync = ref.watch(warehouseStatisticsProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Depolar', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: _buildMobileLayout(warehousesAsync, statisticsAsync),
    );
  }

  Widget _buildMobileLayout(
    AsyncValue<List<Warehouse>> warehousesAsync,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildHeaderSection(),
            _buildFiltersSection(),
            _buildWarehousesSection(warehousesAsync),
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

  Widget _buildWelcomeCard(List<Warehouse> warehouses) {
    final totalWarehouses = warehouses.length;
    final activeWarehouses =
        warehouses.where((w) => w.status == WarehouseStatus.active).length;
    final totalCapacity =
        warehouses.fold<int>(0, (sum, w) => sum + (w.capacity ?? 0));
    final usedCapacity = warehouses.fold<int>(0,
        (sum, w) => sum + (w.capacity ?? 0) ~/ 2); // Placeholder: yarısı dolu

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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      'Depolar',
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
                      'Depo bilgilerini yönetin ve takip edin',
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Özet istatistikler - yan yana
              Row(
                children: [
                  _buildHeaderStatCard('Toplam', totalWarehouses.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Aktif', activeWarehouses.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Kapasite', totalCapacity.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Dolu', usedCapacity.toString()),
                ],
              ),
            ],
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
    );
  }

  /// Header içindeki istatistik kartı - banner timer gibi
  Widget _buildHeaderStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
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
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
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
                        decoration: InputDecoration(
                          hintText: 'Depo ara...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tür filtresi
                    Expanded(
                      child: DropdownButtonFormField<WarehouseType?>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tür',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tümü')),
                          DropdownMenuItem(
                              value: WarehouseType.main, child: Text('Ana')),
                          DropdownMenuItem(
                              value: WarehouseType.branch, child: Text('Şube')),
                          DropdownMenuItem(
                              value: WarehouseType.retail,
                              child: Text('Perakende')),
                          DropdownMenuItem(
                              value: WarehouseType.wholesale,
                              child: Text('Toptan')),
                          DropdownMenuItem(
                              value: WarehouseType.cold, child: Text('Soğuk')),
                          DropdownMenuItem(
                              value: WarehouseType.bonded,
                              child: Text('Gümrük')),
                          DropdownMenuItem(
                              value: WarehouseType.virtual,
                              child: Text('Sanal')),
                          DropdownMenuItem(
                              value: WarehouseType.other, child: Text('Diğer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Durum filtresi
                    Expanded(
                      child: DropdownButtonFormField<WarehouseStatus?>(
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Durum',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tümü')),
                          DropdownMenuItem(
                              value: WarehouseStatus.active,
                              child: Text('Aktif')),
                          DropdownMenuItem(
                              value: WarehouseStatus.inactive,
                              child: Text('Pasif')),
                          DropdownMenuItem(
                              value: WarehouseStatus.maintenance,
                              child: Text('Bakımda')),
                          DropdownMenuItem(
                              value: WarehouseStatus.closed,
                              child: Text('Kapalı')),
                          DropdownMenuItem(
                              value: WarehouseStatus.suspended,
                              child: Text('Askıya Alınmış')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
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
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
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
                          onPressed: _showExportDialog,
                          icon: const Icon(Icons.table_chart),
                          tooltip: 'Excel\'e Aktar',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.green.withValues(alpha: 0.1),
                            foregroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // CSV Export
                        IconButton(
                          onPressed: _showExportDialog,
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
                          onPressed: _showExportDialog,
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
                            backgroundColor:
                                Colors.orange.withValues(alpha: 0.1),
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ],
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

  /// Export dialog göster
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dışa Aktar'),
        content: const Text(
            'Depolar Excel, CSV veya PDF formatında dışa aktarılacak.'),
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

  /// Import dialog göster
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İçe Aktar'),
        content:
            const Text('Excel veya CSV dosyasından depolar içe aktarılacak.'),
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

  Widget _buildWarehousesSection(AsyncValue<List<Warehouse>> warehousesAsync) {
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
                child: warehousesAsync.when(
                  data: (warehouses) {
                    final filteredWarehouses = _filterWarehouses(warehouses);

                    if (filteredWarehouses.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: filteredWarehouses.map((warehouse) {
                        return AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: WarehouseCard(
                                  warehouse: warehouse,
                                  onTap: () =>
                                      _navigateToWarehouseDetail(warehouse),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
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

  List<Warehouse> _filterWarehouses(List<Warehouse> warehouses) {
    return warehouses.where((warehouse) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = warehouse.name.toLowerCase().contains(query);
        final addressMatch = warehouse.address.toLowerCase().contains(query);
        final cityMatch =
            warehouse.city?.toLowerCase().contains(query) ?? false;

        if (!nameMatch && !addressMatch && !cityMatch) {
          return false;
        }
      }

      // Type filter
      if (_selectedType != null && warehouse.type != _selectedType) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && warehouse.status != _selectedStatus) {
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
          Icon(
            Icons.warehouse_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz depo yok',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk deponuzu oluşturmak için + butonuna tıklayın',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Depolar yüklenemedi',
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
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshWarehouses,
            icon: const Icon(Icons.refresh),
            label: Text(
              'Tekrar Dene',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateWarehouse,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text(
        'Depo Ekle',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _refreshWarehouses() {
    ref.read(warehouseNotifierProvider.notifier).refresh();
    ref.invalidate(warehouseStatisticsProvider);
  }

  void _navigateToWarehouseDetail(Warehouse warehouse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WarehouseDetailPage(warehouse: warehouse),
      ),
    );
  }

  void _navigateToCreateWarehouse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateWarehousePage(),
      ),
    );
  }
}
