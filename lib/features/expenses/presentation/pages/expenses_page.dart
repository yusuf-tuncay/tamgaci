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
import '../../../accounts/domain/entities/account.dart';
import '../../../accounts/presentation/providers/account_providers.dart';
import '../providers/expenses_providers.dart';
import '../../../../core/services/export/excel_export_service.dart';
import '../../../../core/services/export/pdf_export_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/providers/company_provider.dart';
import '../../../company/presentation/providers/company_providers.dart';

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
  bool _filtersExpanded =
      false; // Mobil layout için filtreler açık/kapalı durumu

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

  void _showExportOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.table_chart,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              title: Text(
                'Excel Olarak İndir',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _exportToExcel();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.picture_as_pdf,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              title: Text(
                'PDF Olarak İndir',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _exportToPDF();
              },
            ),
          ],
        ),
      ),
    );
  }

  Account _buildAllAccountsDummy() {
    return Account(
      id: 'all',
      tenantId: 'unknown',
      name: 'Tüm Hesaplar',
      accountNumber: '0000000000',
      bankName: '—',
      branchName: '—',
      iban: 'TR00000000000000000000000000',
      swiftCode: '—',
      currency: 'TRY',
      balance: 0.0,
      availableBalance: 0.0,
      blockedAmount: 0.0,
      type: AccountType.other,
      status: AccountStatus.active,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
      updatedBy: 'system',
    );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onPrimary = theme.colorScheme.onPrimary;
    final secondaryTextColor = onPrimary.withValues(alpha: isDark ? 0.9 : 0.95);
    final borderColor = onPrimary.withValues(alpha: 0.12);
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
                        color: onPrimary,
                      ),
                    ),
                    Text(
                      'Masraf işlemlerinizi yönetin',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 12 : 14,
                        color: secondaryTextColor,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onPrimary = theme.colorScheme.onPrimary;
    final backgroundColor = onPrimary.withValues(alpha: isDark ? 0.16 : 0.22);
    final labelColor = onPrimary.withValues(alpha: 0.85);
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: onPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              color: onPrimary,
              size: compact ? 18 : 24,
            ),
            SizedBox(height: compact ? 6 : 8),
          ],
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: onPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: compact ? 10 : 12,
              color: labelColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 768;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.all(16),
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
            return ExpansionTile(
              initiallyExpanded: _filtersExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _filtersExpanded = expanded;
                });
              },
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              childrenPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              collapsedIconColor: isDark ? Colors.grey[400] : Colors.grey[600],
              iconColor: isDark ? Colors.grey[400] : Colors.grey[600],
              title: Text(
                'Arama ve Filtreler',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              const SizedBox(height: 10),
                              // İlk satır: Hesap ve Kategori
                              Row(
                                children: [
                                  Expanded(
                                    child: Consumer(
                                      builder: (context, ref, child) {
                                        final accountsAsync =
                                            ref.watch(accountsProvider);
                                        return accountsAsync.when(
                                          data: (accounts) {
                                            final isValidSelection =
                                                accounts.any((account) =>
                                                        account.id ==
                                                        _selectedAccountId) ||
                                                    _selectedAccountId == 'all';
                                            return DropdownButtonFormField<
                                                String>(
                                              initialValue: isValidSelection
                                                  ? _selectedAccountId
                                                  : 'all',
                                              decoration: InputDecoration(
                                                labelText: 'Hesap',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                isDense: true,
                                              ),
                                              items: [
                                                const DropdownMenuItem(
                                                  value: 'all',
                                                  child: Text('Tüm Hesaplar'),
                                                ),
                                                ...accounts.map((account) =>
                                                    DropdownMenuItem(
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
                                          loading: () =>
                                              DropdownButtonFormField<String>(
                                            initialValue: 'all',
                                            decoration: InputDecoration(
                                              labelText: 'Hesap',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                              isDense: true,
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                              isDense: true,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        isDense: true,
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
                              const SizedBox(height: 10),
                              // Tarih aralığı seçici (tam genişlik)
                              _buildDateRangeControl(),
                              const SizedBox(height: 10),
                              // İkinci satır: Sıralama ve Export
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue:
                                          _getSortDisplayName(_sortBy),
                                      decoration: InputDecoration(
                                        labelText: 'Sırala',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        isDense: true,
                                      ),
                                      items: _sortOptions.map((key) {
                                        return DropdownMenuItem(
                                          value: _getSortDisplayName(key),
                                          child: Text(_getSortDisplayName(key)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _sortBy = _getSortKeyFromDisplayName(
                                              value!);
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                    tooltip:
                                        _sortAscending ? 'Artan' : 'Azalan',
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: _showExportOptions,
                                    icon: const Icon(Icons.file_download),
                                    tooltip: 'Dışa Aktar',
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    padding: EdgeInsets.zero,
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
              ],
            );
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
        // Export seçenekleri (bottom sheet)
        IconButton(
          onPressed: _showExportOptions,
          icon: const Icon(Icons.file_download),
          tooltip: 'Dışa Aktar',
        ),
      ],
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
        padding: EdgeInsets.only(
          left: TamgaciConstants.paddingMedium(context).left,
          right: TamgaciConstants.paddingMedium(context).right,
          top: TamgaciConstants.paddingMedium(context).top,
          bottom: 0,
        ),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          final isLastItem = index == filteredExpenses.length - 1;
          return Padding(
            padding: EdgeInsets.only(
              bottom: isLastItem ? 16 : 12,
            ),
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
          // Hesap adlarını karşılaştırmak için accountsProvider'ı kullan
          final accountsAsync = ref.read(accountsProvider);
          final accounts = accountsAsync.valueOrNull ?? [];

          final aAccount = accounts.firstWhere(
            (acc) => acc.id == a.accountId,
            orElse: () => Account(
              id: a.accountId,
              tenantId: 'unknown',
              name: a.accountId,
              accountNumber: '0000000000',
              bankName: 'Bilinmeyen Banka',
              branchName: 'Bilinmeyen Şube',
              iban: 'TR00000000000000000000000000',
              swiftCode: 'UNKNOWN',
              currency: 'TRY',
              balance: 0.0,
              availableBalance: 0.0,
              blockedAmount: 0.0,
              type: AccountType.other,
              status: AccountStatus.active,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              createdBy: 'system',
              updatedBy: 'system',
            ),
          );

          final bAccount = accounts.firstWhere(
            (acc) => acc.id == b.accountId,
            orElse: () => Account(
              id: b.accountId,
              tenantId: 'unknown',
              name: b.accountId,
              accountNumber: '0000000000',
              bankName: 'Bilinmeyen Banka',
              branchName: 'Bilinmeyen Şube',
              iban: 'TR00000000000000000000000000',
              swiftCode: 'UNKNOWN',
              currency: 'TRY',
              balance: 0.0,
              availableBalance: 0.0,
              blockedAmount: 0.0,
              type: AccountType.other,
              status: AccountStatus.active,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              createdBy: 'system',
              updatedBy: 'system',
            ),
          );

          return _sortAscending
              ? aAccount.name.compareTo(bAccount.name)
              : bAccount.name.compareTo(aAccount.name);
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
                    Consumer(
                      builder: (context, ref, child) {
                        final accountsAsync = ref.watch(accountsProvider);
                        return accountsAsync.when(
                          data: (accounts) {
                            final account = accounts.firstWhere(
                              (a) => a.id == expense.accountId,
                              orElse: () => Account(
                                id: expense.accountId,
                                tenantId: 'unknown',
                                name: 'Bilinmeyen Hesap',
                                accountNumber: '0000000000',
                                bankName: 'Bilinmeyen Banka',
                                branchName: 'Bilinmeyen Şube',
                                iban: 'TR00000000000000000000000000',
                                swiftCode: 'UNKNOWN',
                                currency: 'TRY',
                                balance: 0.0,
                                availableBalance: 0.0,
                                blockedAmount: 0.0,
                                type: AccountType.other,
                                status: AccountStatus.active,
                                isActive: true,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                                createdBy: 'system',
                                updatedBy: 'system',
                              ),
                            );
                            return Text(
                              'Hesap: ${account.name}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            );
                          },
                          loading: () => Text(
                            'Hesap: Yükleniyor...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          error: (error, stack) => Text(
                            'Hesap: Bulunamadı',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        );
                      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[850] : null,
        title: Text(
          'Masraf Detayı',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Açıklama', expense.description, isDark),
            _buildDetailRow('Hesap', expense.accountId, isDark),
            _buildDetailRow('Tutar',
                CurrencyHelper.formatCurrency(expense.amount, 'TRY'), isDark),
            _buildDetailRow('Kategori',
                expense.category.toString().split('.').last, isDark),
            _buildDetailRow(
                'Tarih',
                DateFormat('dd.MM.yyyy HH:mm').format(expense.createdAt),
                isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
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
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    // Progress snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Excel dosyası oluşturuluyor...'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      final allExpenses = ref.read(allExpensesProvider);
      final filtered = _applyFilters(allExpenses);

      if (filtered.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export edilecek masraf bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // User, company, companyInfo (opsiyonel)
      final userAsync = ref.read(currentUserProvider);
      final companyAsync = ref.read(currentCompanyProvider);
      final companyInfoAsync = ref.read(companyInfoStreamProvider);

      final user = userAsync.value;
      final company = companyAsync.value;
      final companyInfo = companyInfoAsync.value;

      // Dummy account (tüm hesaplar)
      final account = _buildAllAccountsDummy();

      final filePath = await ExcelExportService.exportTransactionsToExcel(
        account: account,
        transactions: filtered,
        user: user,
        company: company,
        companyInfo: companyInfo,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        transactionType: null,
        transactionCategory: null,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Excel dosyası başarıyla oluşturuldu!${filePath != null ? '\n$filePath' : ''}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel export hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToPDF() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    // Progress snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('PDF dosyası oluşturuluyor...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }

    try {
      final allExpenses = ref.read(allExpensesProvider);
      final filtered = _applyFilters(allExpenses);

      if (filtered.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export edilecek masraf bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // User, company, companyInfo (opsiyonel)
      final userAsync = ref.read(currentUserProvider);
      final companyAsync = ref.read(currentCompanyProvider);
      final companyInfoAsync = ref.read(companyInfoStreamProvider);

      final user = userAsync.value;
      final company = companyAsync.value;
      final companyInfo = companyInfoAsync.value;

      // Dummy account (tüm hesaplar)
      final account = _buildAllAccountsDummy();

      await PdfExportService.exportTransactionsToPdf(
        account: account,
        transactions: filtered,
        user: user,
        company: company,
        companyInfo: companyInfo,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
        transactionType: null,
        transactionCategory: null,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF dosyası başarıyla oluşturuldu!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _navigateToCreate() {
    // TODO: Masraf ekleme sayfasına yönlendir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Masraf ekleme sayfasına yönlendiriliyor...')),
    );
  }
}
