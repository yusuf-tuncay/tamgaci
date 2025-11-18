// ========== ENHANCED CUSTOMERS LIST PAGE ==========
// lib/features/customers/presentation/pages/enhanced_customers_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/excel_service.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';
import '../../../../core/widgets/disposed_error_suppressor_mixin.dart';
import '../../../payment_collection/presentation/pages/transaction_form_screen.dart';
import '../../../payment_collection/domain/entities/payment_enums.dart';

/// Gelişmiş müşteri listesi sayfası
class EnhancedCustomersListPage extends ConsumerStatefulWidget {
  const EnhancedCustomersListPage({super.key});

  @override
  ConsumerState<EnhancedCustomersListPage> createState() =>
      _EnhancedCustomersListPageState();
}

class _EnhancedCustomersListPageState
    extends ConsumerState<EnhancedCustomersListPage>
    with ConsumerDisposedErrorSuppressorMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _showOnlyWithBalance = false;

  final List<String> _categories = [
    'Tümü',
    'VIP',
    'Normal',
    'Kurumsal',
    'Bireysel'
  ];

  final List<String> _statuses = [
    'Tümü',
    'Aktif',
    'Pasif',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Provider'ı yenile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(customersProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<Customer> _filterAndSortCustomers(List<Customer> customers) {
    var filtered = customers.where((customer) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = customer.name
                .toLowerCase()
                .contains(_searchQuery) ||
            customer.phone?.toLowerCase().contains(_searchQuery) == true ||
            customer.customerCode?.toLowerCase().contains(_searchQuery) == true;
        if (!matchesSearch) return false;
      }

      // Kategori filtresi
      if (_selectedCategory != 'Tümü') {
        if (customer.category1 != _selectedCategory) return false;
      }

      // Bakiye filtresi
      if (_showOnlyWithBalance) {
        if (customer.balance == 0) return false;
      }

      return true;
    }).toList();

    // Sıralama
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'balance':
          comparison = a.balance.compareTo(b.balance);
          break;
        case 'phone':
          comparison = (a.phone ?? '').compareTo(b.phone ?? '');
          break;
        case 'code':
          comparison = (a.customerCode ?? '').compareTo(b.customerCode ?? '');
          break;
        case 'date':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Widget _buildWelcomeCard(bool isDark, List<Customer> customers) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final secondaryTextColor = onPrimary.withValues(alpha: isDark ? 0.9 : 0.95);
    final borderColor = onPrimary.withValues(alpha: 0.12);
    final dividerColor = onPrimary.withValues(alpha: 0.14);
    final activeCustomers = customers.where((c) => c.isActive == true).length;
    final totalBalance = customers.fold<double>(0, (sum, c) => sum + c.balance);
    final totalCreditLimit =
        customers.fold<double>(0, (sum, c) => sum + (c.creditLimit));
    final riskyCustomers = customers.where((c) => c.balance < 0).length;

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
                      'Müşteriler',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: onPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Müşteri bilgilerini yönetin ve takip edin',
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
                      _buildHeaderStatCard('Aktif', activeCustomers.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Bakiye',
                          CurrencyHelper.formatCurrency(totalBalance, 'TRY')),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard(
                          'Kredi',
                          CurrencyHelper.formatCurrency(
                              totalCreditLimit, 'TRY')),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Riskli', riskyCustomers.toString()),
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
                  _buildHeaderStatCard('Aktif', activeCustomers.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Bakiye',
                      CurrencyHelper.formatCurrency(totalBalance, 'TRY')),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Kredi',
                      CurrencyHelper.formatCurrency(totalCreditLimit, 'TRY')),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Riskli', riskyCustomers.toString()),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customersAsync = ref.watch(customersProvider);

    return ResponsiveScaffold(
      appBar: const CustomAppBar(title: 'Müşteriler', showDrawer: true),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildWelcomeCard(isDark, customersAsync.value ?? []),
                const SizedBox(height: 8),
                _buildSearchAndFilters(isDark),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: customersAsync.when(
                    data: (customers) => _buildCustomersList(customers, isDark),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Müşteriler yüklenirken hata oluştu',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton.extended(
                onPressed: () {
                  context.go('/customers/create');
                },
                icon: const Icon(Icons.person_add),
                label: Text(
                  'Yeni Müşteri',
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

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Masaüstünde tek satır, mobilde iki satır
          if (constraints.maxWidth > 768) {
            return Row(
              children: [
                // Arama çubuğu
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Müşteri ara...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Durum filtresi
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
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('İsim')),
                      DropdownMenuItem(value: 'balance', child: Text('Bakiye')),
                      DropdownMenuItem(value: 'phone', child: Text('Telefon')),
                      DropdownMenuItem(value: 'code', child: Text('Kod')),
                      DropdownMenuItem(value: 'date', child: Text('Tarih')),
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
            );
          } else {
            // Mobile - iki satır
            return Column(
              children: [
                // Arama çubuğu - tam genişlik
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Müşteri ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // Filtreler - iki satır
                Row(
                  children: [
                    // İlk satır: Kategori ve Durum
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
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            child: Text(status),
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
                const SizedBox(height: 12),
                // İkinci satır: Sıralama ve Export/Import
                Row(
                  children: [
                    // Sıralama
                    Flexible(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortBy,
                        decoration: InputDecoration(
                          labelText: 'Sırala',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('İsim')),
                          DropdownMenuItem(
                              value: 'balance', child: Text('Bakiye')),
                          DropdownMenuItem(
                              value: 'phone', child: Text('Telefon')),
                          DropdownMenuItem(value: 'code', child: Text('Kod')),
                          DropdownMenuItem(value: 'date', child: Text('Tarih')),
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
                        _sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      tooltip: _sortAscending ? 'Artan' : 'Azalan',
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
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
                            backgroundColor:
                                Colors.green.withValues(alpha: 0.1),
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
                            backgroundColor:
                                Colors.orange.withValues(alpha: 0.1),
                            foregroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCustomersList(List<Customer> customers, bool isDark) {
    final filteredCustomers = _filterAndSortCustomers(customers);

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ||
                      _selectedCategory != 'Tümü' ||
                      _showOnlyWithBalance
                  ? 'Arama kriterlerinize uygun müşteri bulunamadı'
                  : 'Henüz müşteri eklenmemiş',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            if (_searchQuery.isNotEmpty ||
                _selectedCategory != 'Tümü' ||
                _showOnlyWithBalance) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedCategory = 'Tümü';
                    _showOnlyWithBalance = false;
                  });
                },
                child: const Text('Filtreleri Temizle'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(customersProvider);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Masaüstü için tablo görünümü
          if (TamgaciConstants.isDesktop(context) ||
              TamgaciConstants.isWideDesktop(context)) {
            return _buildDesktopTable(filteredCustomers, isDark);
          }

          // Mobil ve tablet için kart görünümü
          return _buildMobileCards(filteredCustomers, isDark);
        },
      ),
    );
  }

  /// Masaüstü için tablo görünümü
  Widget _buildDesktopTable(List<Customer> customers, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildTableHeader('Müşteri Adı')),
                  Expanded(flex: 1, child: _buildTableHeader('Kod')),
                  Expanded(flex: 1, child: _buildTableHeader('Telefon')),
                  Expanded(flex: 1, child: _buildTableHeader('Bakiye')),
                  Expanded(flex: 1, child: _buildTableHeader('Durum')),
                  Expanded(flex: 1, child: _buildTableHeader('İşlemler')),
                ],
              ),
            ),
            // Tablo satırları
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey[700] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _buildDesktopTableRow(customer, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Mobil ve tablet için kart görünümü
  Widget _buildMobileCards(List<Customer> customers, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(customer, isDark);
      },
    );
  }

  /// Tablo başlığı widget'ı
  Widget _buildTableHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimary,
      ),
    );
  }

  /// Masaüstü tablo satırı
  Widget _buildDesktopTableRow(Customer customer, bool isDark) {
    final balanceColor = customer.balance > 0
        ? Colors.green
        : customer.balance < 0
            ? Colors.red
            : Colors.grey;

    return InkWell(
      onTap: () {
        context.go('/customers/detail/${customer.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Müşteri Adı
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: customer.isActive == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    child: Icon(
                      customer.customerType.toString().contains('company')
                          ? Icons.business
                          : Icons.person,
                      size: 16,
                      color: customer.isActive == true
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (customer.email != null &&
                            customer.email!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            customer.email!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        // Müşteri kategorileri etiketleri
                        Wrap(
                          spacing: 4,
                          runSpacing: 2,
                          children: [
                            if (customer.category1 != null &&
                                customer.category1!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  customer.category1!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            if (customer.category2 != null &&
                                customer.category2!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.purple.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  customer.category2!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple[700],
                                  ),
                                ),
                              ),
                            // Şube ikonu
                            if (customer.branches != null &&
                                customer.branches!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.business,
                                      size: 10,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${customer.branches!.length} Şube',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
                customer.customerCode ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Telefon
            Expanded(
              flex: 1,
              child: Text(
                customer.phone ?? '-',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Bakiye
            Expanded(
              flex: 1,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    CurrencyHelper.formatCurrency(customer.balance, 'TRY'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: balanceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                    color: customer.isActive == true
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.isActive == true ? 'Aktif' : 'Pasif',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: customer.isActive == true
                          ? Colors.green
                          : Colors.grey,
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
                    onPressed: () {
                      context.go('/customers/detail/${customer.id}');
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    tooltip: 'Detayları Görüntüle',
                  ),
                  IconButton(
                    onPressed: () {
                      context.go('/customers/edit/${customer.id}');
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

  Widget _buildCustomerCard(Customer customer, bool isDark) {
    final balanceColor = customer.balance > 0
        ? Colors.green
        : customer.balance < 0
            ? Colors.red
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.go('/customers/detail/${customer.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst satır - İsim ve bakiye
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey[800],
                          ),
                        ),
                        if (customer.customerCode != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Kod: ${customer.customerCode}',
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
                      CurrencyHelper.formatCurrency(customer.balance, 'TRY'),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: balanceColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (customer.branches != null &&
                      customer.branches!.isNotEmpty)
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_tree_rounded,
                              size: 16,
                              color: isDark ? Colors.blueGrey : Colors.blue),
                          const SizedBox(width: 4),
                          Text('${customer.branches!.length}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.blueGrey : Colors.blue)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Orta satır - Telefon ve kategori
              Row(
                children: [
                  if (customer.phone != null) ...[
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.phone!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (customer.category1 != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        customer.category1!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (customer.email != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      customer.email!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Alt satır - Tarih ve hızlı işlemler
              Row(
                children: [
                  Text(
                    'Kayıt: ${DateFormat('dd.MM.yyyy').format(customer.createdAt)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  // Hızlı işlem butonları
                  IconButton(
                    onPressed: () {
                      _showQuickActions(customer);
                    },
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Hızlı İşlemler',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(Customer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hızlı İşlemler - ${customer.name}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(
                          '/sales/create?customerId=${customer.id}&customerName=${Uri.encodeComponent(customer.name)}');
                    },
                    icon: const Icon(Icons.sell),
                    label: const Text('Satış Yap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToPaymentForm(customer);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Tahsilat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Hesap ekstresi
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Hesap Ekstresi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/customers/edit/${customer.id}');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _exportToCSV() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToCSV(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToPDF() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToPDF(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToExcel() async {
    try {
      final customersAsync = ref.read(customersProvider);
      final customers = customersAsync.when(
        data: (data) => data,
        loading: () => throw Exception('Müşteriler yükleniyor'),
        error: (error, stack) =>
            throw Exception('Müşteriler yüklenemedi: $error'),
      );

      if (customers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dışa aktarılacak müşteri bulunamadı'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToExcel(customers);

      // Loading'i kapat
      Navigator.of(context).pop();

      if (fileName != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileName dosyası başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Paylaş',
              textColor: Colors.white,
              onPressed: () => _shareFile(fileName),
            ),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel dışa aktarım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareFile(String fileName) async {
    try {
      // Dosya paylaşım implementasyonu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileName dosyası paylaşım için hazır'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dosya paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : null,
        title: Text(
          'Dosya İçe Aktar',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        content: Text(
          'Excel/CSV dosya içe aktarım özellikleri yakında eklenecek.',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Tahsilat form dialog'unu aç
  void _navigateToPaymentForm(Customer customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? Colors.grey[850] : null,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width *
                  0.6 // Masaüstü için %60 genişlik
              : double.infinity, // Mobil için tam genişlik
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: TransactionFormScreen(
              direction: PaymentDirection.incoming,
              customerId: customer.id,
            ),
          ),
        ),
      ),
    ).then((_) {
      // Form kapatıldığında müşteri listesini yenile
      ref.invalidate(customersProvider);
    });
  }
}
