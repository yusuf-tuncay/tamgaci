import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın almaları getirme use case'i
class GetPurchasesUseCase {
  final PurchaseRepository _repository;

  GetPurchasesUseCase(this._repository);

  /// Tüm satın almaları getirir
  /// [includeItems]: Ürün detaylarını dahil et
  /// Returns: Satın alma listesi
  Future<List<Purchase>> call({
    bool includeItems = true,
  }) async {
    return await _repository.getAllPurchases(
      includeItems: includeItems,
    );
  }

  /// Tedarikçiye göre satın almaları getirir
  /// [supplierId]: Tedarikçi ID'si
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getBySupplier(String supplierId) async {
    return await _repository.getPurchasesBySupplierId(supplierId);
  }

  /// Tarih aralığına göre satın almaları getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getPurchasesByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre satın almaları getirir
  /// [status]: Satın alma durumu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getByStatus(
    PurchaseStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getPurchasesByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Ödeme durumuna göre satın almaları getirir
  /// [paymentStatus]: Ödeme durumu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getByPaymentStatus(
    PurchasePaymentStatus paymentStatus, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getPurchasesByPaymentStatus(
      paymentStatus,
      limit: limit,
      offset: offset,
    );
  }

  /// Vadesi geçmiş satın almaları getirir
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> getOverdue({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getOverduePurchases(
      limit: limit,
      offset: offset,
    );
  }

  /// Satın alma arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum satın alma sayısı
  /// [offset]: Atlanacak satın alma sayısı
  /// Returns: Satın alma listesi
  Future<List<Purchase>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchPurchases(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
