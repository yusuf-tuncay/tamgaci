import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın alma oluşturma use case'i
class CreatePurchaseUseCase {
  final PurchaseRepository _repository;

  CreatePurchaseUseCase(this._repository);

  /// Yeni satın alma oluşturur
  /// [purchase]: Oluşturulacak satın alma
  /// Returns: Oluşturulan satın alma
  Future<Purchase> call(Purchase purchase) async {
    // Satın alma numarası otomatik oluşturulacak
    final purchaseNumber = await _repository.generatePurchaseNumber();

    final newPurchase = purchase.copyWith(
      purchaseNumber: purchaseNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final purchaseId = await _repository.createPurchase(newPurchase);
    return newPurchase.copyWith(id: purchaseId);
  }
}
