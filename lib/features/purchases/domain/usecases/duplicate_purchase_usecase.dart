import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın alma kopyalama use case'i
class DuplicatePurchaseUseCase {
  final PurchaseRepository _repository;

  DuplicatePurchaseUseCase(this._repository);

  /// Satın alma kopyalar
  /// [id]: Kopyalanacak satın alma ID'si
  /// Returns: Kopyalanan satın alma
  Future<Purchase> call(String id) async {
    return await _repository.duplicatePurchase(id);
  }
}
