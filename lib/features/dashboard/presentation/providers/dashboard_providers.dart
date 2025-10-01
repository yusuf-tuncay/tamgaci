// ========== DASHBOARD PROVIDERS ==========
// lib/features/dashboard/presentation/providers/dashboard_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Silinen modül: income
// Silinen modül: expenses
import '../../../../features/invoices/presentation/providers/invoice_providers.dart';
import '../../../../features/customers/presentation/providers/customer_providers.dart';
import '../../../../features/suppliers/presentation/providers/supplier_providers.dart';
import '../../../../features/products/presentation/providers/product_providers.dart';
// Silinen modül: payments

import '../../data/services/date_time_service.dart';
import '../../data/services/stock_market_service.dart';
import '../../domain/entities/dashboard_summary.dart';

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
    // Silinen modül: income
    // Silinen modül: expenses
    // final invoicesAsync = await ref.read(invoicesProvider.future);
    final customersAsync = await ref.read(customersProvider.future);
    final suppliersAsync = await ref.read(suppliersProvider.future);
    final productsAsync = await ref.read(productsStreamProvider.future);
    // Silinen modül: payments

    // Silinen modüller nedeniyle tarih hesaplamaları kullanılmıyor

    // Silinen modül: income
    final currentMonthIncomes = <dynamic>[];

    // Silinen modül: expenses
    final currentMonthExpenses = <dynamic>[];

    // Silinen modül: payments
    final currentMonthPayments = <dynamic>[];

    // Silinen modül: payments
    final lastMonthPayments = <dynamic>[];

    // Silinen modül: income
    final lastMonthIncomes = <dynamic>[];

    // Bekleyen faturalar
    // final pendingInvoices = invoicesAsync
    //     .where(
    //       (invoice) =>
    //           invoice.status.toString().contains('sent') ||
    //           invoice.status.toString().contains('unpaid'),
    //     )
    //     .toList();

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

    // Tahsilat toplamları
    final currentMonthPaymentTotal = currentMonthPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final lastMonthPaymentTotal = lastMonthPayments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    // Yüzde değişim hesaplamaları
    final incomeChangePercent = lastMonthIncomeTotal > 0
        ? ((currentMonthIncomeTotal - lastMonthIncomeTotal) /
            lastMonthIncomeTotal *
            100)
        : 0.0;
    // final expenseChangePercent = lastMonthExpenseTotal > 0
    //     ? ((currentMonthExpenseTotal - lastMonthExpenseTotal) /
    //         lastMonthExpenseTotal *
    //         100)
    //     : 0.0;

    final netProfit = currentMonthIncomeTotal - currentMonthExpenseTotal;

    // Tahsilat büyüme oranı
    final paymentGrowthRate = lastMonthPaymentTotal > 0
        ? ((currentMonthPaymentTotal - lastMonthPaymentTotal) /
            lastMonthPaymentTotal *
            100)
        : 0.0;

    return DashboardSummary(
      totalSales: currentMonthIncomeTotal,
      totalPurchases: currentMonthExpenseTotal,
      totalIncome: currentMonthIncomeTotal,
      totalExpenses: currentMonthExpenseTotal,
      netProfit: netProfit,
      cashBalance: 50000.0, // Mock data
      bankBalance: 75000.0, // Mock data
      totalBalance: 125000.0, // Mock data
      criticalStockCount: 5,
      pendingReceivables: 25000.0, // Mock data
      pendingPayables: 15000.0, // Mock data
      monthlySales: currentMonthIncomeTotal,
      lastMonthSales: lastMonthIncomeTotal,
      salesGrowthRate: incomeChangePercent,
      totalCustomers: customersAsync.length,
      totalSuppliers: suppliersAsync.length,
      totalProducts: productsAsync.length,
      newCustomersThisMonth: 3, // Mock data
      newSuppliersThisMonth: 2, // Mock data
      // Tahsilat verileri
      totalPayments: currentMonthPaymentTotal,
      paymentGrowthRate: paymentGrowthRate,
    );
  } catch (e) {
    // Hata durumunda test verileri döndür
    return const DashboardSummary(
      totalSales: 125000.0,
      totalPurchases: 85000.0,
      totalIncome: 125000.0,
      totalExpenses: 85000.0,
      netProfit: 40000.0,
      cashBalance: 50000.0,
      bankBalance: 75000.0,
      totalBalance: 125000.0,
      criticalStockCount: 5,
      pendingReceivables: 25000.0,
      pendingPayables: 15000.0,
      monthlySales: 125000.0,
      lastMonthSales: 110000.0,
      salesGrowthRate: 15.5,
      totalCustomers: 12,
      totalSuppliers: 8,
      totalProducts: 45,
      newCustomersThisMonth: 3,
      newSuppliersThisMonth: 2,
      totalPayments: 0.0,
      paymentGrowthRate: 0.0,
    );
  }
});

/// Son işlemler için provider
final recentTransactionsProvider = FutureProvider<List<TransactionItem>>((
  ref,
) async {
  try {
    // Silinen modül: income
    // Silinen modül: expenses
    final invoicesAsync = await ref.read(invoicesProvider.future);
    // Silinen modül: payments

    final allTransactions = <TransactionItem>[];

    // Silinen modül: income

    // Silinen modül: expenses

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

    // Silinen modül: payments

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
    // Silinen modül: income
    // Silinen modül: expenses

    final now = DateTime.now();
    final months = <MonthlyChartData>[];

    // Son 6 ay için veri oluştur
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthName = DateFormat('MMM', 'tr_TR').format(month);

      // Silinen modül: income
      final monthIncomes = <dynamic>[];

      // Bu ay için giderleri topla
      // Silinen modül: expenses
      final monthExpenses = <dynamic>[];

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

/// İşlem türü enum'u
enum TransactionType { income, expense, invoice, payment }

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
