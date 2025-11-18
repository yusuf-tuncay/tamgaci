// ========== DASHBOARD SUMMARY ENTITY ==========
// lib/features/dashboard/domain/entities/dashboard_summary.dart

/// Dashboard özet bilgileri entity'si
class DashboardSummary {
  /// Toplam satış tutarı
  final double totalSales;

  /// Toplam alış tutarı
  final double totalPurchases;

  /// Toplam gelir
  final double totalIncome;

  /// Toplam gider
  final double totalExpenses;

  /// Net kar/zarar
  final double netProfit;

  /// Kasa bakiyesi
  final double cashBalance;

  /// Banka bakiyesi
  final double bankBalance;

  /// Toplam bakiye
  final double totalBalance;

  /// Kritik stok seviyesindeki ürün sayısı
  final int criticalStockCount;

  /// Bekleyen tahsilat tutarı
  final double pendingReceivables;

  /// Bekleyen ödeme tutarı
  final double pendingPayables;

  /// Bu ay satış tutarı
  final double monthlySales;

  /// Geçen ay satış tutarı
  final double lastMonthSales;

  /// Satış artış oranı (%)
  final double salesGrowthRate;

  /// Toplam müşteri sayısı
  final int totalCustomers;

  /// Toplam tedarikçi sayısı
  final int totalSuppliers;

  /// Toplam ürün sayısı
  final int totalProducts;

  /// Bu ay yeni müşteri sayısı
  final int newCustomersThisMonth;

  /// Bu ay yeni tedarikçi sayısı
  final int newSuppliersThisMonth;

  /// Toplam tahsilat tutarı
  final double totalPayments;

  /// Tahsilat büyüme oranı (%)
  final double paymentGrowthRate;

  /// Alış büyüme oranı (%)
  final double purchaseGrowthRate;

  /// Net kar büyüme oranı (%)
  final double netProfitGrowthRate;

  /// Para birimine göre toplam bakiyeler
  final Map<String, double>? balanceByCurrency;

  /// Bekleyen tahsilat değişim oranı (%)
  final double receivablesGrowthRate;

  /// Bekleyen ödeme değişim oranı (%)
  final double payablesGrowthRate;

  /// Müşteri büyüme oranı (%)
  final double customerGrowthRate;

  /// Tedarikçi büyüme oranı (%)
  final double supplierGrowthRate;

  const DashboardSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.cashBalance,
    required this.bankBalance,
    required this.totalBalance,
    required this.criticalStockCount,
    required this.pendingReceivables,
    required this.pendingPayables,
    required this.monthlySales,
    required this.lastMonthSales,
    required this.salesGrowthRate,
    required this.totalCustomers,
    required this.totalSuppliers,
    required this.totalProducts,
    required this.newCustomersThisMonth,
    required this.newSuppliersThisMonth,
    required this.totalPayments,
    required this.paymentGrowthRate,
    required this.balanceByCurrency,
    required this.purchaseGrowthRate,
    required this.netProfitGrowthRate,
    required this.receivablesGrowthRate,
    required this.payablesGrowthRate,
    required this.customerGrowthRate,
    required this.supplierGrowthRate,
  });

  /// DashboardSummary kopyalama metodu
  DashboardSummary copyWith({
    double? totalSales,
    double? totalPurchases,
    double? totalIncome,
    double? totalExpenses,
    double? netProfit,
    double? cashBalance,
    double? bankBalance,
    double? totalBalance,
    int? criticalStockCount,
    double? pendingReceivables,
    double? pendingPayables,
    double? monthlySales,
    double? lastMonthSales,
    double? salesGrowthRate,
    int? totalCustomers,
    int? totalSuppliers,
    int? totalProducts,
    int? newCustomersThisMonth,
    int? newSuppliersThisMonth,
    double? totalPayments,
    double? paymentGrowthRate,
    Map<String, double>? balanceByCurrency,
    double? purchaseGrowthRate,
    double? netProfitGrowthRate,
    double? receivablesGrowthRate,
    double? payablesGrowthRate,
    double? customerGrowthRate,
    double? supplierGrowthRate,
  }) {
    return DashboardSummary(
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      cashBalance: cashBalance ?? this.cashBalance,
      bankBalance: bankBalance ?? this.bankBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      criticalStockCount: criticalStockCount ?? this.criticalStockCount,
      pendingReceivables: pendingReceivables ?? this.pendingReceivables,
      pendingPayables: pendingPayables ?? this.pendingPayables,
      monthlySales: monthlySales ?? this.monthlySales,
      lastMonthSales: lastMonthSales ?? this.lastMonthSales,
      salesGrowthRate: salesGrowthRate ?? this.salesGrowthRate,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalSuppliers: totalSuppliers ?? this.totalSuppliers,
      totalProducts: totalProducts ?? this.totalProducts,
      newCustomersThisMonth:
          newCustomersThisMonth ?? this.newCustomersThisMonth,
      newSuppliersThisMonth:
          newSuppliersThisMonth ?? this.newSuppliersThisMonth,
      totalPayments: totalPayments ?? this.totalPayments,
      paymentGrowthRate: paymentGrowthRate ?? this.paymentGrowthRate,
      balanceByCurrency: balanceByCurrency ?? this.balanceByCurrency,
      purchaseGrowthRate: purchaseGrowthRate ?? this.purchaseGrowthRate,
      netProfitGrowthRate: netProfitGrowthRate ?? this.netProfitGrowthRate,
      receivablesGrowthRate:
          receivablesGrowthRate ?? this.receivablesGrowthRate,
      payablesGrowthRate: payablesGrowthRate ?? this.payablesGrowthRate,
      customerGrowthRate: customerGrowthRate ?? this.customerGrowthRate,
      supplierGrowthRate: supplierGrowthRate ?? this.supplierGrowthRate,
    );
  }

  /// Boş DashboardSummary oluşturucu
  factory DashboardSummary.empty() {
    return const DashboardSummary(
      totalSales: 0.0,
      totalPurchases: 0.0,
      totalIncome: 0.0,
      totalExpenses: 0.0,
      netProfit: 0.0,
      cashBalance: 0.0,
      bankBalance: 0.0,
      totalBalance: 0.0,
      criticalStockCount: 0,
      pendingReceivables: 0.0,
      pendingPayables: 0.0,
      monthlySales: 0.0,
      lastMonthSales: 0.0,
      salesGrowthRate: 0.0,
      totalCustomers: 0,
      totalSuppliers: 0,
      totalProducts: 0,
      newCustomersThisMonth: 0,
      newSuppliersThisMonth: 0,
      totalPayments: 0.0,
      paymentGrowthRate: 0.0,
      balanceByCurrency: {},
      purchaseGrowthRate: 0.0,
      netProfitGrowthRate: 0.0,
      receivablesGrowthRate: 0.0,
      payablesGrowthRate: 0.0,
      customerGrowthRate: 0.0,
      supplierGrowthRate: 0.0,
    );
  }

  @override
  String toString() {
    return 'DashboardSummary('
        'totalSales: $totalSales, '
        'totalPurchases: $totalPurchases, '
        'netProfit: $netProfit, '
        'totalBalance: $totalBalance, '
        'criticalStockCount: $criticalStockCount'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardSummary &&
        other.totalSales == totalSales &&
        other.totalPurchases == totalPurchases &&
        other.totalIncome == totalIncome &&
        other.totalExpenses == totalExpenses &&
        other.netProfit == netProfit &&
        other.cashBalance == cashBalance &&
        other.bankBalance == bankBalance &&
        other.totalBalance == totalBalance &&
        other.criticalStockCount == criticalStockCount &&
        other.pendingReceivables == pendingReceivables &&
        other.pendingPayables == pendingPayables &&
        other.monthlySales == monthlySales &&
        other.lastMonthSales == lastMonthSales &&
        other.salesGrowthRate == salesGrowthRate &&
        other.totalCustomers == totalCustomers &&
        other.totalSuppliers == totalSuppliers &&
        other.totalProducts == totalProducts &&
        other.newCustomersThisMonth == newCustomersThisMonth &&
        other.newSuppliersThisMonth == newSuppliersThisMonth &&
        other.totalPayments == totalPayments &&
        other.paymentGrowthRate == paymentGrowthRate &&
        _mapEquals(other.balanceByCurrency ?? const {},
            balanceByCurrency ?? const {}) &&
        other.purchaseGrowthRate == purchaseGrowthRate &&
        other.netProfitGrowthRate == netProfitGrowthRate &&
        other.receivablesGrowthRate == receivablesGrowthRate &&
        other.payablesGrowthRate == payablesGrowthRate &&
        other.customerGrowthRate == customerGrowthRate &&
        other.supplierGrowthRate == supplierGrowthRate;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      totalSales,
      totalPurchases,
      totalIncome,
      totalExpenses,
      netProfit,
      cashBalance,
      bankBalance,
      totalBalance,
      criticalStockCount,
      pendingReceivables,
      pendingPayables,
      monthlySales,
      lastMonthSales,
      salesGrowthRate,
      totalCustomers,
      totalSuppliers,
      totalProducts,
      newCustomersThisMonth,
      newSuppliersThisMonth,
      totalPayments,
      paymentGrowthRate,
      balanceByCurrency ?? const {},
      purchaseGrowthRate,
      netProfitGrowthRate,
      receivablesGrowthRate,
      payablesGrowthRate,
      customerGrowthRate,
      supplierGrowthRate,
    ]);
  }
}

bool _mapEquals(Map<String, double> a, Map<String, double> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key)) return false;
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}
