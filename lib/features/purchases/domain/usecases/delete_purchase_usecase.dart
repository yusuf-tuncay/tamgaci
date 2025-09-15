import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın alma silme use case'i
class DeletePurchaseUseCase {
  final PurchaseRepository _repository;

  DeletePurchaseUseCase(this._repository);

  /// Satın alma siler
  /// [id]: Silinecek satın alma ID'si
  Future<void> call(String id) async {
    await _repository.deletePurchase(id);
  }
}
