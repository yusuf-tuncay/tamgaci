// ========== ENHANCED PURCHASES LIST PAGE ==========
// lib/features/purchases/presentation/pages/enhanced_purchases_list_page.dart

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
import '../../domain/entities/purchase.dart';

/// Gelişmiş alışlar listesi sayfası
class EnhancedPurchasesListPage extends ConsumerStatefulWidget {
  const EnhancedPurchasesListPage({super.key});

  @override
  ConsumerState<EnhancedPurchasesListPage> createState() =>
      _EnhancedPurchasesListPageState();
}

class _EnhancedPurchasesListPageState
    extends ConsumerState<EnhancedPurchasesListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _selectedPaymentStatus = 'Tümü';
  String _sortBy = 'purchaseDate';
  bool _sortAscending = true;
  DateTimeRange? _dateRange;

  final List<String> _types = [
    'Tümü',
    'Fatura',
    'Proforma',
    'İrsaliye',
    'Fiş',
    'Sipariş',
    'Teklif'
  ];
  final List<String> _statuses = [
    'Tümü',
    'Taslak',
    'Beklemede',
    'Onaylandı',
    'Sipariş Verildi',
    'Teslim Alındı',
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
    'purchaseDate',
    'totalAmount',
    'supplierName',
    'purchaseNumber',
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
    Navigator.of(context).pushNamed('/purchases/create');
  }

  /// Header kartı - istatistikler ve hoş geldin mesajı
  Widget _buildWelcomeCard(List<Purchase> purchases) {
    final totalPurchases = purchases.length;
    final totalAmount = purchases.fold<double>(
        0, (sum, purchase) => sum + (purchase.totalAmount));
    final paidPurchases = purchases
        .where(
            (purchase) => purchase.paymentStatus == PurchasePaymentStatus.paid)
        .length;
    final pendingPurchases = purchases
        .where(
            (purchase) => purchase.paymentStatus != PurchasePaymentStatus.paid)
        .length;

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
                      'Alışlar',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Alış işlemlerinizi yönetin',
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildHeaderStatCard('Toplam Alış',
                              CurrencyHelper.formatCurrency(totalAmount, 'TRY')),
                          const SizedBox(width: 8),
                          _buildHeaderStatCard(
                              'Alış Sayısı', totalPurchases.toString()),
                          const SizedBox(width: 8),
                          _buildHeaderStatCard(
                              'Ödenen', paidPurchases.toString()),
                          const SizedBox(width: 8),
                          _buildHeaderStatCard(
                              'Bekleyen', pendingPurchases.toString()),
                        ],
                      ),
                    ),
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
                  _buildHeaderStatCard('Toplam Alış',
                      CurrencyHelper.formatCurrency(totalAmount, 'TRY')),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard(
                      'Alış Sayısı', totalPurchases.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Ödenen', paidPurchases.toString()),
                  const SizedBox(width: 8),
                  _buildHeaderStatCard('Bekleyen', pendingPurchases.toString()),
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

  void _navigateToDetail(String purchaseId) {
    Navigator.of(context).pushNamed('/purchases/detail', arguments: purchaseId);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final purchases = _getMockPurchases();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: CustomAppBar(
        title: 'Alışlar',
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
            child: _buildWelcomeCard(purchases),
          ),

          // Arama ve filtre çubuğu
          _buildSearchAndFilters(isDark),

          // Alış listesi
          Expanded(child: _buildPurchasesList(purchases, searchQuery)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
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
                      hintText: 'Alış ara...',
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
                    hintText: 'Alış ara...',
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
      case 'purchaseDate':
        return 'Tarih';
      case 'totalAmount':
        return 'Tutar';
      case 'supplierName':
        return 'Tedarikçi';
      case 'purchaseNumber':
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
        return 'purchaseDate';
      case 'Tutar':
        return 'totalAmount';
      case 'Tedarikçi':
        return 'supplierName';
      case 'Numara':
        return 'purchaseNumber';
      case 'Oluşturma':
        return 'createdAt';
      default:
        return 'purchaseDate';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildPurchasesList(List<Purchase> purchases, String searchQuery) {
    List<Purchase> filteredPurchases = _applyFilters(purchases, searchQuery);

    if (filteredPurchases.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Alış Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü' ||
                _selectedPaymentStatus != 'Tümü'
            ? 'Arama kriterlerinize uygun alış bulunamadı.'
            : 'Henüz alış kaydı bulunmuyor.\nYeni alış eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü' &&
                _selectedPaymentStatus == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Alış Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Alış listesini yenile
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredPurchases.length,
        itemBuilder: (context, index) {
          final purchase = filteredPurchases[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPurchaseCard(purchase),
          );
        },
      ),
    );
  }

  List<Purchase> _applyFilters(List<Purchase> purchases, String searchQuery) {
    List<Purchase> filtered = List.from(purchases);

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((purchase) {
        return purchase.purchaseNumber
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (purchase.supplierName
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (purchase.notes
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((purchase) => purchase.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered
          .where((purchase) => purchase.status.displayName == _selectedStatus)
          .toList();
    }

    // Ödeme durumu filtresi
    if (_selectedPaymentStatus != 'Tümü') {
      filtered = filtered
          .where((purchase) =>
              purchase.paymentStatus.displayName == _selectedPaymentStatus)
          .toList();
    }

    // Tarih filtresi
    if (_dateRange != null) {
      filtered = filtered.where((purchase) {
        return purchase.purchaseDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            purchase.purchaseDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'purchaseDate':
          return b.purchaseDate.compareTo(a.purchaseDate);
        case 'totalAmount':
          return b.totalAmount.compareTo(a.totalAmount);
        case 'supplierName':
          return (a.supplierName ?? '').compareTo(b.supplierName ?? '');
        case 'purchaseNumber':
          return b.purchaseNumber.compareTo(a.purchaseNumber);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return b.purchaseDate.compareTo(a.purchaseDate);
      }
    });

    return filtered;
  }

  Widget _buildPurchaseCard(Purchase purchase) {
    final statusColor = _getStatusColor(purchase.status);
    final paymentColor = _getPaymentStatusColor(purchase.paymentStatus);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(purchase.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - Alış numarası ve durum
              Row(
                children: [
                  // Alış türü ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      _getPurchaseTypeIcon(purchase.type),
                      color: statusColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Alış bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                purchase.purchaseNumber,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                purchase.type.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          purchase.supplierName ?? 'Tedarikçi Bilgisi Yok',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _formatDate(purchase.purchaseDate),
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

                  // Durum
                  _buildStatusChip(purchase.status, statusColor),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Tutar ve ödeme bilgileri
              Row(
                children: [
                  // Toplam tutar
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Toplam Tutar',
                      value: CurrencyHelper.formatCurrency(
                          purchase.totalAmount, purchase.currency),
                      color: AppColors.primary,
                      icon: Icons.attach_money,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Ödeme durumu
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Ödeme Durumu',
                      value: purchase.paymentStatus.displayName,
                      color: paymentColor,
                      icon: _getPaymentStatusIcon(purchase.paymentStatus),
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Vade tarihi
                  if (purchase.dueDate != null)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Vade Tarihi',
                        value: _formatDate(purchase.dueDate!),
                        color: purchase.isOverdue
                            ? AppColors.error
                            : AppColors.info,
                        icon: Icons.calendar_today,
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

  IconData _getPurchaseTypeIcon(PurchaseType type) {
    switch (type) {
      case PurchaseType.invoice:
        return Icons.receipt;
      case PurchaseType.proforma:
        return Icons.description;
      case PurchaseType.waybill:
        return Icons.local_shipping;
      case PurchaseType.receipt:
        return Icons.point_of_sale;
      case PurchaseType.purchase:
        return Icons.shopping_cart;
      case PurchaseType.returnPurchase:
        return Icons.keyboard_return;
      case PurchaseType.estimate:
        return Icons.assessment;
    }
  }

  IconData _getPaymentStatusIcon(PurchasePaymentStatus status) {
    switch (status) {
      case PurchasePaymentStatus.pending:
        return Icons.pending;
      case PurchasePaymentStatus.partial:
        return Icons.payment;
      case PurchasePaymentStatus.paid:
        return Icons.check_circle;
      case PurchasePaymentStatus.overdue:
        return Icons.warning;
      case PurchasePaymentStatus.refunded:
        return Icons.keyboard_return;
    }
  }

  Color _getStatusColor(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.draft:
        return AppColors.textSecondary;
      case PurchaseStatus.pending:
        return AppColors.warning;
      case PurchaseStatus.confirmed:
        return AppColors.info;
      case PurchaseStatus.received:
        return AppColors.success;
      case PurchaseStatus.paid:
        return AppColors.success;
      case PurchaseStatus.cancelled:
        return AppColors.error;
      case PurchaseStatus.returned:
        return AppColors.warning;
    }
  }

  Color _getPaymentStatusColor(PurchasePaymentStatus status) {
    switch (status) {
      case PurchasePaymentStatus.pending:
        return AppColors.warning;
      case PurchasePaymentStatus.partial:
        return AppColors.info;
      case PurchasePaymentStatus.paid:
        return AppColors.success;
      case PurchasePaymentStatus.overdue:
        return AppColors.error;
      case PurchasePaymentStatus.refunded:
        return AppColors.warning;
    }
  }

  Widget _buildStatusChip(PurchaseStatus status, Color color) {
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

  List<Purchase> _getMockPurchases() {
    return [
      Purchase(
        id: '1',
        tenantId: 'mock-tenant',
        purchaseNumber: 'ALI-2024-001',
        type: PurchaseType.invoice,
        status: PurchaseStatus.received,
        paymentStatus: PurchasePaymentStatus.paid,
        supplierId: '1',
        supplierName: 'ABC Tedarik A.Ş.',
        purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().subtract(const Duration(days: 4)),
        receivedDate: DateTime.now().subtract(const Duration(days: 5)),
        subtotal: 2000.0,
        taxRate: 18.0,
        taxAmount: 360.0,
        discountAmount: 100.0,
        totalAmount: 2260.0,
        currency: 'TRY',
        items: [],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Purchase(
        id: '2',
        tenantId: 'mock-tenant',
        purchaseNumber: 'ALI-2024-002',
        type: PurchaseType.purchase,
        status: PurchaseStatus.confirmed,
        paymentStatus: PurchasePaymentStatus.pending,
        supplierId: '2',
        supplierName: 'XYZ Malzeme Ltd.',
        purchaseDate: DateTime.now().subtract(const Duration(days: 4)),
        dueDate: DateTime.now().add(const Duration(days: 10)),
        subtotal: 1500.0,
        taxRate: 18.0,
        taxAmount: 270.0,
        discountAmount: 0.0,
        totalAmount: 1770.0,
        currency: 'TRY',
        items: [],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Purchase(
        id: '3',
        tenantId: 'mock-tenant',
        purchaseNumber: 'ALI-2024-003',
        type: PurchaseType.waybill,
        status: PurchaseStatus.confirmed,
        paymentStatus: PurchasePaymentStatus.partial,
        supplierId: '3',
        supplierName: 'DEF Hammadde A.Ş.',
        purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 20)),
        subtotal: 3000.0,
        taxRate: 18.0,
        taxAmount: 540.0,
        discountAmount: 150.0,
        totalAmount: 3390.0,
        currency: 'TRY',
        items: [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
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

      final fileName = await ExcelService.exportCustomersToExcel([]);

      // Loading'i kapat
      Navigator.of(context).pop();

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel dosyası oluşturuldu: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Loading'i kapat
      Navigator.of(context).pop();

      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel oluşturulurken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV dosyası oluşturuldu: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Loading'i kapat
      Navigator.of(context).pop();

      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV oluşturulurken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF dosyası oluşturuldu: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Loading'i kapat
      Navigator.of(context).pop();

      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF oluşturulurken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya İçe Aktar'),
        content: const Text('Bu özellik yakında eklenecek.'),
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
