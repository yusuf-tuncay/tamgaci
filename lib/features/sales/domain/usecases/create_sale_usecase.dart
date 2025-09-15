import 'package:tamgaci/features/sales/domain/entities/sale.dart';
import 'package:tamgaci/features/sales/domain/repositories/sale_repository.dart';

/// Satış oluşturma use case'i
class CreateSaleUseCase {
  final SaleRepository _repository;

  CreateSaleUseCase(this._repository);

  /// Yeni satış oluşturur
  /// [sale]: Oluşturulacak satış
  /// Returns: Oluşturulan satış
  Future<Sale> call(Sale sale) async {
    // Satış numarası otomatik oluşturulacak
    final saleNumber = await _repository.generateSaleNumber(sale.type);

    final newSale = sale.copyWith(
      saleNumber: saleNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createSale(newSale);
  }
}
