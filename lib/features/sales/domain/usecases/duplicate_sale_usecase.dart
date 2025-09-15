import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satış kopyalama use case'i
class DuplicateSaleUseCase {
  final SaleRepository _repository;

  DuplicateSaleUseCase(this._repository);

  /// Satışı kopyalar
  /// [id]: Kopyalanacak satış ID'si
  /// Returns: Kopyalanan satış
  Future<Sale> call(String id) async {
    return await _repository.duplicateSale(id);
  }
}
