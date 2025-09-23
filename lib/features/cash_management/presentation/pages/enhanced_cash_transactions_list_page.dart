// ========== ENHANCED CASH TRANSACTIONS LIST PAGE ==========
// lib/features/cash_management/presentation/pages/enhanced_cash_transactions_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/account.dart';

/// Gelişmiş nakit işlemleri listesi sayfası
class EnhancedCashTransactionsListPage extends ConsumerStatefulWidget {
  const EnhancedCashTransactionsListPage({super.key});

  @override
  ConsumerState<EnhancedCashTransactionsListPage> createState() =>
      _EnhancedCashTransactionsListPageState();
}

class _EnhancedCashTransactionsListPageState
    extends ConsumerState<EnhancedCashTransactionsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'Tümü';
  String _selectedStatus = 'Tümü';
  String _selectedAccount = 'Tümü';
  String _sortBy = 'transactionDate';
  DateTimeRange? _dateRange;

  final List<String> _types = [
    'Tümü',
    'Gelir',
    'Gider',
    'Transfer',
    'Düzeltme',
    'Kredi',
    'Yatırım'
  ];
  final List<String> _statuses = [
    'Tümü',
    'Beklemede',
    'Tamamlandı',
    'İptal Edildi',
    'Başarısız'
  ];
  final List<String> _sortOptions = [
    'transactionDate',
    'amount',
    'type',
    'status',
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
    Navigator.of(context).pushNamed('/cash-transactions/create');
  }

  void _navigateToDetail(String transactionId) {
    Navigator.of(context)
        .pushNamed('/cash-transactions/detail', arguments: transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = _searchController.text;
    final transactions = _getMockTransactions();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Nakit İşlemleri',
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
          _buildStatsCards(transactions),

          // İşlemler listesi
          Expanded(child: _buildTransactionsList(transactions, searchQuery)),
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
              hintText: 'İşlem ara...',
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
                _buildFilterChip(
                    'Hesap', _selectedAccount, _getMockAccountNames(), (value) {
                  setState(() {
                    _selectedAccount = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Sırala', _getSortDisplayName(_sortBy),
                    _sortOptions.map(_getSortDisplayName).toList(), (value) {
                  setState(() {
                    _sortBy = _getSortKeyFromDisplayName(value);
                  });
                }),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_dateRange != null
                      ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                      : 'Tarih'),
                  selected: _dateRange != null,
                  onSelected: (selected) {
                    if (selected) {
                      _selectDateRange();
                    } else {
                      setState(() {
                        _dateRange = null;
                      });
                    }
                  },
                ),
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
      case 'transactionDate':
        return 'Tarih';
      case 'amount':
        return 'Tutar';
      case 'type':
        return 'Tür';
      case 'status':
        return 'Durum';
      case 'createdAt':
        return 'Oluşturma';
      default:
        return 'Tarih';
    }
  }

  String _getSortKeyFromDisplayName(String displayName) {
    switch (displayName) {
      case 'Tarih':
        return 'transactionDate';
      case 'Tutar':
        return 'amount';
      case 'Tür':
        return 'type';
      case 'Durum':
        return 'status';
      case 'Oluşturma':
        return 'createdAt';
      default:
        return 'transactionDate';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatsCards(List<CashTransaction> transactions) {
    final totalTransactions = transactions.length;
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final pendingTransactions = transactions
        .where((t) => t.status == CashTransactionStatus.pending)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Toplam İşlem',
              totalTransactions.toString(),
              Icons.receipt_long,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Gelir',
              CurrencyHelper.formatCurrency(totalIncome, 'TRY'),
              Icons.trending_up,
              AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Toplam Gider',
              CurrencyHelper.formatCurrency(totalExpense, 'TRY'),
              Icons.trending_down,
              AppColors.error,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Bekleyen',
              pendingTransactions.toString(),
              Icons.pending,
              AppColors.warning,
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

  Widget _buildTransactionsList(
      List<CashTransaction> transactions, String searchQuery) {
    List<CashTransaction> filteredTransactions =
        _applyFilters(transactions, searchQuery);

    if (filteredTransactions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'İşlem Bulunamadı',
        message: searchQuery.isNotEmpty ||
                _selectedType != 'Tümü' ||
                _selectedStatus != 'Tümü' ||
                _selectedAccount != 'Tümü'
            ? 'Arama kriterlerinize uygun işlem bulunamadı.'
            : 'Henüz nakit işlemi bulunmuyor.\nYeni işlem eklemek için + butonuna tıklayın.',
        actionButton: searchQuery.isEmpty &&
                _selectedType == 'Tümü' &&
                _selectedStatus == 'Tümü' &&
                _selectedAccount == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('İşlem Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // İşlem listesini yenile
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = filteredTransactions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTransactionCard(transaction),
          );
        },
      ),
    );
  }

  List<CashTransaction> _applyFilters(
      List<CashTransaction> transactions, String searchQuery) {
    List<CashTransaction> filtered = List.from(transactions);

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return (transaction.description
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (transaction.reference
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (transaction.category
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Tür filtresi
    if (_selectedType != 'Tümü') {
      filtered = filtered
          .where((transaction) => transaction.type.displayName == _selectedType)
          .toList();
    }

    // Durum filtresi
    if (_selectedStatus != 'Tümü') {
      filtered = filtered
          .where((transaction) =>
              transaction.status.displayName == _selectedStatus)
          .toList();
    }

    // Hesap filtresi
    if (_selectedAccount != 'Tümü') {
      filtered = filtered
          .where((transaction) =>
              _getAccountName(transaction.accountId) == _selectedAccount)
          .toList();
    }

    // Tarih filtresi
    if (_dateRange != null) {
      filtered = filtered.where((transaction) {
        return transaction.transactionDate
                .isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
            transaction.transactionDate
                .isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'transactionDate':
          return b.transactionDate.compareTo(a.transactionDate);
        case 'amount':
          return b.amount.compareTo(a.amount);
        case 'type':
          return a.type.displayName.compareTo(b.type.displayName);
        case 'status':
          return a.status.displayName.compareTo(b.status.displayName);
        case 'createdAt':
          return b.createdAt.compareTo(a.createdAt);
        default:
          return b.transactionDate.compareTo(a.transactionDate);
      }
    });

    return filtered;
  }

  Widget _buildTransactionCard(CashTransaction transaction) {
    final typeColor = _getTypeColor(transaction.type);
    final statusColor = _getStatusColor(transaction.status);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(transaction.id),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: TamgaciConstants.cardPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım - İşlem türü ve durum
              Row(
                children: [
                  // İşlem türü ikonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusSM),
                    ),
                    child: Icon(
                      _getTransactionTypeIcon(transaction.type),
                      color: typeColor,
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // İşlem bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                transaction.description ??
                                    'İşlem Açıklaması Yok',
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
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                transaction.type.displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _getAccountName(transaction.accountId),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          _formatDate(transaction.transactionDate),
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
                  _buildStatusChip(transaction.status, statusColor),
                ],
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Alt kısım - Tutar ve kategori bilgileri
              Row(
                children: [
                  // Tutar
                  Expanded(
                    child: _buildInfoCard(
                      label: 'Tutar',
                      value: CurrencyHelper.formatCurrency(
                          transaction.amount, transaction.currency),
                      color: transaction.isIncome
                          ? AppColors.success
                          : AppColors.error,
                      icon: transaction.isIncome
                          ? Icons.add_circle
                          : Icons.remove_circle,
                    ),
                  ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Kategori
                  if (transaction.category != null)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Kategori',
                        value: transaction.category!,
                        color: AppColors.info,
                        icon: Icons.category,
                      ),
                    ),

                  const SizedBox(width: TamgaciConstants.spaceMD),

                  // Referans
                  if (transaction.reference != null)
                    Expanded(
                      child: _buildInfoCard(
                        label: 'Referans',
                        value: transaction.reference!,
                        color: AppColors.textSecondary,
                        icon: Icons.tag,
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

  IconData _getTransactionTypeIcon(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.income:
        return Icons.trending_up;
      case CashTransactionType.expense:
        return Icons.trending_down;
      case CashTransactionType.transfer:
        return Icons.swap_horiz;
      case CashTransactionType.adjustment:
        return Icons.edit;
      case CashTransactionType.loan:
        return Icons.credit_card;
      case CashTransactionType.investment:
        return Icons.trending_up;
    }
  }

  Color _getTypeColor(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.income:
        return AppColors.success;
      case CashTransactionType.expense:
        return AppColors.error;
      case CashTransactionType.transfer:
        return AppColors.info;
      case CashTransactionType.adjustment:
        return AppColors.warning;
      case CashTransactionType.loan:
        return AppColors.primary;
      case CashTransactionType.investment:
        return AppColors.success;
    }
  }

  Color _getStatusColor(CashTransactionStatus status) {
    switch (status) {
      case CashTransactionStatus.pending:
        return AppColors.warning;
      case CashTransactionStatus.completed:
        return AppColors.success;
      case CashTransactionStatus.cancelled:
        return AppColors.error;
      case CashTransactionStatus.failed:
        return AppColors.error;
    }
  }

  Widget _buildStatusChip(CashTransactionStatus status, Color color) {
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

  List<String> _getMockAccountNames() {
    return [
      'Tümü',
      'Ana Nakit Kasa',
      'İş Bankası TRY Hesabı',
      'Kredi Kartı',
      'USD Döviz Hesabı'
    ];
  }

  String _getAccountName(String accountId) {
    switch (accountId) {
      case '1':
        return 'Ana Nakit Kasa';
      case '2':
        return 'İş Bankası TRY Hesabı';
      case '3':
        return 'Kredi Kartı';
      case '4':
        return 'USD Döviz Hesabı';
      default:
        return 'Bilinmeyen Hesap';
    }
  }

  List<CashTransaction> _getMockTransactions() {
    return [
      CashTransaction(
        id: '1',
        accountId: '1',
        type: CashTransactionType.income,
        status: CashTransactionStatus.completed,
        amount: 5000.0,
        currency: 'TRY',
        description: 'Satış geliri',
        category: 'Satış',
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CashTransaction(
        id: '2',
        accountId: '2',
        type: CashTransactionType.expense,
        status: CashTransactionStatus.completed,
        amount: 1500.0,
        currency: 'TRY',
        description: 'Ofis kirası',
        category: 'Kira',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CashTransaction(
        id: '3',
        accountId: '1',
        toAccountId: '2',
        type: CashTransactionType.transfer,
        status: CashTransactionStatus.completed,
        amount: 10000.0,
        currency: 'TRY',
        description: 'Nakitten bankaya transfer',
        transactionDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CashTransaction(
        id: '4',
        accountId: '3',
        type: CashTransactionType.expense,
        status: CashTransactionStatus.pending,
        amount: 2500.0,
        currency: 'TRY',
        description: 'Hammadde alımı',
        category: 'Alım',
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
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
