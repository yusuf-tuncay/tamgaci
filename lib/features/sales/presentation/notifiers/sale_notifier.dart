import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/usecases/create_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/update_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/delete_sale_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/get_sales_statistics_usecase.dart';
import 'package:tamgaci/features/sales/domain/usecases/duplicate_sale_usecase.dart';
import 'package:tamgaci/features/sales/presentation/states/sale_state.dart';

/// Sales state notifier
class SaleNotifier extends StateNotifier<SaleState> {
  final CreateSaleUseCase _createSaleUseCase;
  final GetSalesUseCase _getSalesUseCase;
  final GetSaleUseCase _getSaleUseCase;
  final UpdateSaleUseCase _updateSaleUseCase;
  final DeleteSaleUseCase _deleteSaleUseCase;
  final GetSalesStatisticsUseCase _getSalesStatisticsUseCase;
  final DuplicateSaleUseCase _duplicateSaleUseCase;

  SaleNotifier({
    required CreateSaleUseCase createSaleUseCase,
    required GetSalesUseCase getSalesUseCase,
    required GetSaleUseCase getSaleUseCase,
    required UpdateSaleUseCase updateSaleUseCase,
    required DeleteSaleUseCase deleteSaleUseCase,
    required GetSalesStatisticsUseCase getSalesStatisticsUseCase,
    required DuplicateSaleUseCase duplicateSaleUseCase,
  })  : _createSaleUseCase = createSaleUseCase,
        _getSalesUseCase = getSalesUseCase,
        _getSaleUseCase = getSaleUseCase,
        _updateSaleUseCase = updateSaleUseCase,
        _deleteSaleUseCase = deleteSaleUseCase,
        _getSalesStatisticsUseCase = getSalesStatisticsUseCase,
        _duplicateSaleUseCase = duplicateSaleUseCase,
        super(const SaleState());

  /// Tüm satışları getirir
  Future<void> getSales({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.call(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Müşteriye göre satışları getirir
  Future<void> getSalesByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.getByCustomer(
        customerId,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tarih aralığına göre satışları getirir
  Future<void> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.getByDateRange(
        startDate,
        endDate,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Duruma göre satışları getirir
  Future<void> getSalesByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.getByStatus(
        status,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Ödeme durumuna göre satışları getirir
  Future<void> getSalesByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.getByPaymentStatus(
        paymentStatus,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Vadesi geçmiş satışları getirir
  Future<void> getOverdueSales({
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.getOverdue(
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satış arama
  Future<void> searchSales(
    String query, {
    int? limit,
    int? offset,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sales = await _getSalesUseCase.search(
        query,
        limit: limit,
        offset: offset,
      );

      state = state.copyWith(
        isLoading: false,
        sales: sales,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Tek satış getirir
  Future<void> getSale(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sale = await _getSaleUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        selectedSale: sale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satış numarasına göre satış getirir
  Future<void> getSaleByNumber(String saleNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sale = await _getSaleUseCase.getByNumber(saleNumber);

      state = state.copyWith(
        isLoading: false,
        selectedSale: sale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Yeni satış oluşturur
  Future<void> createSale(Sale sale) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final createdSale = await _createSaleUseCase.call(sale);

      state = state.copyWith(
        isLoading: false,
        sales: [...state.sales, createdSale],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı günceller
  Future<void> updateSale(Sale sale) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.call(sale);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satış durumunu günceller
  Future<void> updateSaleStatus(String id, SaleStatus status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.updateStatus(id, status);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Ödeme durumunu günceller
  Future<void> updatePaymentStatus(
      String id, PaymentStatus paymentStatus) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale =
          await _updateSaleUseCase.updatePaymentStatus(id, paymentStatus);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı onaylar
  Future<void> approveSale(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.approve(id);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı kargoya verir
  Future<void> shipSale(String id, String trackingNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.ship(id, trackingNumber);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı teslim eder
  Future<void> deliverSale(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.deliver(id);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı iptal eder
  Future<void> cancelSale(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.cancel(id, reason);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı iade eder
  Future<void> returnSale(String id, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedSale = await _updateSaleUseCase.returnSale(id, reason);

      final updatedSales = state.sales.map((s) {
        return s.id == updatedSale.id ? updatedSale : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == updatedSale.id
            ? updatedSale
            : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı siler
  Future<void> deleteSale(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deleteSaleUseCase.call(id);

      final updatedSales = state.sales.where((s) => s.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        sales: updatedSales,
        selectedSale: state.selectedSale?.id == id ? null : state.selectedSale,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satışı kopyalar
  Future<void> duplicateSale(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final duplicatedSale = await _duplicateSaleUseCase.call(id);

      state = state.copyWith(
        isLoading: false,
        sales: [...state.sales, duplicatedSale],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satış istatistiklerini getirir
  Future<void> getSalesStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final statistics = await _getSalesStatisticsUseCase.call(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        statistics: statistics,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Satış raporu oluşturur
  Future<void> getSalesReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final report = await _getSalesStatisticsUseCase.getReport(
        startDate,
        endDate,
        groupBy: groupBy,
      );

      state = state.copyWith(
        isLoading: false,
        report: report,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok satan ürünleri getirir
  Future<void> getTopSellingProducts({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topProducts =
          await _getSalesStatisticsUseCase.getTopSellingProducts(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topSellingProducts: topProducts,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// En çok alışveriş yapan müşterileri getirir
  Future<void> getTopCustomers({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final topCustomers = await _getSalesStatisticsUseCase.getTopCustomers(
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        topCustomers: topCustomers,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Seçili satışı temizler
  void clearSelectedSale() {
    state = state.copyWith(selectedSale: null);
  }

  /// Hata mesajını temizler
  void clearError() {
    state = state.copyWith(error: null);
  }
}
