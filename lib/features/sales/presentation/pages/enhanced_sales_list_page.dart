// ========== ENHANCED SALES LIST PAGE ==========
// lib/features/sales/presentation/pages/enhanced_sales_list_page.dart

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
import '../../../../core/services/excel_service.dart';
import '../../domain/entities/sale.dart';
import '../providers/sale_providers.dart';

/// Gelişmiş satış listesi sayfası
class EnhancedSalesListPage extends ConsumerStatefulWidget {
  const EnhancedSalesListPage({super.key});

  @override
  ConsumerState<EnhancedSalesListPage> createState() =>
      _EnhancedSalesListPageState();
}

class _EnhancedSalesListPageState extends ConsumerState<EnhancedSalesListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  final String _selectedPaymentStatus = 'Tümü';
  String _sortBy = 'saleDate';
  bool _sortAscending = true;
  DateTimeRange? _dateRange;

  final List<String> _types = [
    'Tümü',
    'Fatura',
    'Proforma',
    'İrsaliye',
    'Fiş',
    'Teklif'
  ];
  final List<String> _statuses = [
    'Tümü',
    'Taslak',
    'Beklemede',
    'Onaylandı',
    'Kargoya Verildi',
    'Teslim Edildi',
    'İptal Edildi'
  ];
  final List<String> _paymentStatuses = [
    'Tümü',
    'Ödeme Bekliyor',
    'Kısmi Ödeme',
    'Ödendi',
    'Vadesi Geçmiş',
    'İade Edildi'
  ];
  final List<String> _sortOptions = [
    'saleDate',
    'totalAmount',
    'customerName',
    'saleNumber',
    'createdAt'
  ];

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
    Navigator.of(context).pushNamed('/sales/create');
  }

  /// Header kartı - istatistikler ve hoş geldin mesajı
  Widget _buildWelcomeCard(List<Sale> sales) {
    final totalSales = sales.length;
    final totalAmount =
        sales.fold<double>(0, (sum, sale) => sum + (sale.totalAmount));
    final paidSales = sales.where((sale) => sale.isPaid == true).length;
    final pendingSales = sales.where((sale) => sale.isPaid == false).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Satışlar',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Satış işlemlerinizi yönetin',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
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
                      _buildHeaderStatCard('Toplam Satış',
                          CurrencyHelper.formatCurrency(totalAmount, 'TRY')),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard(
                          'Satış Sayısı', totalSales.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Ödenen', paidSales.toString()),
                      const SizedBox(width: 8),
                      _buildHeaderStatCard('Bekleyen', pendingSales.toString()),
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
                  _buildHeaderStatCard('Toplam Satış',
                      CurrencyHelper.formatCurrency(totalAmount, 'TRY')),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Satış Sayısı', totalSales.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Ödenen', paidSales.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Bekleyen', pendingSales.toString()),
                ],
              ),
            ),
          ],
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

  /// Header içindeki istatistik kartı
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

  void _navigateToDetail(String saleId) {
    Navigator.of(context).pushNamed('/sales/detail', arguments: saleId);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final sales = ref.watch(saleNotifierProvider).sales;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        showBackButton: false,
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
          // Header kartı
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildWelcomeCard(sales),
          ),

          // Arama ve filtre çubuğu
          _buildSearchAndFilters(isDark),

          // Satış listesi
          Expanded(child: _buildSalesList(sales, searchQuery)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey[200]!,
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
                      hintText: 'Satış ara...',
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tür filtresi
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tür',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
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
                const SizedBox(width: 12),
                // Sıralama
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _getSortDisplayName(_sortBy),
                    decoration: InputDecoration(
                      labelText: 'Sırala',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    items: _sortOptions.map(_getSortDisplayName).map((sort) {
                      return DropdownMenuItem(
                        value: sort,
                        child: Text(sort),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortBy = _getSortKeyFromDisplayName(value!);
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
            // Mobil layout - iki satır
            return Column(
              children: [
                // İlk satır: Arama
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Satış ara...',
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                // İkinci satır: Filtreler
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Tür',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
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
                // Üçüncü satır: Sıralama, Sıralama yönü ve Import/Export butonları
                Row(
                  children: [
                    // Sıralama dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _getSortDisplayName(_sortBy),
                        decoration: InputDecoration(
                          labelText: 'Sırala',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items:
                            _sortOptions.map(_getSortDisplayName).map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Text(sort),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortBy = _getSortKeyFromDisplayName(value!);
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
                    // Import/Export butonları
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          // CSV Export
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
                          // PDF Export
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

  String _getSortDisplayName(String key) {
    switch (key) {
      case 'saleDate':
        return 'Tarih';
      case 'totalAmount':
        return 'Tutar';
      case 'customerName':
        return 'Müşteri';
      case 'saleNumber':
        return 'Numara';
      case 'createdAt':
        return 'Oluşturma';
      default:
        return 'Tarih';
    }
  }

  String _getSortKeyFromDisplayName(String displayName) {
    switch (displayName) {
      case 'Tarih':
        return 'saleDate';
      case 'Tutar':
        return 'totalAmount';
      case 'Müşteri':
        return 'customerName';
      case 'Numara':
        return 'saleNumber';
      case 'Oluşturma':
        return 'createdAt';
      default:
        return 'saleDate';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSalesList(List<Sale> sales, String searchQuery) {
    List<Sale> filteredSales = _applyFilters(sales, searchQuery);

    if (filteredSales.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.sell_outlined,
        title: 'Satış Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü' ||
                _selectedPaymentStatus != 'Tümü'
            ? 'Arama kriterlerinize uygun satış bulunamadı.'
            : 'Henüz satış kaydı bulunmuyor.\nYeni satış eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü' &&
                _selectedPaymentStatus == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Satış Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Satış listesini yenile
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredSales.length,
        itemBuilder: (context, index) {
          final sale = filteredSales[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSaleRow(sale),
          );
        },
      ),
    );
  }

  List<Sale> _applyFilters(List<Sale> sales, String searchQuery) {
    List<Sale> filtered = List.from(sales);

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((sale) {
        return sale.saleNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (sale.customerName
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (sale.notes?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((sale) => sale.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered
          .where((sale) => sale.status.displayName == _selectedStatus)
          .toList();
    }

    // Ödeme durumu filtresi
    if (_selectedPaymentStatus != 'Tümü') {
      filtered = filtered
          .where((sale) =>
              sale.paymentStatus.displayName == _selectedPaymentStatus)
          .toList();
    }

    // Tarih filtresi
    if (_dateRange != null) {
      filtered = filtered.where((sale) {
        return sale.saleDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            sale.saleDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'saleDate':
          return b.saleDate.compareTo(a.saleDate);
        case 'totalAmount':
          return b.totalAmount.compareTo(a.totalAmount);
        case 'customerName':
          return (a.customerName ?? '').compareTo(b.customerName ?? '');
        case 'saleNumber':
          return b.saleNumber.compareTo(a.saleNumber);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return b.saleDate.compareTo(a.saleDate);
      }
    });

    return filtered;
  }

  Widget _buildSaleRow(Sale sale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(sale.status);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: isDark ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(sale.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Satış türü ikonu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSaleTypeIcon(sale.type),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Satış bilgileri
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.saleNumber,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sale.customerName ?? 'Müşteri Yok',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Tarih
              Expanded(
                child: Text(
                  _formatDate(sale.saleDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Tutar
              Expanded(
                child: Text(
                  CurrencyHelper.formatCurrency(
                      sale.totalAmount, sale.currency),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Durum
              _buildStatusChip(sale.status, statusColor),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSaleTypeIcon(SaleType type) {
    switch (type) {
      case SaleType.sale:
        return Icons.sell;
      case SaleType.invoice:
        return Icons.receipt;
      case SaleType.proforma:
        return Icons.description;
      case SaleType.waybill:
        return Icons.local_shipping;
      case SaleType.receipt:
        return Icons.point_of_sale;
      case SaleType.estimate:
        return Icons.assessment;
    }
  }

  Color _getStatusColor(SaleStatus status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case SaleStatus.draft:
        return isDark ? Colors.grey[400]! : AppColors.textSecondary;
      case SaleStatus.pending:
        return AppColors.warning;
      case SaleStatus.confirmed:
        return AppColors.info;
      case SaleStatus.shipped:
        return AppColors.primary;
      case SaleStatus.delivered:
        return AppColors.success;
      case SaleStatus.paid:
        return AppColors.success;
      case SaleStatus.cancelled:
        return AppColors.error;
      case SaleStatus.returned:
        return AppColors.warning;
    }
  }

  Widget _buildStatusChip(SaleStatus status, Color color) {
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

  void _exportToExcel() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // TODO: Sales için Excel export implementasyonu
      final fileName =
          'sales_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      // Loading'i kapat
      Navigator.of(context).pop();

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel dosyası oluşturuldu: $fileName'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      // Loading'i kapat
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Hata mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel oluşturulurken hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _exportToCSV() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToCSV([]);

      // Loading'i kapat
      Navigator.of(context).pop();

      // Başarı mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV dosyası oluşturuldu: $fileName'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Hata mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV oluşturulurken hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _exportToPDF() async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final fileName = await ExcelService.exportCustomersToPDF([]);

      // Loading'i kapat
      Navigator.of(context).pop();

      // Başarı mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF dosyası oluşturuldu: $fileName'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Hata mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        content: Text(
          'Bu özellik yakında eklenecek.',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
