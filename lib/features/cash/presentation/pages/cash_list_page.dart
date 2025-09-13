// ========== CASH LIST PAGE ==========
// lib/features/cash/presentation/pages/cash_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/routes/routes.dart';
import '../providers/cash_providers.dart';
import '../../domain/entities/cash_transaction.dart';

/// Kasa işlemleri listesi sayfası
class CashListPage extends ConsumerStatefulWidget {
  const CashListPage({super.key});

  @override
  ConsumerState<CashListPage> createState() => _CashListPageState();
}

class _CashListPageState extends ConsumerState<CashListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  /// Arama değişikliği dinleyicisi
  void _onSearchChanged() {
    ref.read(cashSearchQueryProvider.notifier).state = _searchController.text;
  }

  /// Filtre sayfasını aç
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterSheet(),
    );
  }

  /// Yeni işlem oluşturma sayfasına git
  void _navigateToCreate() {
    Navigator.of(context).pushNamed(TamgaciRoutes.createCashTransaction);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Kasa İşlemleri',
        showBackButton: true,
        showDrawer: false,
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrele',
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İşlem ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark
                    ? TamgaciConstants.surfaceColorDark
                    : TamgaciConstants.surfaceColor,
              ),
            ),
          ),

          // İşlem listesi
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final cashTransactionsAsync =
                    ref.watch(cashTransactionsStreamProvider);

                return cashTransactionsAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Henüz Kasa İşlemi Yok',
                        message:
                            'İlk kasa işleminizi oluşturmak için + butonuna tıklayın',
                        actionButton: ElevatedButton(
                          onPressed: _navigateToCreate,
                          child: const Text('İşlem Oluştur'),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return _buildTransactionCard(transaction, isDark);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: isDark ? Colors.red.shade300 : Colors.red,
                        ),
                        const SizedBox(height: TamgaciConstants.spaceMD),
                        Text(
                          'Hata: $error',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: isDark
                                ? TamgaciConstants.textSecondaryDark
                                : TamgaciConstants.textSecondary,
                          ),
                        ),
                        const SizedBox(height: TamgaciConstants.spaceLG),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(cashTransactionsStreamProvider);
                          },
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// İşlem kartı oluştur
  Widget _buildTransactionCard(CashTransaction transaction, bool isDark) {
    final isIncome = transaction.type == CashTransactionType.income;
    final isExpense = transaction.type == CashTransactionType.expense;

    Color cardColor;
    IconData typeIcon;
    String typeText;

    if (isIncome) {
      cardColor = isDark ? Colors.green.shade900 : Colors.green.shade50;
      typeIcon = Icons.trending_up;
      typeText = 'Gelir';
    } else if (isExpense) {
      cardColor = isDark ? Colors.red.shade900 : Colors.red.shade50;
      typeIcon = Icons.trending_down;
      typeText = 'Gider';
    } else {
      cardColor = isDark ? Colors.blue.shade900 : Colors.blue.shade50;
      typeIcon = Icons.swap_horiz;
      typeText = 'Transfer';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceMD),
      color: cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDark ? Colors.white24 : Colors.white70,
          child: Icon(
            typeIcon,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          transaction.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.white70,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction.category,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : isExpense ? '-' : ''}${NumberFormat.currency(
                locale: 'tr_TR',
                symbol: '₺',
              ).format(transaction.amount)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              DateFormat('dd.MM.yyyy').format(transaction.transactionDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        onTap: () {
          // İşlem detay sayfasına git
          // Navigator.of(context).pushNamed(
          //   TamgaciRoutes.cashTransactionDetail,
          //   arguments: transaction.id,
          // );
        },
      ),
    );
  }

  /// Filtre sayfası oluştur
  Widget _buildFilterSheet() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
            decoration: const BoxDecoration(
              color: TamgaciConstants.primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(
                  'Filtrele',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Filtre seçenekleri
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İşlem tipi filtresi
                  Text(
                    'İşlem Tipi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TamgaciConstants.spaceMD),
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedType =
                          ref.watch(selectedCashTransactionTypeProvider);

                      return Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Tümü'),
                            selected: selectedType == null,
                            onSelected: (selected) {
                              ref
                                  .read(selectedCashTransactionTypeProvider
                                      .notifier)
                                  .state = null;
                            },
                          ),
                          ...CashTransactionType.values.map((type) {
                            return FilterChip(
                              label: Text(type.displayName),
                              selected: selectedType == type,
                              onSelected: (selected) {
                                ref
                                    .read(selectedCashTransactionTypeProvider
                                        .notifier)
                                    .state = selected ? type : null;
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: TamgaciConstants.spaceLG),

                  // Tarih aralığı filtresi
                  Text(
                    'Tarih Aralığı',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TamgaciConstants.spaceMD),
                  Consumer(
                    builder: (context, ref, child) {
                      final dateRange = ref.watch(cashDateRangeProvider);

                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                  initialDateRange: dateRange != null
                                      ? DateTimeRange(
                                          start: dateRange['start']!,
                                          end: dateRange['end']!,
                                        )
                                      : null,
                                );
                                if (picked != null) {
                                  ref
                                      .read(cashDateRangeProvider.notifier)
                                      .state = {
                                    'start': picked.start,
                                    'end': picked.end,
                                  };
                                }
                              },
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                dateRange != null
                                    ? '${DateFormat('dd.MM.yyyy').format(dateRange['start']!)} - ${DateFormat('dd.MM.yyyy').format(dateRange['end']!)}'
                                    : 'Tarih Seç',
                              ),
                            ),
                          ),
                          if (dateRange != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                ref.read(cashDateRangeProvider.notifier).state =
                                    null;
                              },
                              icon: const Icon(Icons.clear),
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  // Filtreleri temizle butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(selectedCashTransactionTypeProvider.notifier)
                            .state = null;
                        ref.read(cashDateRangeProvider.notifier).state = null;
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Filtreleri Temizle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
