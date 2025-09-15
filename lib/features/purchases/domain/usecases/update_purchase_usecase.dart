import 'package:tamgaci/features/purchases/domain/entities/purchase.dart';
import 'package:tamgaci/features/purchases/domain/repositories/purchase_repository.dart';

/// Satın alma güncelleme use case'i
class UpdatePurchaseUseCase {
  final PurchaseRepository _repository;

  UpdatePurchaseUseCase(this._repository);

  /// Satın alma günceller
  /// [purchase]: Güncellenecek satın alma
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> call(Purchase purchase) async {
    final updatedPurchase = purchase.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updatePurchase(updatedPurchase);
  }

  /// Satın alma durumunu günceller
  /// [id]: Satın alma ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> updateStatus(String id, PurchaseStatus status) async {
    return await _repository.updatePurchaseStatus(id, status);
  }

  /// Ödeme durumunu günceller
  /// [id]: Satın alma ID'si
  /// [paymentStatus]: Yeni ödeme durumu
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> updatePaymentStatus(
      String id, PurchasePaymentStatus paymentStatus) async {
    return await _repository.updatePaymentStatus(id, paymentStatus);
  }

  /// Satın alma onaylar
  /// [id]: Satın alma ID'si
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> approve(String id) async {
    return await _repository.approvePurchase(id);
  }

  /// Satın alma teslim alır
  /// [id]: Satın alma ID'si
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> receive(String id) async {
    return await _repository.receivePurchase(id);
  }

  /// Satın alma iptal eder
  /// [id]: Satın alma ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> cancel(String id, String reason) async {
    return await _repository.cancelPurchase(id, reason);
  }

  /// Satın alma iade eder
  /// [id]: Satın alma ID'si
  /// [reason]: İade nedeni
  /// Returns: Güncellenmiş satın alma
  Future<Purchase> returnPurchase(String id, String reason) async {
    return await _repository.returnPurchase(id, reason);
  }
}
