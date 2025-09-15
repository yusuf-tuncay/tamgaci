import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Tek satın alma getirme use case'i
class GetPurchaseUseCase {
  final PurchaseRepository _repository;

  GetPurchaseUseCase(this._repository);

  /// ID'ye göre satın alma getirir
  /// [id]: Satın alma ID'si
  /// Returns: Satın alma veya null
  Future<Purchase?> call(String id) async {
    return await _repository.getPurchaseById(id);
  }

  /// Satın alma numarasına göre satın alma getirir
  /// [purchaseNumber]: Satın alma numarası
  /// Returns: Satın alma veya null
  Future<Purchase?> getByNumber(String purchaseNumber) async {
    return await _repository.getPurchaseByNumber(purchaseNumber);
  }
}
