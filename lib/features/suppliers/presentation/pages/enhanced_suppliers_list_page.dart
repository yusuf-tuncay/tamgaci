// ========== ENHANCED SUPPLIERS LIST PAGE ==========
// lib/features/suppliers/presentation/pages/enhanced_suppliers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';

/// Gelişmiş tedarikçi listesi sayfası
class EnhancedSuppliersListPage extends ConsumerStatefulWidget {
  const EnhancedSuppliersListPage({super.key});

  @override
  ConsumerState<EnhancedSuppliersListPage> createState() =>
      _EnhancedSuppliersListPageState();
}

class _EnhancedSuppliersListPageState
    extends ConsumerState<EnhancedSuppliersListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _sortBy = 'name';

  final List<String> _categories = [
    'Tümü',
    'Elektronik',
    'Gıda',
    'Tekstil',
    'İnşaat',
    'Diğer'
  ];
  final List<String> _statuses = ['Tümü', 'Aktif', 'Pasif', 'Askıya Alınmış'];
  final List<String> _sortOptions = [
    'name',
    'contactPerson',
    'currentBalance',
    'creditLimit',
    'createdAt'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSuppliers();
  }

  void _loadSuppliers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final operationsState = ref.read(supplierOperationsProvider);
      if (operationsState.suppliers.isEmpty && !operationsState.isLoading) {
        ref.read(supplierOperationsProvider.notifier).loadSuppliers();
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
    Navigator.of(context).pushNamed('/suppliers/create');
  }

  void _navigateToDetail(String supplierId) {
    Navigator.of(context).pushNamed('/suppliers/detail', arguments: supplierId);
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(supplierOperationsProvider);
    final searchQuery = _searchController.text;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Tedarikçiler',
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
          _buildStatsCards(operationsState.suppliers),

          // Tedarikçi listesi
          Expanded(child: _buildSuppliersList(operationsState, searchQuery)),
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
              hintText: 'Tedarikçi ara...',
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
      case 'contactPerson':
        return 'İletişim';
      case 'currentBalance':
        return 'Bakiye';
      case 'creditLimit':
        return 'Kredi Limiti';
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
      case 'İletişim':
        return 'contactPerson';
      case 'Bakiye':
        return 'currentBalance';
      case 'Kredi Limiti':
        return 'creditLimit';
      case 'Tarih':
        return 'createdAt';
      default:
        return 'name';
    }
  }

  Widget _buildStatsCards(List<Supplier> suppliers) {
    final activeSuppliers =
        suppliers.where((s) => s.status == SupplierStatus.active).length;
    final totalBalance =
        suppliers.fold<double>(0, (sum, s) => sum + s.currentBalance);
    final totalCreditLimit =
        suppliers.fold<double>(0, (sum, s) => sum + s.creditLimit);
    final overdueSuppliers =
        suppliers.where((s) => s.currentBalance > s.creditLimit).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Aktif Tedarikçi',
              activeSuppliers.toString(),
              Icons.business,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Bakiye',
              CurrencyHelper.formatCurrency(totalBalance, 'TRY'),
              Icons.account_balance_wallet,
              AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Kredi Limiti',
              CurrencyHelper.formatCurrency(totalCreditLimit, 'TRY'),
              Icons.credit_card,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Riskli',
              overdueSuppliers.toString(),
              Icons.warning,
              AppColors.error,
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

  Widget _buildSuppliersList(
      SupplierOperationsState operationsState, String searchQuery) {
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
              onPressed: _loadSuppliers,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    final suppliers = operationsState.suppliers;
    List<Supplier> filteredSuppliers = _applyFilters(suppliers, searchQuery);

    if (filteredSuppliers.isEmpty && !operationsState.isLoading) {
      return EmptyStateWidget(
        icon: Icons.business_outlined,
        title: 'Tedarikçi Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedCategory != 'Tümü' ||
                _selectedStatus != 'Tümü'
            ? 'Arama kriterlerinize uygun tedarikçi bulunamadı.'
            : 'Henüz tedarikçi kaydı bulunmuyor.\nYeni tedarikçi eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedCategory == 'Tümü' &&
                _selectedStatus == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Tedarikçi Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(supplierOperationsProvider.notifier).loadSuppliers();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredSuppliers.length,
        itemBuilder: (context, index) {
          final supplier = filteredSuppliers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSupplierCard(supplier),
          );
        },
      ),
    );
  }

  List<Supplier> _applyFilters(List<Supplier> suppliers, String searchQuery) {
    List<Supplier> filtered = suppliers;

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((supplier) {
        return supplier.name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (supplier.contactPerson
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (supplier.email
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (supplier.supplierCode
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((supplier) => supplier.category == _selectedCategory)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered.where((supplier) {
        switch (_selectedStatus) {
          case 'Aktif':
            return supplier.status == SupplierStatus.active;
          case 'Pasif':
            return supplier.status == SupplierStatus.inactive;
          case 'Askıya Alınmış':
            return supplier.status == SupplierStatus.suspended;
          default:
            return true;
        }
      }).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'contactPerson':
          return (a.contactPerson ?? '').compareTo(b.contactPerson ?? '');
        case 'currentBalance':
          return b.currentBalance.compareTo(a.currentBalance);
        case 'creditLimit':
          return b.creditLimit.compareTo(a.creditLimit);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return filtered;
  }

  Widget _buildSupplierCard(Supplier supplier) {
    final isActive = supplier.status == SupplierStatus.active;
    final hasOutstandingBalance = supplier.currentBalance > 0;
    final isOverdue = supplier.currentBalance > supplier.creditLimit;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(supplier.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Şirket adı ve durum
              Row(
                children: [
                  // Şirket ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isActive ? AppColors.success : AppColors.error)
                          .withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      Icons.business,
                      color: isActive ? AppColors.success : AppColors.error,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Şirket bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                supplier.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (supplier.supplierCode != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  supplier.supplierCode!,
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
                          supplier.contactPerson ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (supplier.category != null)
                          Text(
                            supplier.category!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceSM),

                  // Durum
                  _buildStatusChip(isActive, isOverdue),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // İletişim bilgileri
              Row(
                children: [
                  const Icon(
                    Icons.email,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      supplier.email ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    supplier.phone ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Finansal bilgiler
              Row(
                children: [
                  // Kredi limiti
                  Expanded(
                    child: _buildFinancialInfo(
                      label: 'Kredi Limiti',
                      value: CurrencyHelper.formatCurrency(
                          supplier.creditLimit, supplier.currency),
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Mevcut bakiye
                  Expanded(
                    child: _buildFinancialInfo(
                      label: 'Mevcut Bakiye',
                      value: CurrencyHelper.formatCurrency(
                          supplier.currentBalance, supplier.currency),
                      color: hasOutstandingBalance
                          ? AppColors.error
                          : AppColors.success,
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

  Widget _buildStatusChip(bool isActive, bool isOverdue) {
    Color color;
    String text;

    if (isOverdue) {
      color = AppColors.error;
      text = 'Riskli';
    } else if (isActive) {
      color = AppColors.success;
      text = 'Aktif';
    } else {
      color = AppColors.textSecondary;
      text = 'Pasif';
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

  Widget _buildFinancialInfo({
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
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
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
