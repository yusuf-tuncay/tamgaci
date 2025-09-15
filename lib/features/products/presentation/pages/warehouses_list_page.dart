// ========== WAREHOUSES LIST PAGE ==========
// lib/features/products/presentation/pages/warehouses_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/warehouse.dart';

/// Depolar listesi sayfası
class WarehousesListPage extends ConsumerStatefulWidget {
  const WarehousesListPage({super.key});

  @override
  ConsumerState<WarehousesListPage> createState() => _WarehousesListPageState();
}

class _WarehousesListPageState extends ConsumerState<WarehousesListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _sortBy = 'name';

  final List<String> _types = [
    'Tümü',
    'Ana Depo',
    'Şube Deposu',
    'Geçici Depo',
    'Soğuk Depo',
    'Tehlikeli Madde Deposu'
  ];
  final List<String> _statuses = ['Tümü', 'Aktif', 'Pasif', 'Bakımda', 'Dolu'];
  final List<String> _sortOptions = ['name', 'type', 'capacity', 'createdAt'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
    // Depo oluşturma sayfasına git
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Depo'),
        content: const Text('Depo oluşturma formu yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(String warehouseId) {
    // Depo detay sayfasına git
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Depo Detayı'),
        content: const Text('Depo detay sayfası yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final warehouses = _getMockWarehouses();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Depolar',
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
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama ve filtre çubuğu
          _buildSearchAndFilterBar(),

          // İstatistik kartları
          _buildStatsCards(warehouses),

          // Depo listesi
          Expanded(child: _buildWarehousesList(warehouses, searchQuery)),
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
              hintText: 'Depo ara...',
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
      case 'type':
        return 'Tür';
      case 'capacity':
        return 'Kapasite';
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
      case 'Tür':
        return 'type';
      case 'Kapasite':
        return 'capacity';
      case 'Tarih':
        return 'createdAt';
      default:
        return 'name';
    }
  }

  Widget _buildStatsCards(List<Warehouse> warehouses) {
    final activeWarehouses =
        warehouses.where((w) => w.status == WarehouseStatus.active).length;
    final fullWarehouses =
        warehouses.where((w) => w.capacityUsageRate >= 0.9).length;
    final totalCapacity =
        warehouses.fold<double>(0, (sum, w) => sum + (w.capacity ?? 0));
    final usedCapacity =
        warehouses.fold<double>(0, (sum, w) => sum + (w.usedCapacity ?? 0));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Aktif Depo',
              activeWarehouses.toString(),
              Icons.warehouse,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Dolu Depo',
              fullWarehouses.toString(),
              Icons.warning,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Kapasite',
              '${totalCapacity.toStringAsFixed(0)} m²',
              Icons.straighten,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Kullanım',
              '${(usedCapacity / totalCapacity * 100).toStringAsFixed(0)}%',
              Icons.pie_chart,
              AppColors.info,
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

  Widget _buildWarehousesList(List<Warehouse> warehouses, String searchQuery) {
    List<Warehouse> filteredWarehouses = _applyFilters(warehouses, searchQuery);

    if (filteredWarehouses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.warehouse_outlined,
        title: 'Depo Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü'
            ? 'Arama kriterlerinize uygun depo bulunamadı.'
            : 'Henüz depo kaydı bulunmuyor.\nYeni depo eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Depo Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Depo listesini yenile
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredWarehouses.length,
        itemBuilder: (context, index) {
          final warehouse = filteredWarehouses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWarehouseCard(warehouse),
          );
        },
      ),
    );
  }

  List<Warehouse> _applyFilters(
      List<Warehouse> warehouses, String searchQuery) {
    List<Warehouse> filtered = warehouses;

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((warehouse) {
        return warehouse.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (warehouse.code
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            warehouse.address.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((warehouse) => warehouse.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered
          .where((warehouse) => warehouse.status.displayName == _selectedStatus)
          .toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'type':
          return a.type.displayName.compareTo(b.type.displayName);
        case 'capacity':
          return (b.capacity ?? 0).compareTo(a.capacity ?? 0);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  Widget _buildWarehouseCard(Warehouse warehouse) {
    final capacityColor = _getCapacityColor(warehouse.capacityUsageRate);
    final statusColor = _getStatusColor(warehouse.status);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(warehouse.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Depo adı ve durum
              Row(
                children: [
                  // Depo ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      _getWarehouseTypeIcon(warehouse.type),
                      color: statusColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Depo bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                warehouse.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (warehouse.code != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  warehouse.code!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          warehouse.type.displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          warehouse.address,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Durum
                  _buildStatusChip(warehouse.status),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Kapasite ve özellikler
              Row(
                children: [
                  // Kapasite
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Kapasite',
                      value: warehouse.capacity != null
                          ? '${warehouse.capacity!.toStringAsFixed(0)} m²'
                          : 'Belirtilmemiş',
                      color: capacityColor,
                      icon: Icons.straighten,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Kullanım
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Kullanım',
                      value:
                          '${(warehouse.capacityUsageRate * 100).toStringAsFixed(0)}%',
                      color: capacityColor,
                      icon: Icons.pie_chart,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Özellikler
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Özellikler',
                      value: _getWarehouseFeatures(warehouse),
                      color: AppColors.info,
                      icon: Icons.info,
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

  IconData _getWarehouseTypeIcon(WarehouseType type) {
    switch (type) {
      case WarehouseType.main:
        return Icons.warehouse;
      case WarehouseType.branch:
        return Icons.store;
      case WarehouseType.temporary:
        return Icons.place;
      case WarehouseType.cold:
        return Icons.ac_unit;
      case WarehouseType.hazardous:
        return Icons.warning;
      case WarehouseType.warehouse:
        return Icons.inventory_2;
    }
  }

  Color _getCapacityColor(double usageRate) {
    if (usageRate >= 0.9) return AppColors.error;
    if (usageRate >= 0.7) return AppColors.warning;
    if (usageRate >= 0.5) return AppColors.info;
    return AppColors.success;
  }

  Color _getStatusColor(WarehouseStatus status) {
    switch (status) {
      case WarehouseStatus.active:
        return AppColors.success;
      case WarehouseStatus.inactive:
        return AppColors.textSecondary;
      case WarehouseStatus.maintenance:
        return AppColors.warning;
      case WarehouseStatus.full:
        return AppColors.error;
    }
  }

  Widget _buildStatusChip(WarehouseStatus status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
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

  String _getWarehouseFeatures(Warehouse warehouse) {
    List<String> features = [];
    if (warehouse.hasClimateControl) features.add('İklim');
    if (warehouse.hasSecurity) features.add('Güvenlik');
    return features.isNotEmpty ? features.join(', ') : 'Standart';
  }

  List<Warehouse> _getMockWarehouses() {
    return [
      Warehouse(
        id: '1',
        name: 'Ana Depo',
        code: 'AD-001',
        type: WarehouseType.main,
        status: WarehouseStatus.active,
        address: 'İstanbul, Türkiye',
        capacity: 1000,
        usedCapacity: 750,
        hasClimateControl: true,
        hasSecurity: true,
        managerName: 'Ahmet Yılmaz',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Warehouse(
        id: '2',
        name: 'Şube Deposu',
        code: 'SD-002',
        type: WarehouseType.branch,
        status: WarehouseStatus.active,
        address: 'Ankara, Türkiye',
        capacity: 500,
        usedCapacity: 200,
        hasClimateControl: false,
        hasSecurity: true,
        managerName: 'Mehmet Kaya',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Warehouse(
        id: '3',
        name: 'Soğuk Depo',
        code: 'SD-003',
        type: WarehouseType.cold,
        status: WarehouseStatus.active,
        address: 'İzmir, Türkiye',
        capacity: 300,
        usedCapacity: 280,
        hasClimateControl: true,
        hasSecurity: true,
        managerName: 'Ayşe Demir',
        createdBy: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
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
