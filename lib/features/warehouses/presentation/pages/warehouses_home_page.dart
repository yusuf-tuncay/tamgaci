import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/warehouse.dart';
import '../providers/warehouse_providers.dart';
import '../widgets/warehouse_card.dart';
import 'create_warehouse_page.dart';
import 'warehouse_detail_page.dart';

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
    final warehousesAsync = ref.watch(warehouseNotifierProvider);
    final statisticsAsync = ref.watch(warehouseStatisticsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const Drawer(
        width: 280,
        child: Center(
          child: Text('Drawer Menu'),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildHeaderSection(),
          _buildStatisticsSection(statisticsAsync),
          _buildFiltersSection(),
          _buildWarehousesSection(warehousesAsync),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 1,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'Depolar',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshWarehouses,
          icon: const Icon(Icons.refresh, color: Colors.black87, size: 24),
          tooltip: 'Yenile',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1), // Indigo-500
                      Color(0xFF8B5CF6), // Violet-500
                      Color(0xFF7C3AED), // Violet-600
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.warehouse_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Depo Yönetimi',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tüm depolarınızı tek yerden yönetin',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
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
                  error: (error, stack) => _buildErrorStatistics(error),
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
            'Toplam Depo',
            '${stats['totalWarehouses'] ?? 0}',
            Icons.warehouse,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Aktif Depo',
            '${stats['activeWarehouses'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pasif Depo',
            '${stats['inactiveWarehouses'] ?? 0}',
            Icons.pause_circle,
            Colors.orange,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatistics() {
    return const SizedBox(
      height: 80,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorStatistics(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'İstatistikler yüklenemedi',
              style: GoogleFonts.poppins(color: Colors.red[600]),
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
                        _buildFilterButton(
                            'Tür', _selectedType?.displayName ?? 'Tümü'),
                        const SizedBox(width: 8),
                        _buildFilterButton(
                            'Durum', _selectedStatus?.displayName ?? 'Tümü'),
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

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Depo ara...',
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
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(String filterType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$filterType Filtresi'),
        content:
            filterType == 'Tür' ? _buildTypeFilter() : _buildStatusFilter(),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (filterType == 'Tür') {
                  _selectedType = null;
                } else {
                  _selectedStatus = null;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Temizle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: WarehouseType.values.map((type) {
        return ListTile(
          title: Text(type.displayName),
          leading: Radio<WarehouseType>(
            value: type,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
              Navigator.pop(context);
            },
          ),
          onTap: () {
            setState(() {
              _selectedType = type;
            });
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: WarehouseStatus.values.map((status) {
        return ListTile(
          title: Text(status.displayName),
          leading: Radio<WarehouseStatus>(
            value: status,
            groupValue: _selectedStatus,
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
              Navigator.pop(context);
            },
          ),
          onTap: () {
            setState(() {
              _selectedStatus = status;
            });
            Navigator.pop(context);
          },
        );
      }).toList(),
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
        if (!warehouse.name.toLowerCase().contains(query) &&
            !warehouse.address.toLowerCase().contains(query) &&
            (warehouse.city?.toLowerCase().contains(query) ?? false)) {
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
