// ========== DASHBOARD PROVIDERS ==========
// lib/features/dashboard/presentation/providers/dashboard_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../features/income/presentation/providers/income_providers.dart';
import '../../../../features/expenses/presentation/providers/expense_providers.dart';
import '../../../../features/invoices/presentation/providers/invoice_providers.dart';
import '../../../../features/customers/presentation/providers/customer_providers.dart';
import '../../../../features/suppliers/presentation/providers/supplier_providers.dart';
import '../../../../features/products/presentation/providers/product_providers.dart';

import '../../data/services/date_time_service.dart';
import '../../data/services/stock_market_service.dart';

/// Güncel tarih ve saat provider'ı (her 500ms'de güncellenir)
final currentDateTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(milliseconds: 500),
    (_) => DateTimeService.getCurrentDateTime(),
  ).asyncMap((_) => DateTimeService.getCurrentDateTime());
});

/// Borsa verileri provider'ı (her 30 saniyede güncellenir)
final stockMarketDataProvider = StreamProvider<StockMarketData>((ref) {
  return Stream.periodic(
    const Duration(seconds: 30),
    (_) => StockMarketService.getStockMarketData(),
  ).asyncMap((_) => StockMarketService.getStockMarketData());
});

/// Döviz grafik verileri provider'ı (her 1 dakikada güncellenir)
final currencyChartDataProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Stream.periodic(
    const Duration(minutes: 1),
    (_) => StockMarketService.getCurrencyChartData(),
  ).asyncMap((_) => StockMarketService.getCurrencyChartData());
});

/// Dashboard özet verileri için provider
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  try {
    final incomesAsync = await ref.read(incomesProvider.future);
    final expensesAsync = await ref.read(expensesProvider.future);
    final invoicesAsync = await ref.read(invoicesProvider.future);
    final customersAsync = await ref.read(customersProvider.future);
    final suppliersAsync = await ref.read(suppliersProvider.future);
    final productsAsync = await ref.read(productsStreamProvider.future);

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // Bu ay gelirleri
    final currentMonthIncomes = incomesAsync.where((income) {
      final incomeDate = DateTime(
        income.incomeDate.year,
        income.incomeDate.month,
      );
      return incomeDate.isAtSameMomentAs(currentMonth);
    }).toList();

    // Bu ay giderleri
    final currentMonthExpenses = expensesAsync.where((expense) {
      final expenseDate = DateTime(
        expense.expenseDate.year,
        expense.expenseDate.month,
      );
      return expenseDate.isAtSameMomentAs(currentMonth);
    }).toList();

    // Geçen ay gelirleri
    final lastMonthIncomes = incomesAsync.where((income) {
      final incomeDate = DateTime(
        income.incomeDate.year,
        income.incomeDate.month,
      );
      return incomeDate.isAtSameMomentAs(lastMonth);
    }).toList();

    // Geçen ay giderleri
    final lastMonthExpenses = expensesAsync.where((expense) {
      final expenseDate = DateTime(
        expense.expenseDate.year,
        expense.expenseDate.month,
      );
      return expenseDate.isAtSameMomentAs(lastMonth);
    }).toList();

    // Bekleyen faturalar
    final pendingInvoices = invoicesAsync
        .where(
          (invoice) =>
              invoice.status.toString().contains('sent') ||
              invoice.status.toString().contains('unpaid'),
        )
        .toList();

    // Toplam hesaplamalar
    final currentMonthIncomeTotal = currentMonthIncomes.fold<double>(
      0,
      (sum, income) => sum + income.amount,
    );
    final currentMonthExpenseTotal = currentMonthExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final lastMonthIncomeTotal = lastMonthIncomes.fold<double>(
      0,
      (sum, income) => sum + income.amount,
    );
    final lastMonthExpenseTotal = lastMonthExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
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

    return DashboardSummary(
      currentMonthIncome: currentMonthIncomeTotal,
      currentMonthExpense: currentMonthExpenseTotal,
      netProfit: netProfit,
      pendingInvoicesCount: pendingInvoices.length,
      totalCustomers: customersAsync.length,
      totalSuppliers: suppliersAsync.length,
      totalProducts: productsAsync.length,
      incomeChangePercent: incomeChangePercent,
      expenseChangePercent: expenseChangePercent,
      netProfitChangePercent: netProfitChangePercent,
      // Inventory test verileri (geçici)
      lowStockCount: 5,
      outOfStockCount: 2,
      totalStockValue: 125000.0,
      warehouseCount: 3,
      recentMovementCount: 8,
    );
  } catch (e) {
    // Hata durumunda test verileri döndür
    return DashboardSummary(
      currentMonthIncome: 125000.0,
      currentMonthExpense: 85000.0,
      netProfit: 40000.0,
      pendingInvoicesCount: 5,
      totalCustomers: 12,
      totalSuppliers: 8,
      totalProducts: 45,
      incomeChangePercent: 15.5,
      expenseChangePercent: -8.2,
      netProfitChangePercent: 23.7,
      // Inventory test verileri
      lowStockCount: 5,
      outOfStockCount: 2,
      totalStockValue: 125000.0,
      warehouseCount: 3,
      recentMovementCount: 8,
    );
  }
});

/// Son işlemler için provider
final recentTransactionsProvider = FutureProvider<List<TransactionItem>>((
  ref,
) async {
  try {
    final incomesAsync = await ref.read(incomesProvider.future);
    final expensesAsync = await ref.read(expensesProvider.future);
    final invoicesAsync = await ref.read(invoicesProvider.future);

    final allTransactions = <TransactionItem>[];

    // Gelirleri ekle
    for (final income in incomesAsync.take(10)) {
      allTransactions.add(
        TransactionItem(
          id: income.id,
          title: income.title,
          amount: income.amount,
          type: TransactionType.income,
          date: income.incomeDate,
          description: income.description ?? '',
        ),
      );
    }

    // Giderleri ekle
    for (final expense in expensesAsync.take(10)) {
      allTransactions.add(
        TransactionItem(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          type: TransactionType.expense,
          date: expense.expenseDate,
          description: expense.description ?? '',
        ),
      );
    }

    // Faturaları ekle
    for (final invoice in invoicesAsync.take(10)) {
      allTransactions.add(
        TransactionItem(
          id: invoice.id,
          title: 'Fatura: ${invoice.invoiceNumber}',
          amount: invoice.totalAmount,
          type: TransactionType.invoice,
          date: invoice.invoiceDate,
          description:
              '${invoice.customer?.name ?? 'Müşteri'} - ${invoice.status.displayName}',
        ),
      );
    }

    // Tarihe göre sırala (en yeni önce)
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    return allTransactions.take(10).toList();
  } catch (e) {
    // Hata durumunda test verileri döndür
    final now = DateTime.now();
    return [
      TransactionItem(
        id: 'income_1',
        title: 'Müşteri Ödemesi',
        amount: 15000.0,
        type: TransactionType.income,
        date: now.subtract(const Duration(hours: 2)),
        description: 'ABC Şirketi ödemesi',
      ),
      TransactionItem(
        id: 'expense_1',
        title: 'Ofis Kirası',
        amount: 8000.0,
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 4)),
        description: 'Aralık ayı ofis kirası',
      ),
      TransactionItem(
        id: 'invoice_1',
        title: 'Fatura: INV-2024-001',
        amount: 25000.0,
        type: TransactionType.invoice,
        date: now.subtract(const Duration(days: 1)),
        description: 'XYZ Ltd. - Ödendi',
      ),
      TransactionItem(
        id: 'income_2',
        title: 'Danışmanlık Hizmeti',
        amount: 12000.0,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 2)),
        description: 'Proje danışmanlığı',
      ),
      TransactionItem(
        id: 'expense_2',
        title: 'İnternet Faturası',
        amount: 350.0,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        description: 'Aralık internet faturası',
      ),
    ];
  }
});

/// Aylık gelir-gider grafiği için provider
final monthlyChartDataProvider = FutureProvider<List<MonthlyChartData>>((
  ref,
) async {
  try {
    final incomesAsync = await ref.read(incomesProvider.future);
    final expensesAsync = await ref.read(expensesProvider.future);

    final now = DateTime.now();
    final months = <MonthlyChartData>[];

    // Son 6 ay için veri oluştur
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthName = DateFormat('MMM', 'tr_TR').format(month);

      // Bu ay için gelirleri topla
      final monthIncomes = incomesAsync.where((income) {
        final incomeDate = DateTime(
          income.incomeDate.year,
          income.incomeDate.month,
        );
        return incomeDate.isAtSameMomentAs(month);
      }).toList();

      // Bu ay için giderleri topla
      final monthExpenses = expensesAsync.where((expense) {
        final expenseDate = DateTime(
          expense.expenseDate.year,
          expense.expenseDate.month,
        );
        return expenseDate.isAtSameMomentAs(month);
      }).toList();

      final totalIncome = monthIncomes.fold<double>(
        0,
        (sum, income) => sum + income.amount,
      );
      final totalExpense = monthExpenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      months.add(
        MonthlyChartData(
          month: monthName,
          income: totalIncome,
          expense: totalExpense,
          profit: totalIncome - totalExpense,
        ),
      );
    }

    return months;
  } catch (e) {
    // Hata durumunda test verileri döndür
    final now = DateTime.now();
    return [
      MonthlyChartData(
        month: DateFormat(
          'MMM',
          'tr_TR',
        ).format(DateTime(now.year, now.month - 5)),
        income: 95000.0,
        expense: 65000.0,
        profit: 30000.0,
      ),
      MonthlyChartData(
        month: DateFormat(
          'MMM',
          'tr_TR',
        ).format(DateTime(now.year, now.month - 4)),
        income: 110000.0,
        expense: 70000.0,
        profit: 40000.0,
      ),
      MonthlyChartData(
        month: DateFormat(
          'MMM',
          'tr_TR',
        ).format(DateTime(now.year, now.month - 3)),
        income: 105000.0,
        expense: 75000.0,
        profit: 30000.0,
      ),
      MonthlyChartData(
        month: DateFormat(
          'MMM',
          'tr_TR',
        ).format(DateTime(now.year, now.month - 2)),
        income: 120000.0,
        expense: 80000.0,
        profit: 40000.0,
      ),
      MonthlyChartData(
        month: DateFormat(
          'MMM',
          'tr_TR',
        ).format(DateTime(now.year, now.month - 1)),
        income: 115000.0,
        expense: 85000.0,
        profit: 30000.0,
      ),
      MonthlyChartData(
        month: DateFormat('MMM', 'tr_TR').format(now),
        income: 125000.0,
        expense: 85000.0,
        profit: 40000.0,
      ),
    ];
  }
});

/// Dashboard özet modeli
class DashboardSummary {
  final double currentMonthIncome;
  final double currentMonthExpense;
  final double netProfit;
  final int pendingInvoicesCount;
  final int totalCustomers;
  final int totalSuppliers;
  final int totalProducts;
  final double incomeChangePercent;
  final double expenseChangePercent;
  final double netProfitChangePercent;
  // Inventory alanları
  final int lowStockCount;
  final int outOfStockCount;
  final double totalStockValue;
  final int warehouseCount;
  final int recentMovementCount;

  DashboardSummary({
    required this.currentMonthIncome,
    required this.currentMonthExpense,
    required this.netProfit,
    required this.pendingInvoicesCount,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.totalProducts,
    required this.incomeChangePercent,
    required this.expenseChangePercent,
    required this.netProfitChangePercent,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalStockValue,
    required this.warehouseCount,
    required this.recentMovementCount,
  });

  String get formattedCurrentMonthIncome => NumberFormat.currency(
        locale: 'tr_TR',
        symbol: '₺',
      ).format(currentMonthIncome);

  String get formattedCurrentMonthExpense => NumberFormat.currency(
        locale: 'tr_TR',
        symbol: '₺',
      ).format(currentMonthExpense);

  String get formattedNetProfit =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(netProfit);

  String get formattedIncomeChange =>
      '${incomeChangePercent >= 0 ? '+' : ''}${incomeChangePercent.toStringAsFixed(1)}%';

  String get formattedExpenseChange =>
      '${expenseChangePercent >= 0 ? '+' : ''}${expenseChangePercent.toStringAsFixed(1)}%';

  String get formattedNetProfitChange =>
      '${netProfitChangePercent >= 0 ? '+' : ''}${netProfitChangePercent.toStringAsFixed(1)}%';

  // Inventory formatlanmış getter'ları
  String get formattedTotalStockValue => NumberFormat.currency(
        locale: 'tr_TR',
        symbol: '₺',
      ).format(totalStockValue);

  String get formattedLowStockCount => '$lowStockCount ürün';

  String get formattedOutOfStockCount => '$outOfStockCount ürün';

  String get formattedWarehouseCount => '$warehouseCount depo';

  String get formattedRecentMovementCount => '$recentMovementCount hareket';
}

/// İşlem türü enum'u
enum TransactionType { income, expense, invoice }

/// İşlem öğesi modeli
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String description;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
  });

  String get formattedAmount =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(amount);

  String get formattedDate => DateFormat('dd MMM, HH:mm', 'tr_TR').format(date);

  String get formattedAmountWithSign {
    final sign = type == TransactionType.expense ? '-' : '+';
    return '$sign$formattedAmount';
  }
}

/// Aylık grafik veri modeli
class MonthlyChartData {
  final String month;
  final double income;
  final double expense;
  final double profit;

  MonthlyChartData({
    required this.month,
    required this.income,
    required this.expense,
    required this.profit,
  });

  String get formattedIncome =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(income);

  String get formattedExpense =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(expense);

  String get formattedProfit =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(profit);
}
