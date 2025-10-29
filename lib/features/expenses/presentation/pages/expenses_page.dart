// ========== ENHANCED EXPENSES LIST PAGE ==========
// lib/features/expenses/presentation/pages/expenses_page.dart

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
import '../../../accounts/domain/entities/account_transaction.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../providers/expenses_providers.dart';

/// Gelişmiş masraflar listesi sayfası
class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedAccountId = 'all';
  String _selectedCategory = 'Tümü';
  String _sortBy = 'createdAt';
  bool _sortAscending = false; // En yeni önce
  DateTimeRange? _dateRange;

  // Export debounce
  bool _isExporting = false;

  late final List<String> _categories = [
    'Tümü',
    'Masraf',
    'Diğer',
  ];

  late final List<String> _sortOptions = [
    'createdAt',
    'amount',
    'description',
    'accountName',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  String _formatDateRange(DateTimeRange range) {
    final df = DateFormat('dd.MM.yyyy');
    return '${df.format(range.start)} - ${df.format(range.end)}';
  }

  /// Diğer modüllerle tutarlı tarih aralığı butonu
  Widget _buildDateRangeControl() {
    return GestureDetector(
      onTap: _showDateRangeDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dateRange == null
                    ? 'Tarih Aralığı Seç'
                    : _formatDateRange(_dateRange!),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      _dateRange != null ? Colors.blue[700] : Colors.grey[600],
                  fontWeight:
                      _dateRange != null ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangeDialog() {
    DateTime tempStart =
        _dateRange?.start ?? DateTime.now().subtract(const Duration(days: 7));
    DateTime tempEnd = _dateRange?.end ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                'Tarih Aralığı Seç',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Başlangıç',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      CalendarDatePicker(
                        initialDate: tempStart,
                        firstDate: DateTime(2000),
                        lastDate: tempEnd.isAfter(DateTime(2000))
                            ? tempEnd
                            : DateTime(2100),
                        onDateChanged: (d) {
                          setStateDialog(() {
                            tempStart = DateTime(d.year, d.month, d.day);
                            if (tempEnd.isBefore(tempStart)) {
                              tempEnd = tempStart;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Bitiş',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 8),
                      CalendarDatePicker(
                        initialDate: tempEnd,
                        firstDate: tempStart,
                        lastDate: DateTime(2100),
                        onDateChanged: (d) {
                          setStateDialog(() {
                            tempEnd = DateTime(d.year, d.month, d.day);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateRange = DateTimeRange(
                        start: DateTime(
                            tempStart.year, tempStart.month, tempStart.day),
                        end: DateTime(tempEnd.year, tempEnd.month, tempEnd.day,
                            23, 59, 59, 999),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Uygula'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateRange = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Temizle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getAccountNameById(String accountId) {
    final accountsAsync = ref.read(accountsProvider);
    return accountsAsync.maybeWhen(
      data: (accounts) {
        final match = accounts.where((a) => a.id == accountId);
        return match.isNotEmpty ? match.first.name : accountId;
      },
      orElse: () => accountId,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(allExpensesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Masraflar',
        showDrawer: true,
      ),
      drawerContent: const TamgaciDrawerMenu(),
      persistentOnLarge: false,
      body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header kartı
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildWelcomeCard(expenses),
              ),

              // Arama ve filtre çubuğu
              Flexible(
                child: _buildSearchAndFilters(isDark),
              ),

              // Masraflar listesi
              Expanded(child: _buildExpensesList(expenses, isDark)),
            ],
          )),
    );
  }

  Widget _buildWelcomeCard(List<AccountTransaction> expenses) {
    final isMobile = MediaQuery.of(context).size.width <= 768;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                      'Masraflar',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Masraf işlemlerinizi yönetin',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 12 : 14,
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
                      _buildHeaderStatCard('Toplam Masraf',
                          '${expenses.length}', Icons.money_off),
                      const SizedBox(width: 16),
                      _buildHeaderStatCard(
                          'Toplam Tutar',
                          CurrencyHelper.formatCurrency(
                              expenses.fold(
                                  0.0, (sum, expense) => sum + expense.amount),
                              'TRY'),
                          Icons.attach_money),
                      const SizedBox(width: 16),
                      _buildHeaderStatCard(
                          'Bu Ay',
                          '${expenses.where((e) => DateTime.now().month == e.createdAt.month && DateTime.now().year == e.createdAt.year).length}',
                          Icons.calendar_month),
                    ],
                  ),
                ),
            ],
          ),
          // Mobile'da istatistikler: tek satır 3 kompakt kart
          if (isMobile) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildHeaderStatCard(
                    'Toplam',
                    '${expenses.length}',
                    Icons.receipt_long,
                    compact: true,
                    showIcon: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHeaderStatCard(
                    'Tutar',
                    CurrencyHelper.formatCurrency(
                      expenses.fold(0.0, (sum, e) => sum + e.amount),
                      'TRY',
                    ),
                    Icons.attach_money,
                    compact: true,
                    showIcon: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHeaderStatCard(
                    'Bu Ay',
                    '${expenses.where((e) => DateTime.now().month == e.createdAt.month && DateTime.now().year == e.createdAt.year).length}',
                    Icons.calendar_month,
                    compact: true,
                    showIcon: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStatCard(String title, String value, IconData icon,
      {bool compact = false, bool showIcon = true}) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              color: Colors.white,
              size: compact ? 18 : 24,
            ),
            SizedBox(height: compact ? 6 : 8),
          ],
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: compact ? 10 : 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          if (constraints.maxWidth > 768) {
            return _buildDesktopFilters();
          } else {
            return _buildMobileFilters();
          }
        },
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Arama çubuğu
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Masraf ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Hesap filtresi
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final accountsAsync = ref.watch(accountsProvider);
              return DropdownButtonFormField<String>(
                initialValue: accountsAsync.when(
                  data: (_) => _selectedAccountId,
                  loading: () => null,
                  error: (_, __) => null,
                ),
                decoration: InputDecoration(
                  labelText: 'Hesap',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: accountsAsync.when(
                  data: (accounts) => [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Tüm Hesaplar'),
                    ),
                    ...accounts.map((account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        )),
                  ],
                  loading: () => [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Tüm Hesaplar'),
                    ),
                  ],
                  error: (_, __) => [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('Tüm Hesaplar'),
                    ),
                  ],
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value ?? 'all';
                  });
                },
              );
            },
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
                horizontal: 12,
                vertical: 12,
              ),
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
        const SizedBox(width: 12),
        // Tarih aralığı seçici
        Expanded(child: _buildDateRangeControl()),
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
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: _sortOptions.map((key) {
              return DropdownMenuItem(
                value: _getSortDisplayName(key),
                child: Text(_getSortDisplayName(key)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _sortBy = _getSortKeyFromDisplayName(value!);
              });
            },
          ),
        ),
        const SizedBox(width: 12),
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
        const SizedBox(width: 12),
        // Export butonları
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.table_chart),
              tooltip: 'Excel\'e Aktar',
            ),
            IconButton(
              onPressed: _exportToPDF,
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'PDF\'ye Aktar',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arama çubuğu - tam genişlik
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Masraf ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // İlk satır: Hesap ve Kategori
          Row(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final accountsAsync = ref.watch(accountsProvider);
                    return accountsAsync.when(
                      data: (accounts) {
                        // Seçili hesap geçerli mi kontrol et
                        final isValidSelection = accounts.any((account) =>
                                account.id == _selectedAccountId) ||
                            _selectedAccountId == 'all';
                        return DropdownButtonFormField<String>(
                          initialValue:
                              isValidSelection ? _selectedAccountId : 'all',
                          decoration: InputDecoration(
                            labelText: 'Hesap',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Tüm Hesaplar'),
                            ),
                            ...accounts.map((account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(account.name),
                                )),
                          ],
                          onChanged: (value) {
                            if (value != null && mounted) {
                              setState(() {
                                _selectedAccountId = value;
                              });
                            }
                          },
                        );
                      },
                      loading: () => DropdownButtonFormField<String>(
                        initialValue: 'all',
                        decoration: InputDecoration(
                          labelText: 'Hesap',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Yükleniyor...'),
                          ),
                        ],
                        onChanged: null,
                      ),
                      error: (error, stackTrace) =>
                          DropdownButtonFormField<String>(
                        initialValue: 'all',
                        decoration: InputDecoration(
                          labelText: 'Hesap',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Hata oluştu'),
                          ),
                        ],
                        onChanged: null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
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
            ],
          ),
          const SizedBox(height: 12),
          // Tarih aralığı seçici (tam genişlik)
          SizedBox(width: double.infinity, child: _buildDateRangeControl()),
          const SizedBox(height: 12),
          // İkinci satır: Sıralama ve Export
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _getSortDisplayName(_sortBy),
                  decoration: InputDecoration(
                    labelText: 'Sırala',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: _sortOptions.map((key) {
                    return DropdownMenuItem(
                      value: _getSortDisplayName(key),
                      child: Text(_getSortDisplayName(key)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sortBy = _getSortKeyFromDisplayName(value!);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
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
              const SizedBox(width: 12),
              IconButton(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.table_chart),
                tooltip: 'Excel\'e Aktar',
              ),
              IconButton(
                onPressed: _exportToPDF,
                icon: const Icon(Icons.picture_as_pdf),
                tooltip: 'PDF\'ye Aktar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortDisplayName(String key) {
    switch (key) {
      case 'createdAt':
        return 'Tarih';
      case 'amount':
        return 'Tutar';
      case 'description':
        return 'Açıklama';
      case 'accountName':
        return 'Hesap';
      default:
        return 'Tarih';
    }
  }

  String _getSortKeyFromDisplayName(String displayName) {
    switch (displayName) {
      case 'Tarih':
        return 'createdAt';
      case 'Tutar':
        return 'amount';
      case 'Açıklama':
        return 'description';
      case 'Hesap':
        return 'accountName';
      default:
        return 'createdAt';
    }
  }

  Widget _buildExpensesList(List<AccountTransaction> expenses, bool isDark) {
    final filteredExpenses = _applyFilters(expenses);

    if (filteredExpenses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.money_off,
        title: 'Masraf Bulunamadı',
        message: _searchQuery.isNotEmpty ||
                _selectedAccountId != 'all' ||
                _selectedCategory != 'Tümü'
            ? 'Arama kriterlerinize uygun masraf bulunamadı.'
            : 'Henüz masraf kaydı bulunmuyor.\nYeni masraf eklemek için + butonuna tıklayın.',
        actionButton: _searchQuery.isEmpty &&
                _selectedAccountId == 'all' &&
                _selectedCategory == 'Tümü'
            ? ElevatedButton.icon(
                onPressed: _navigateToCreate,
                icon: const Icon(Icons.add),
                label: const Text('Masraf Ekle'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allExpensesProvider);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: TamgaciConstants.paddingMedium(context),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExpenseRow(expense, isDark),
          );
        },
      ),
    );
  }

  List<AccountTransaction> _applyFilters(List<AccountTransaction> expenses) {
    List<AccountTransaction> filtered = List.from(expenses);

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((expense) {
        return expense.description.toLowerCase().contains(_searchQuery) ||
            (expense.accountId.toLowerCase().contains(_searchQuery));
      }).toList();
    }

    // Hesap filtresi
    if (_selectedAccountId != 'all') {
      filtered = filtered
          .where((expense) => expense.accountId == _selectedAccountId)
          .toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((expense) =>
              expense.category.toString().split('.').last == _selectedCategory)
          .toList();
    }

    // Tarih aralığı filtresi
    if (_dateRange != null) {
      final start = DateTime(_dateRange!.start.year, _dateRange!.start.month,
          _dateRange!.start.day);
      final end = DateTime(_dateRange!.end.year, _dateRange!.end.month,
          _dateRange!.end.day, 23, 59, 59, 999);
      filtered = filtered
          .where(
              (e) => !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end))
          .toList();
    }

    // Sıralama
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'createdAt':
          return _sortAscending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        case 'amount':
          return _sortAscending
              ? a.amount.abs().compareTo(b.amount.abs())
              : b.amount.abs().compareTo(a.amount.abs());
        case 'description':
          return _sortAscending
              ? a.description.compareTo(b.description)
              : b.description.compareTo(a.description);
        case 'accountName':
          final aName = _getAccountNameById(a.accountId);
          final bName = _getAccountNameById(b.accountId);
          return _sortAscending
              ? aName.compareTo(bName)
              : bName.compareTo(aName);
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    return filtered;
  }

  Widget _buildExpenseRow(AccountTransaction expense, bool isDark) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: () => _showExpenseDetail(expense),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Masraf ikonu
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.money_off,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Masraf bilgileri
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hesap: ${_getAccountNameById(expense.accountId)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy HH:mm').format(expense.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Tutar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyHelper.formatCurrency(expense.amount, 'TRY'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    expense.category.toString().split('.').last,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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

  void _showExpenseDetail(AccountTransaction expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Masraf Detayı',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', expense.description),
            _buildDetailRow('Hesap', expense.accountId),
            _buildDetailRow(
                'Tutar', CurrencyHelper.formatCurrency(expense.amount, 'TRY')),
            _buildDetailRow(
                'Kategori', expense.category.toString().split('.').last),
            _buildDetailRow('Tarih',
                DateFormat('dd.MM.yyyy HH:mm').format(expense.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  void _exportToExcel() {
    Navigator.of(context).pop(); // Bottom sheet'i kapat
    setState(() {
      _isExporting = true;
    });

    // TODO: Excel export implementasyonu
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel export başarılı!')),
      );
    });
  }

  void _exportToPDF() {
    Navigator.of(context).pop(); // Bottom sheet'i kapat
    setState(() {
      _isExporting = true;
    });

    // TODO: PDF export implementasyonu
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isExporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF export başarılı!')),
      );
    });
  }

  void _navigateToCreate() {
    // TODO: Masraf ekleme sayfasına yönlendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Masraf ekleme sayfasına yönlendiriliyor...')),
    );
  }
}
