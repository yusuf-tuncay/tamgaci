import 'package:equatable/equatable.dart';
import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';

/// Purchases state
class PurchaseState extends Equatable {
  final List<Purchase> purchases;
  final Purchase? selectedPurchase;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;
  final Map<String, dynamic>? report;
  final List<Map<String, dynamic>> topPurchasedProducts;
  final List<Map<String, dynamic>> topSuppliers;

  const PurchaseState({
    this.purchases = const [],
    this.selectedPurchase,
    this.isLoading = false,
    this.error,
    this.statistics,
    this.report,
    this.topPurchasedProducts = const [],
    this.topSuppliers = const [],
  });

  PurchaseState copyWith({
    List<Purchase>? purchases,
    Purchase? selectedPurchase,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? report,
    List<Map<String, dynamic>>? topPurchasedProducts,
    List<Map<String, dynamic>>? topSuppliers,
  }) {
    return PurchaseState(
      purchases: purchases ?? this.purchases,
      selectedPurchase: selectedPurchase ?? this.selectedPurchase,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
      report: report ?? this.report,
      topPurchasedProducts: topPurchasedProducts ?? this.topPurchasedProducts,
      topSuppliers: topSuppliers ?? this.topSuppliers,
    );
  }

  @override
  List<Object?> get props => [
        purchases,
        selectedPurchase,
        isLoading,
        error,
        statistics,
        report,
        topPurchasedProducts,
        topSuppliers,
      ];
}
