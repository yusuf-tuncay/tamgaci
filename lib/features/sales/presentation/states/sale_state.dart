import 'package:equatable/equatable.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';

/// Sales state
class SaleState extends Equatable {
  final List<Sale> sales;
  final Sale? selectedSale;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;
  final Map<String, dynamic>? report;
  final List<Map<String, dynamic>> topSellingProducts;
  final List<Map<String, dynamic>> topCustomers;

  const SaleState({
    this.sales = const [],
    this.selectedSale,
    this.isLoading = false,
    this.error,
    this.statistics,
    this.report,
    this.topSellingProducts = const [],
    this.topCustomers = const [],
  });

  SaleState copyWith({
    List<Sale>? sales,
    Sale? selectedSale,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? report,
    List<Map<String, dynamic>>? topSellingProducts,
    List<Map<String, dynamic>>? topCustomers,
  }) {
    return SaleState(
      sales: sales ?? this.sales,
      selectedSale: selectedSale ?? this.selectedSale,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
      report: report ?? this.report,
      topSellingProducts: topSellingProducts ?? this.topSellingProducts,
      topCustomers: topCustomers ?? this.topCustomers,
    );
  }

  @override
  List<Object?> get props => [
        sales,
        selectedSale,
        isLoading,
        error,
        statistics,
        report,
        topSellingProducts,
        topCustomers,
      ];
}
