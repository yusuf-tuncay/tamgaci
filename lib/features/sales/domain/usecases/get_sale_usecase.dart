import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Tek satış getirme use case'i
class GetSaleUseCase {
  final SaleRepository _repository;

  GetSaleUseCase(this._repository);

  /// ID'ye göre satış getirir
  /// [id]: Satış ID'si
  /// Returns: Satış veya null
  Future<Sale?> call(String id) async {
    return await _repository.getSaleById(id);
  }

  /// Satış numarasına göre satış getirir
  /// [saleNumber]: Satış numarası
  /// Returns: Satış veya null
  Future<Sale?> getByNumber(String saleNumber) async {
    return await _repository.getSaleByNumber(saleNumber);
  }
}
