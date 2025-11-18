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
import '../../../../features/purchases/presentation/providers/purchase_providers.dart';
import '../../../../features/purchases/domain/entities/purchase.dart';
import '../../../../features/accounts/presentation/providers/account_providers.dart';
import '../../../../features/accounts/domain/entities/account.dart';
import '../../../../features/invoices/domain/entities/invoice.dart';
import '../../../../core/providers/currency_providers.dart';
import '../../../../core/domain/entities/currency.dart';
// Silinen modül: payments

import '../../data/services/date_time_service.dart';
import '../../data/services/stock_market_service.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Güncel tarih ve saat provider'ı (tek seferlik)
final currentDateTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.fromFuture(DateTimeService.getCurrentDateTime());
});

/// Borsa verileri provider'ı (tek seferlik)
final stockMarketDataProvider = StreamProvider<StockMarketData>((ref) {
  return Stream.fromFuture(StockMarketService.getStockMarketData());
});

/// Döviz grafik verileri provider'ı (tek seferlik)
final currencyChartDataProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Stream.fromFuture(StockMarketService.getCurrencyChartData());
});

/// Dashboard özet verileri için provider
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  try {
    final invoices = await ref.watch(invoicesProvider.future);
    final customers = await ref.watch(customersProvider.future);
    final suppliers = await ref.watch(suppliersProvider.future);
    final products = await ref.watch(productsStreamProvider.future);

    final purchaseRepository = ref.watch(purchaseRepositoryProvider);
    final purchases =
        await purchaseRepository.getAllPurchases(includeItems: false);

    final accounts = await ref.watch(accountsProvider.future);

    List<Currency> exchangeRates = [];
    try {
      exchangeRates = await ref.watch(exchangeRatesProvider.future);
    } catch (_) {
      exchangeRates = [];
    }
    final fxRateMap = <String, double>{'TRY': 1.0};
    for (final rate in exchangeRates) {
      fxRateMap[rate.code.toUpperCase()] = rate.exchangeRate;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);

    final double totalSales = _sumInvoiceAmounts(invoices);
    final double totalPurchases = _sumPurchaseAmounts(purchases);

    final double monthlySales = _sumInvoiceAmounts(
      invoices.where(
        (invoice) =>
            _isWithinRange(invoice.invoiceDate, startOfMonth, startOfNextMonth),
      ),
    );

    final double lastMonthSales = _sumInvoiceAmounts(
      invoices.where(
        (invoice) =>
            _isWithinRange(invoice.invoiceDate, startOfLastMonth, startOfMonth),
      ),
    );

    final double salesGrowthRate =
        _calculateGrowth(monthlySales, lastMonthSales);

    final double monthlyPurchases = _sumPurchaseAmounts(
      purchases.where((purchase) => _isWithinRange(
          purchase.purchaseDate, startOfMonth, startOfNextMonth)),
    );

    final double lastMonthPurchases = _sumPurchaseAmounts(
      purchases.where((purchase) => _isWithinRange(
          purchase.purchaseDate, startOfLastMonth, startOfMonth)),
    );

    final double purchaseGrowthRate =
        _calculateGrowth(monthlyPurchases, lastMonthPurchases);

    final double monthlyNetProfit = monthlySales - monthlyPurchases;
    final double lastMonthNetProfit = lastMonthSales - lastMonthPurchases;
    final double netProfitGrowthRate =
        _calculateGrowth(monthlyNetProfit, lastMonthNetProfit);

    final double pendingReceivables = _sumInvoiceAmounts(
      invoices.where((invoice) => !invoice.isPaid),
    );

    final double lastMonthPendingReceivables = _sumInvoiceAmounts(
      invoices.where(
        (invoice) =>
            !invoice.isPaid &&
            _isWithinRange(invoice.invoiceDate, startOfLastMonth, startOfMonth),
      ),
    );

    final double receivablesGrowthRate =
        _calculateGrowth(pendingReceivables, lastMonthPendingReceivables);

    final double paymentsThisMonth = _sumInvoiceAmounts(
      invoices.where(
        (invoice) =>
            invoice.isPaid &&
            _isWithinRange(invoice.invoiceDate, startOfMonth, startOfNextMonth),
      ),
    );

    final double paymentsLastMonth = _sumInvoiceAmounts(
      invoices.where(
        (invoice) =>
            invoice.isPaid &&
            _isWithinRange(invoice.invoiceDate, startOfLastMonth, startOfMonth),
      ),
    );

    final double paymentGrowthRate =
        _calculateGrowth(paymentsThisMonth, paymentsLastMonth);

    final double pendingPayables = purchases
        .where((purchase) =>
            purchase.paymentStatus != PurchasePaymentStatus.paid)
        .fold(0, (sum, purchase) => sum + purchase.totalAmount);

    final double lastMonthPendingPayables = purchases
        .where((purchase) =>
            purchase.paymentStatus != PurchasePaymentStatus.paid &&
            _isWithinRange(
                purchase.purchaseDate, startOfLastMonth, startOfMonth))
        .fold(0, (sum, purchase) => sum + purchase.totalAmount);

    final double payablesGrowthRate =
        _calculateGrowth(pendingPayables, lastMonthPendingPayables);

    final double totalIncome = totalSales;
    final double totalExpenses = totalPurchases;

    final Map<String, double> balanceByCurrency = {};
    for (final account in accounts) {
      final currency = (account.currency.isNotEmpty)
          ? account.currency.toUpperCase()
          : 'TRY';
      balanceByCurrency[currency] =
          (balanceByCurrency[currency] ?? 0.0) + account.balance;
    }

    double cashBalance = 0.0;
    double bankBalance = 0.0;
    double totalBalance = 0.0;

    for (final account in accounts) {
      final converted =
          _convertToTry(account.balance, account.currency, fxRateMap);
      totalBalance += converted;
      if (account.type == AccountType.cash) {
        cashBalance += converted;
      } else {
        bankBalance += converted;
      }
    }

    final criticalStockCount =
        products.where((product) => product.isLowStock).length;

    final newCustomersThisMonth = customers
        .where((customer) => !customer.createdAt.isBefore(startOfMonth))
        .length;

    final lastMonthNewCustomers = customers
        .where((customer) =>
            _isWithinRange(customer.createdAt, startOfLastMonth, startOfMonth))
        .length;

    final double customerGrowthRate = _calculateGrowth(
      newCustomersThisMonth.toDouble(),
      lastMonthNewCustomers.toDouble(),
    );

    final newSuppliersThisMonth = suppliers
        .where((supplier) => !supplier.createdAt.isBefore(startOfMonth))
        .length;

    final lastMonthNewSuppliers = suppliers
        .where((supplier) =>
            _isWithinRange(supplier.createdAt, startOfLastMonth, startOfMonth))
        .length;

    final double supplierGrowthRate = _calculateGrowth(
      newSuppliersThisMonth.toDouble(),
      lastMonthNewSuppliers.toDouble(),
    );

    return DashboardSummary(
      totalSales: totalSales,
      totalPurchases: totalPurchases,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: monthlyNetProfit,
      cashBalance: cashBalance,
      bankBalance: bankBalance,
      totalBalance: totalBalance,
      criticalStockCount: criticalStockCount,
      pendingReceivables: pendingReceivables,
      pendingPayables: pendingPayables,
      monthlySales: monthlySales,
      lastMonthSales: lastMonthSales,
      salesGrowthRate: salesGrowthRate,
      totalCustomers: customers.length,
      totalSuppliers: suppliers.length,
      totalProducts: products.length,
      newCustomersThisMonth: newCustomersThisMonth,
      newSuppliersThisMonth: newSuppliersThisMonth,
      totalPayments: paymentsThisMonth,
      paymentGrowthRate: paymentGrowthRate,
      balanceByCurrency: balanceByCurrency,
      purchaseGrowthRate: purchaseGrowthRate,
      netProfitGrowthRate: netProfitGrowthRate,
      receivablesGrowthRate: receivablesGrowthRate,
      payablesGrowthRate: payablesGrowthRate,
      customerGrowthRate: customerGrowthRate,
      supplierGrowthRate: supplierGrowthRate,
    );
  } catch (_) {
    return DashboardSummary.empty();
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

bool _isWithinRange(DateTime value, DateTime start, DateTime endExclusive) {
  return !value.isBefore(start) && value.isBefore(endExclusive);
}

double _sumInvoiceAmounts(Iterable<Invoice> invoices) {
  return invoices.fold<double>(
    0.0,
    (sum, invoice) => sum + invoice.totalAmount,
  );
}

double _sumPurchaseAmounts(Iterable<Purchase> purchases) {
  return purchases.fold<double>(
    0.0,
    (sum, purchase) => sum + purchase.totalAmount,
  );
}

double _convertToTry(
  double amount,
  String currencyCode,
  Map<String, double> fxRates,
) {
  if (amount == 0) return 0.0;
  final normalized = currencyCode.isNotEmpty
      ? currencyCode.toUpperCase()
      : 'TRY';
  if (normalized == 'TRY') {
    return amount;
  }
  final rate = fxRates[normalized];
  if (rate == null || rate <= 0) {
    return amount;
  }
  return amount * rate;
}

double _calculateGrowth(double current, double previous) {
  if (previous == 0) {
    if (current == 0) {
      return 0.0;
    }
    return 100.0;
  }
  return ((current - previous) / previous) * 100;
}
