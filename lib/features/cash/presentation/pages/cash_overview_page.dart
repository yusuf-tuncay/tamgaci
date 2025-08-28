// ========== CASH (KASA YÖNETİMİ) FEATURE ==========
// lib/features/cash/presentation/pages/cash_overview_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../core/routes/routes.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income.dart';
import '../../../expenses/domain/entities/expense.dart';

/// Kasa yönetimi özet sayfası
class CashOverviewPage extends ConsumerStatefulWidget {
  const CashOverviewPage({super.key});

  @override
  ConsumerState<CashOverviewPage> createState() => _CashOverviewPageState();
}

class _CashOverviewPageState extends ConsumerState<CashOverviewPage> {
  @override
  Widget build(BuildContext context) {
    final incomesAsync = ref.watch(incomesStreamProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Kasa Yönetimi',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(TamgaciRoutes.cashTransactions),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => _showAddTransactionDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(incomesStreamProvider);
          ref.invalidate(expensesStreamProvider);
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: TamgaciConstants.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kasa bakiyeleri kartları
              _buildBalanceCards(incomesAsync, expensesAsync),

              const SizedBox(height: 24),

              // Hızlı işlemler
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Son işlemler
              _buildRecentTransactions(incomesAsync, expensesAsync),

              const SizedBox(height: 24),

              // İstatistikler
              _buildStatistics(incomesAsync, expensesAsync),
            ],
          ),
        ),
      ),
    );
  }

  /// Kasa bakiyeleri kartlarını oluşturur
  Widget _buildBalanceCards(
    AsyncValue<List<Income>> incomesAsync,
    AsyncValue<List<Expense>> expensesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kasa Bakiyeleri',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        incomesAsync.when(
          data: (incomes) => expensesAsync.when(
            data: (expenses) {
              final now = DateTime.now();
              final currentMonth = DateTime(now.year, now.month);
              
              // Bu ay gelirleri
              final currentMonthIncomes = incomes.where((income) {
                final incomeDate = DateTime(
                  income.incomeDate.year,
                  income.incomeDate.month,
                );
                return incomeDate.isAtSameMomentAs(currentMonth);
              }).toList();

              // Bu ay giderleri
              final currentMonthExpenses = expenses.where((expense) {
                final expenseDate = DateTime(
                  expense.expenseDate.year,
                  expense.expenseDate.month,
                );
                return expenseDate.isAtSameMomentAs(currentMonth);
              }).toList();

              // Toplam hesaplamalar
              final totalIncome = currentMonthIncomes.fold<double>(
                0, (sum, income) => sum + income.amount,
              );
              final totalExpense = currentMonthExpenses.fold<double>(
                0, (sum, expense) => sum + expense.amount,
              );
              final netBalance = totalIncome - totalExpense;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          title: 'Bu Ay Gelir',
                          amount: totalIncome,
                          icon: Icons.trending_up,
                          color: TamgaciConstants.successColor,
                          isPositive: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBalanceCard(
                          title: 'Bu Ay Gider',
                          amount: totalExpense,
                          icon: Icons.trending_down,
                          color: TamgaciConstants.errorColor,
                          isPositive: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          title: 'Net Bakiye',
                          amount: netBalance,
                          icon: Icons.account_balance_wallet,
                          color: netBalance >= 0 
                              ? TamgaciConstants.primaryColor 
                              : TamgaciConstants.errorColor,
                          isPositive: netBalance >= 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBalanceCard(
                          title: 'Toplam İşlem',
                          amount: (currentMonthIncomes.length + currentMonthExpenses.length).toDouble(),
                          icon: Icons.receipt_long,
                          color: TamgaciConstants.infoColor,
                          isPositive: true,
                          isCount: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => _buildBalanceCardsLoading(),
            error: (error, stack) => _buildBalanceCardsError(error),
          ),
          loading: () => _buildBalanceCardsLoading(),
          error: (error, stack) => _buildBalanceCardsError(error),
        ),
      ],
    );
  }

  /// Bakiye kartları loading
  Widget _buildBalanceCardsLoading() {
    return Row(
      children: [
        Expanded(child: _buildBalanceCardLoading()),
        const SizedBox(width: 16),
        Expanded(child: _buildBalanceCardLoading()),
      ],
    );
  }

  /// Bakiye kartı loading
  Widget _buildBalanceCardLoading() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// Bakiye kartları error
  Widget _buildBalanceCardsError(Object error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: TamgaciConstants.errorColor,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Veriler yüklenirken hata oluştu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bakiye kartı oluşturur
  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required bool isPositive,
    bool isCount = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      TamgaciConstants.radiusSM,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? TamgaciConstants.successColor
                      : TamgaciConstants.errorColor,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isCount 
                  ? '${amount.toInt()}'
                  : '₺${NumberFormat('#,##0.00', 'tr_TR').format(amount.abs())}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isPositive ? color : TamgaciConstants.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hızlı işlemler bölümünü oluşturur
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Gelir Ekle',
                icon: Icons.add_circle_outline,
                color: TamgaciConstants.successColor,
                onTap: () => Navigator.of(context).pushNamed(TamgaciRoutes.createIncome),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Gider Ekle',
                icon: Icons.remove_circle_outline,
                color: TamgaciConstants.errorColor,
                onTap: () => Navigator.of(context).pushNamed(TamgaciRoutes.createExpense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: 'Fatura Oluştur',
                icon: Icons.receipt_long,
                color: TamgaciConstants.primaryColor,
                onTap: () => Navigator.of(context).pushNamed(TamgaciRoutes.createInvoice),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                title: 'Raporlar',
                icon: Icons.bar_chart,
                color: TamgaciConstants.infoColor,
                onTap: () => Navigator.of(context).pushNamed(TamgaciRoutes.reportsOverview),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Hızlı işlem kartı oluşturur
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusSM,
                  ),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Son işlemler bölümünü oluşturur
  Widget _buildRecentTransactions(
    AsyncValue<List<Income>> incomesAsync,
    AsyncValue<List<Expense>> expensesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Son İşlemler',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(TamgaciRoutes.cashTransactions),
              child: Text(
                'Tümünü Gör',
                style: GoogleFonts.poppins(
                  color: TamgaciConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        incomesAsync.when(
          data: (incomes) => expensesAsync.when(
            data: (expenses) {
              // Son 10 işlemi birleştir ve sırala
              final allTransactions = <Map<String, dynamic>>[];
              
              // Gelirleri ekle
              for (final income in incomes.take(5)) {
                allTransactions.add({
                  'title': income.title,
                  'amount': income.amount,
                  'isIncome': true,
                  'date': income.incomeDate,
                  'category': income.categoryName,
                  'type': 'Gelir',
                });
              }
              
              // Giderleri ekle
              for (final expense in expenses.take(5)) {
                allTransactions.add({
                  'title': expense.title,
                  'amount': expense.amount,
                  'isIncome': false,
                  'date': expense.expenseDate,
                  'category': expense.categoryName,
                  'type': 'Gider',
                });
              }
              
              // Tarihe göre sırala (en yeni önce)
              allTransactions.sort((a, b) => b['date'].compareTo(a['date']));
              
              // İlk 10 işlemi al
              final recentTransactions = allTransactions.take(10).toList();
              
              if (recentTransactions.isEmpty) {
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Henüz işlem bulunmuyor'),
                    ),
                  ),
                );
              }
              
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
                ),
                child: Column(
                  children: recentTransactions.map((transaction) {
                    return _buildTransactionItem(
                      title: transaction['title'],
                      amount: transaction['amount'],
                      isIncome: transaction['isIncome'],
                      date: transaction['date'],
                      category: transaction['category'],
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => _buildTransactionsLoading(),
            error: (error, stack) => _buildTransactionsError(error),
          ),
          loading: () => _buildTransactionsLoading(),
          error: (error, stack) => _buildTransactionsError(error),
        ),
      ],
    );
  }

  /// İşlemler loading
  Widget _buildTransactionsLoading() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// İşlemler error
  Widget _buildTransactionsError(Object error) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: TamgaciConstants.errorColor,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'İşlemler yüklenirken hata oluştu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İşlem öğesi oluşturur
  Widget _buildTransactionItem({
    required String title,
    required double amount,
    required bool isIncome,
    required DateTime date,
    required String category,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              (isIncome
                      ? TamgaciConstants.successColor
                      : TamgaciConstants.errorColor)
                  .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),
        child: Icon(
          isIncome ? Icons.add : Icons.remove,
          color: isIncome
              ? TamgaciConstants.successColor
              : TamgaciConstants.errorColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: TamgaciConstants.textPrimary,
        ),
      ),
      subtitle: Text(
        '${DateFormat('dd.MM.yyyy', 'tr_TR').format(date)} • $category',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: TamgaciConstants.textSecondary,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : ''}₺${NumberFormat('#,##0.00', 'tr_TR').format(amount.abs())}',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isIncome
              ? TamgaciConstants.successColor
              : TamgaciConstants.errorColor,
        ),
      ),
    );
  }

  /// İstatistikler bölümünü oluşturur
  Widget _buildStatistics(
    AsyncValue<List<Income>> incomesAsync,
    AsyncValue<List<Expense>> expensesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bu Ay İstatistikleri',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        incomesAsync.when(
          data: (incomes) => expensesAsync.when(
            data: (expenses) {
              final now = DateTime.now();
              final currentMonth = DateTime(now.year, now.month);
              final lastMonth = DateTime(now.year, now.month - 1);
              
              // Bu ay gelirleri
              final currentMonthIncomes = incomes.where((income) {
                final incomeDate = DateTime(
                  income.incomeDate.year,
                  income.incomeDate.month,
                );
                return incomeDate.isAtSameMomentAs(currentMonth);
              }).toList();

              // Bu ay giderleri
              final currentMonthExpenses = expenses.where((expense) {
                final expenseDate = DateTime(
                  expense.expenseDate.year,
                  expense.expenseDate.month,
                );
                return expenseDate.isAtSameMomentAs(currentMonth);
              }).toList();

              // Geçen ay gelirleri
              final lastMonthIncomes = incomes.where((income) {
                final incomeDate = DateTime(
                  income.incomeDate.year,
                  income.incomeDate.month,
                );
                return incomeDate.isAtSameMomentAs(lastMonth);
              }).toList();

              // Geçen ay giderleri
              final lastMonthExpenses = expenses.where((expense) {
                final expenseDate = DateTime(
                  expense.expenseDate.year,
                  expense.expenseDate.month,
                );
                return expenseDate.isAtSameMomentAs(lastMonth);
              }).toList();

              // Toplam hesaplamalar
              final currentMonthIncomeTotal = currentMonthIncomes.fold<double>(
                0, (sum, income) => sum + income.amount,
              );
              final currentMonthExpenseTotal = currentMonthExpenses.fold<double>(
                0, (sum, expense) => sum + expense.amount,
              );
              final lastMonthIncomeTotal = lastMonthIncomes.fold<double>(
                0, (sum, income) => sum + income.amount,
              );
              final lastMonthExpenseTotal = lastMonthExpenses.fold<double>(
                0, (sum, expense) => sum + expense.amount,
              );

              // Yüzde değişim hesaplamaları
              final incomeChangePercent = lastMonthIncomeTotal > 0
                  ? ((currentMonthIncomeTotal - lastMonthIncomeTotal) /
                      lastMonthIncomeTotal *
                      100)
                  : 0.0;
              final expenseChangePercent = lastMonthExpenseTotal > 0
                  ? ((currentMonthExpenseTotal - lastMonthExpenseTotal) /
                      lastMonthExpenseTotal *
                      100)
                  : 0.0;

              final netProfit = currentMonthIncomeTotal - currentMonthExpenseTotal;
              final lastMonthNetProfit = lastMonthIncomeTotal - lastMonthExpenseTotal;
              final netProfitChangePercent = lastMonthNetProfit > 0
                  ? ((netProfit - lastMonthNetProfit) / lastMonthNetProfit * 100)
                  : 0.0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Toplam Gelir',
                          value: '₺${NumberFormat('#,##0', 'tr_TR').format(currentMonthIncomeTotal)}',
                          change: '${incomeChangePercent >= 0 ? '+' : ''}${incomeChangePercent.toStringAsFixed(1)}%',
                          isPositive: incomeChangePercent >= 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Toplam Gider',
                          value: '₺${NumberFormat('#,##0', 'tr_TR').format(currentMonthExpenseTotal)}',
                          change: '${expenseChangePercent >= 0 ? '+' : ''}${expenseChangePercent.toStringAsFixed(1)}%',
                          isPositive: expenseChangePercent < 0, // Gider azalması pozitif
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Net Kar',
                          value: '₺${NumberFormat('#,##0', 'tr_TR').format(netProfit)}',
                          change: '${netProfitChangePercent >= 0 ? '+' : ''}${netProfitChangePercent.toStringAsFixed(1)}%',
                          isPositive: netProfitChangePercent >= 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'İşlem Sayısı',
                          value: '${currentMonthIncomes.length + currentMonthExpenses.length}',
                          change: 'Bu ay',
                          isPositive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => _buildStatisticsLoading(),
            error: (error, stack) => _buildStatisticsError(error),
          ),
          loading: () => _buildStatisticsLoading(),
          error: (error, stack) => _buildStatisticsError(error),
        ),
      ],
    );
  }

  /// İstatistikler loading
  Widget _buildStatisticsLoading() {
    return Row(
      children: [
        Expanded(child: _buildStatCardLoading()),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCardLoading()),
      ],
    );
  }

  /// İstatistik kartı loading
  Widget _buildStatCardLoading() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  /// İstatistikler error
  Widget _buildStatisticsError(Object error) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: TamgaciConstants.errorColor,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'İstatistikler yüklenirken hata oluştu',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// İstatistik kartı oluşturur
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TamgaciConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TamgaciConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive
                      ? TamgaciConstants.successColor
                      : TamgaciConstants.errorColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive
                        ? TamgaciConstants.successColor
                        : TamgaciConstants.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOG METHODS ==========

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İşlem Ekle'),
        content: const Text('Gelir veya gider eklemek için ilgili sayfaya yönlendirileceksiniz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(TamgaciRoutes.createIncome);
            },
            child: const Text('Gelir Ekle'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(TamgaciRoutes.createExpense);
            },
            child: const Text('Gider Ekle'),
          ),
        ],
      ),
    );
  }
}
