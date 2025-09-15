import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satış silme use case'i
class DeleteSaleUseCase {
  final SaleRepository _repository;

  DeleteSaleUseCase(this._repository);

  /// Satışı siler
  /// [id]: Silinecek satış ID'si
  Future<void> call(String id) async {
    await _repository.deleteSale(id);
  }
}
