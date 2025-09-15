import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satış güncelleme use case'i
class UpdateSaleUseCase {
  final SaleRepository _repository;

  UpdateSaleUseCase(this._repository);

  /// Satışı günceller
  /// [sale]: Güncellenecek satış
  /// Returns: Güncellenmiş satış
  Future<Sale> call(Sale sale) async {
    final updatedSale = sale.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateSale(updatedSale);
  }

  /// Satış durumunu günceller
  /// [id]: Satış ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş satış
  Future<Sale> updateStatus(String id, SaleStatus status) async {
    return await _repository.updateSaleStatus(id, status);
  }

  /// Ödeme durumunu günceller
  /// [id]: Satış ID'si
  /// [paymentStatus]: Yeni ödeme durumu
  /// Returns: Güncellenmiş satış
  Future<Sale> updatePaymentStatus(
      String id, PaymentStatus paymentStatus) async {
    return await _repository.updatePaymentStatus(id, paymentStatus);
  }

  /// Satışı onaylar
  /// [id]: Satış ID'si
  /// Returns: Güncellenmiş satış
  Future<Sale> approve(String id) async {
    return await _repository.approveSale(id);
  }

  /// Satışı kargoya verir
  /// [id]: Satış ID'si
  /// [trackingNumber]: Takip numarası
  /// Returns: Güncellenmiş satış
  Future<Sale> ship(String id, String trackingNumber) async {
    return await _repository.shipSale(id, trackingNumber);
  }

  /// Satışı teslim eder
  /// [id]: Satış ID'si
  /// Returns: Güncellenmiş satış
  Future<Sale> deliver(String id) async {
    return await _repository.deliverSale(id);
  }

  /// Satışı iptal eder
  /// [id]: Satış ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş satış
  Future<Sale> cancel(String id, String reason) async {
    return await _repository.cancelSale(id, reason);
  }

  /// Satışı iade eder
  /// [id]: Satış ID'si
  /// [reason]: İade nedeni
  /// Returns: Güncellenmiş satış
  Future<Sale> returnSale(String id, String reason) async {
    return await _repository.returnSale(id, reason);
  }
}
