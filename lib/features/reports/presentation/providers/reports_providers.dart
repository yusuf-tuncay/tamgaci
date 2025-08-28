// ========== REPORTS PROVIDERS ==========
// lib/features/reports/presentation/providers/reports_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../features/income/presentation/providers/income_providers.dart';
import '../../../../features/expenses/presentation/providers/expense_providers.dart';
import '../../../../features/invoices/presentation/providers/invoice_providers.dart';
import '../../../../features/customers/presentation/providers/customer_providers.dart';
import '../../../../features/suppliers/presentation/providers/supplier_providers.dart';
import '../../../../features/products/presentation/providers/product_providers.dart';

/// Raporlar özet verileri için provider
final reportsSummaryProvider = FutureProvider<ReportsSummary>((ref) async {
  final incomesAsync = await ref.read(incomesProvider.future);
  final expensesAsync = await ref.read(expensesProvider.future);
  final invoicesAsync = await ref.read(invoicesProvider.future);
  final customersAsync = await ref.read(customersProvider.future);
  final suppliersAsync = await ref.read(suppliersProvider.future);
  final productsAsync = await ref.read(productsStreamProvider.future);

  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final lastMonth = DateTime(now.year, now.month - 1);

  // Bu ay verileri
  final currentMonthIncomes = incomesAsync.where((income) {
    final incomeDate = DateTime(
      income.incomeDate.year,
      income.incomeDate.month,
    );
    return incomeDate.isAtSameMomentAs(currentMonth);
  }).toList();

  final currentMonthExpenses = expensesAsync.where((expense) {
    final expenseDate = DateTime(
      expense.expenseDate.year,
      expense.expenseDate.month,
    );
    return expenseDate.isAtSameMomentAs(currentMonth);
  }).toList();

  final currentMonthInvoices = invoicesAsync.where((invoice) {
    final invoiceDate = DateTime(
      invoice.invoiceDate.year,
      invoice.invoiceDate.month,
    );
    return invoiceDate.isAtSameMomentAs(currentMonth);
  }).toList();

  // Geçen ay verileri
  final lastMonthIncomes = incomesAsync.where((income) {
    final incomeDate = DateTime(
      income.incomeDate.year,
      income.incomeDate.month,
    );
    return incomeDate.isAtSameMomentAs(lastMonth);
  }).toList();

  final lastMonthExpenses = expensesAsync.where((expense) {
    final expenseDate = DateTime(
      expense.expenseDate.year,
      expense.expenseDate.month,
    );
    return expenseDate.isAtSameMomentAs(currentMonth);
  }).toList();

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

  final totalTransactions =
      currentMonthIncomes.length +
      currentMonthExpenses.length +
      currentMonthInvoices.length;
  final lastMonthTransactions =
      lastMonthIncomes.length + lastMonthExpenses.length;
  final transactionChangePercent = lastMonthTransactions > 0
      ? ((totalTransactions - lastMonthTransactions) /
            lastMonthTransactions *
            100)
      : 0.0;

  return ReportsSummary(
    totalIncome: currentMonthIncomeTotal,
    totalExpense: currentMonthExpenseTotal,
    netProfit: netProfit,
    totalTransactions: totalTransactions,
    totalCustomers: customersAsync.length,
    totalSuppliers: suppliersAsync.length,
    totalProducts: productsAsync.length,
    incomeChangePercent: incomeChangePercent,
    expenseChangePercent: expenseChangePercent,
    netProfitChangePercent: netProfitChangePercent,
    transactionChangePercent: transactionChangePercent,
  );
});

/// Gelir-gider raporu için provider
final incomeExpenseReportProvider = FutureProvider<IncomeExpenseReport>((
  ref,
) async {
  final incomesAsync = await ref.read(incomesProvider.future);
  final expensesAsync = await ref.read(expensesProvider.future);

  final now = DateTime.now();
  final months = <MonthlyReportData>[];

  // Son 12 ay için veri oluştur
  for (int i = 11; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final monthName = DateFormat('MMM yyyy', 'tr_TR').format(month);

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
      MonthlyReportData(
        month: monthName,
        income: totalIncome,
        expense: totalExpense,
        profit: totalIncome - totalExpense,
        incomeCount: monthIncomes.length,
        expenseCount: monthExpenses.length,
      ),
    );
  }

  // Kategori bazlı analiz
  final incomeCategories = <String, double>{};
  final expenseCategories = <String, double>{};

  for (final income in incomesAsync) {
    final category = income.categoryName;
    incomeCategories[category] =
        (incomeCategories[category] ?? 0) + income.amount;
  }

  for (final expense in expensesAsync) {
    final category = expense.categoryName;
    expenseCategories[category] =
        (expenseCategories[category] ?? 0) + expense.amount;
  }

  return IncomeExpenseReport(
    monthlyData: months,
    incomeCategories: incomeCategories,
    expenseCategories: expenseCategories,
  );
});

/// Müşteri raporu için provider
final customerReportProvider = FutureProvider<CustomerReport>((ref) async {
  final customersAsync = await ref.read(customersProvider.future);
  final invoicesAsync = await ref.read(invoicesProvider.future);

  // Müşteri türü dağılımı
  final customerTypeStats = <String, int>{};
  for (final customer in customersAsync) {
    final type = customer.customerType.displayName;
    customerTypeStats[type] = (customerTypeStats[type] ?? 0) + 1;
  }

  // Müşteri performans analizi
  final customerPerformance = <CustomerPerformance>[];
  for (final customer in customersAsync) {
    final customerInvoices = invoicesAsync
        .where((invoice) => invoice.customerId == customer.id)
        .toList();

    final totalAmount = customerInvoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
    final paidInvoices = customerInvoices
        .where((invoice) => invoice.status.toString().contains('paid'))
        .length;
    final totalInvoices = customerInvoices.length;

    customerPerformance.add(
      CustomerPerformance(
        customerId: customer.id,
        customerName: customer.name,
        totalAmount: totalAmount,
        totalInvoices: totalInvoices,
        paidInvoices: paidInvoices,
        paymentRate: totalInvoices > 0
            ? (paidInvoices / totalInvoices * 100)
            : 0,
      ),
    );
  }

  // Performansa göre sırala
  customerPerformance.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  return CustomerReport(
    totalCustomers: customersAsync.length,
    customerTypeStats: customerTypeStats,
    customerPerformance: customerPerformance,
  );
});

/// Tedarikçi raporu için provider
final supplierReportProvider = FutureProvider<SupplierReport>((ref) async {
  final suppliersAsync = await ref.read(suppliersProvider.future);
  final expensesAsync = await ref.read(expensesProvider.future);

  // Tedarikçi performans analizi
  final supplierPerformance = <SupplierPerformance>[];
  for (final supplier in suppliersAsync) {
    final supplierExpenses = expensesAsync
        .where((expense) => expense.supplierId == supplier.id)
        .toList();

    final totalAmount = supplierExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final expenseCount = supplierExpenses.length;

    supplierPerformance.add(
      SupplierPerformance(
        supplierId: supplier.id,
        supplierName: supplier.name,
        totalAmount: totalAmount,
        expenseCount: expenseCount,
        averageAmount: expenseCount > 0 ? totalAmount / expenseCount : 0,
      ),
    );
  }

  // Tutara göre sırala
  supplierPerformance.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  return SupplierReport(
    totalSuppliers: suppliersAsync.length,
    supplierPerformance: supplierPerformance,
  );
});

/// Ürün raporu için provider
final productReportProvider = FutureProvider<ProductReport>((ref) async {
  final productsAsync = await ref.read(productsStreamProvider.future);
  final invoicesAsync = await ref.read(invoicesProvider.future);

  // Ürün satış analizi
  final productSales = <ProductSales>[];
  for (final product in productsAsync) {
    double totalSales = 0;
    int totalQuantity = 0;

    // Faturalardaki ürün satışlarını hesapla
    for (final invoice in invoicesAsync) {
      for (final item in invoice.items) {
        if (item.productName == product.name) {
          totalSales += item.lineTotal;
          totalQuantity += item.quantity.toInt();
        }
      }
    }

    productSales.add(
      ProductSales(
        productId: product.id?.toString() ?? '',
        productName: product.name,
        totalSales: totalSales,
        totalQuantity: totalQuantity,
        averagePrice: totalQuantity > 0
            ? totalSales / totalQuantity
            : product.unitPrice,
        stockLevel: product.stockQuantity,
      ),
    );
  }

  // Satışa göre sırala
  productSales.sort((a, b) => b.totalSales.compareTo(a.totalSales));

  // Stok durumu analizi
  final lowStockProducts = productsAsync
      .where((product) => product.stockQuantity <= 10)
      .length;

  final outOfStockProducts = productsAsync
      .where((product) => product.stockQuantity == 0)
      .length;

  return ProductReport(
    totalProducts: productsAsync.length,
    productSales: productSales,
    lowStockProducts: lowStockProducts,
    outOfStockProducts: outOfStockProducts,
  );
});

/// Raporlar özet veri modeli
class ReportsSummary {
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final int totalTransactions;
  final int totalCustomers;
  final int totalSuppliers;
  final int totalProducts;
  final double incomeChangePercent;
  final double expenseChangePercent;
  final double netProfitChangePercent;
  final double transactionChangePercent;

  ReportsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.totalTransactions,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.totalProducts,
    required this.incomeChangePercent,
    required this.expenseChangePercent,
    required this.netProfitChangePercent,
    required this.transactionChangePercent,
  });

  String get formattedTotalIncome =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalIncome);

  String get formattedTotalExpense =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalExpense);

  String get formattedNetProfit =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(netProfit);

  String get formattedIncomeChange =>
      '${incomeChangePercent >= 0 ? '+' : ''}${incomeChangePercent.toStringAsFixed(1)}%';

  String get formattedExpenseChange =>
      '${expenseChangePercent >= 0 ? '+' : ''}${expenseChangePercent.toStringAsFixed(1)}%';

  String get formattedNetProfitChange =>
      '${netProfitChangePercent >= 0 ? '+' : ''}${netProfitChangePercent.toStringAsFixed(1)}%';

  String get formattedTransactionChange =>
      '${transactionChangePercent >= 0 ? '+' : ''}${transactionChangePercent.toStringAsFixed(1)}%';
}

/// Aylık rapor veri modeli
class MonthlyReportData {
  final String month;
  final double income;
  final double expense;
  final double profit;
  final int incomeCount;
  final int expenseCount;

  MonthlyReportData({
    required this.month,
    required this.income,
    required this.expense,
    required this.profit,
    required this.incomeCount,
    required this.expenseCount,
  });

  String get formattedIncome =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(income);

  String get formattedExpense =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(expense);

  String get formattedProfit =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(profit);
}

/// Gelir-gider raporu modeli
class IncomeExpenseReport {
  final List<MonthlyReportData> monthlyData;
  final Map<String, double> incomeCategories;
  final Map<String, double> expenseCategories;

  IncomeExpenseReport({
    required this.monthlyData,
    required this.incomeCategories,
    required this.expenseCategories,
  });
}

/// Müşteri performans modeli
class CustomerPerformance {
  final String customerId;
  final String customerName;
  final double totalAmount;
  final int totalInvoices;
  final int paidInvoices;
  final double paymentRate;

  CustomerPerformance({
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.totalInvoices,
    required this.paidInvoices,
    required this.paymentRate,
  });

  String get formattedTotalAmount =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalAmount);

  String get formattedPaymentRate => '${paymentRate.toStringAsFixed(1)}%';
}

/// Müşteri raporu modeli
class CustomerReport {
  final int totalCustomers;
  final Map<String, int> customerTypeStats;
  final List<CustomerPerformance> customerPerformance;

  CustomerReport({
    required this.totalCustomers,
    required this.customerTypeStats,
    required this.customerPerformance,
  });
}

/// Tedarikçi performans modeli
class SupplierPerformance {
  final String supplierId;
  final String supplierName;
  final double totalAmount;
  final int expenseCount;
  final double averageAmount;

  SupplierPerformance({
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    required this.expenseCount,
    required this.averageAmount,
  });

  String get formattedTotalAmount =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalAmount);

  String get formattedAverageAmount =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(averageAmount);
}

/// Tedarikçi raporu modeli
class SupplierReport {
  final int totalSuppliers;
  final List<SupplierPerformance> supplierPerformance;

  SupplierReport({
    required this.totalSuppliers,
    required this.supplierPerformance,
  });
}

/// Ürün satış modeli
class ProductSales {
  final String productId;
  final String productName;
  final double totalSales;
  final int totalQuantity;
  final double averagePrice;
  final int stockLevel;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.totalSales,
    required this.totalQuantity,
    required this.averagePrice,
    required this.stockLevel,
  });

  String get formattedTotalSales =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(totalSales);

  String get formattedAveragePrice =>
      NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(averagePrice);
}

/// Ürün raporu modeli
class ProductReport {
  final int totalProducts;
  final List<ProductSales> productSales;
  final int lowStockProducts;
  final int outOfStockProducts;

  ProductReport({
    required this.totalProducts,
    required this.productSales,
    required this.lowStockProducts,
    required this.outOfStockProducts,
  });
}
