// ========== ENHANCED SUPPLIERS LIST PAGE ==========
// lib/features/suppliers/presentation/pages/enhanced_suppliers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_enums.dart';

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

  Widget _buildWelcomeCard(bool isDark) {
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
          Text(
            'Tedarikçiler',
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
            'Tedarikçi bilgilerini yönetin ve takip edin',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(supplierOperationsProvider);
    final searchQuery = _searchController.text;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Tedarikçiler',
        showDrawer: true,
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildWelcomeCard(isDark),
                const SizedBox(height: 16),
                // Arama ve filtre çubuğu
                _buildSearchAndFilterBar(),
                const SizedBox(height: 16),
                // İstatistik kartları
                _buildStatsCards(operationsState.suppliers),
                const SizedBox(height: 16),
                // Tedarikçi listesi
                SizedBox(
                  height: MediaQuery.of(context).size.height - 400,
                  child: _buildSuppliersList(operationsState, searchQuery),
                ),
              ],
            ),
          ),
          // Floating Action Button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.business),
                label: Text(
                  'Yeni Tedarikçi',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                backgroundColor: TamgaciConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
      ),
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
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[700] : Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          // Filtreler - Dikey layout (overflow önleme)
          Column(
            children: [
              // İlk satır - Kategori ve Durum
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Durum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // İkinci satır - Sıralama
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _sortBy,
                      decoration: InputDecoration(
                        labelText: 'Sırala',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'name',
                            child:
                                Text('İsim', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'contactPerson',
                            child: Text('İletişim',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'currentBalance',
                            child:
                                Text('Bakiye', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'creditLimit',
                            child: Text('Kredi Limiti',
                                style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(
                            value: 'createdAt',
                            child:
                                Text('Tarih', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SizedBox(width: 1), // Boş alan
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ek filtreler ve aksiyonlar - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                // Küçük ekranlar için dikey layout
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _showExportDialog,
                          icon: const Icon(Icons.table_chart),
                          tooltip: 'Excel',
                        ),
                        IconButton(
                          onPressed: _showExportDialog,
                          icon: const Icon(Icons.description),
                          tooltip: 'CSV',
                        ),
                        IconButton(
                          onPressed: _showExportDialog,
                          icon: const Icon(Icons.picture_as_pdf),
                          tooltip: 'PDF',
                        ),
                        IconButton(
                          onPressed: _showFilterDialog,
                          icon: const Icon(Icons.filter_list),
                          tooltip: 'Filtre',
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Büyük ekranlar için yatay layout
                return Row(
                  children: [
                    // Excel dışa aktarım
                    IconButton(
                      onPressed: _showExportDialog,
                      icon: const Icon(Icons.table_chart),
                      tooltip: 'Excel\'e Aktar',
                    ),
                    // CSV dışa aktarım
                    IconButton(
                      onPressed: _showExportDialog,
                      icon: const Icon(Icons.description),
                      tooltip: 'CSV\'ye Aktar',
                    ),
                    // PDF dışa aktarım
                    IconButton(
                      onPressed: _showExportDialog,
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'PDF\'ye Aktar',
                    ),
                    // Filtre
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Gelişmiş Filtreler',
                    ),
                    const Spacer(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
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
        actionButton: null,
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
          .where((supplier) => supplier.category1 == _selectedCategory)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = supplier.status == SupplierStatus.active;
    final hasOutstandingBalance = supplier.currentBalance > 0;

    // Bakiye rengi belirleme
    Color balanceColor;
    if (supplier.currentBalance == 0) {
      balanceColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    } else if (supplier.currentBalance > 0) {
      balanceColor = Colors.green;
    } else {
      balanceColor = Colors.red;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(supplier.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır - Şirket adı ve bakiye
              Row(
                children: [
                  // Şirket ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business,
                      color: isActive ? Colors.green : Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Şirket bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        if (supplier.supplierCode != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Kod: ${supplier.supplierCode}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bakiye
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: balanceColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      CurrencyHelper.formatCurrency(
                          supplier.currentBalance, 'TRY'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: balanceColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Orta satır - Telefon ve kategori
              Row(
                children: [
                  if (supplier.phone != null) ...[
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      supplier.phone!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (supplier.category1 != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.blueGrey : Colors.blue)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? Colors.blueGrey : Colors.blue)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        supplier.category1!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.blueGrey : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Alt satır - İletişim kişisi ve durum
              Row(
                children: [
                  if (supplier.contactPerson != null) ...[
                    Icon(
                      Icons.person,
                      size: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        supplier.contactPerson!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Durum chip'i
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isActive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isActive ? Colors.green : Colors.red)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isActive ? 'Aktif' : 'Pasif',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

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
