import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satışları getirme use case'i
class GetSalesUseCase {
  final SaleRepository _repository;

  GetSalesUseCase(this._repository);

  /// Tüm satışları getirir
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllSales(
      limit: limit,
      offset: offset,
    );
  }

  /// Müşteriye göre satışları getirir
  /// [customerId]: Müşteri ID'si
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> getByCustomer(
    String customerId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSalesByCustomer(
      customerId,
      limit: limit,
      offset: offset,
    );
  }

  /// Tarih aralığına göre satışları getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSalesByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre satışları getirir
  /// [status]: Satış durumu
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> getByStatus(
    SaleStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSalesByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Ödeme durumuna göre satışları getirir
  /// [paymentStatus]: Ödeme durumu
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> getByPaymentStatus(
    PaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getSalesByPaymentStatus(
      paymentStatus,
      limit: limit,
      offset: offset,
    );
  }

  /// Vadesi geçmiş satışları getirir
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> getOverdue({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getOverdueSales(
      limit: limit,
      offset: offset,
    );
  }

  /// Satış arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum satış sayısı
  /// [offset]: Atlanacak satış sayısı
  /// Returns: Satış listesi
  Future<List<Sale>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchSales(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
