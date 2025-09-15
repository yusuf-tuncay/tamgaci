import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_item_repository.dart';

/// Envanter öğeleri istatistikleri use case'i
class GetInventoryItemsStatisticsUseCase {
  final InventoryItemRepository _repository;

  GetInventoryItemsStatisticsUseCase(this._repository);

  /// Envanter öğeleri istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call() async {
    return await _repository.getInventoryItemsStatistics();
  }

  /// Envanter öğeleri raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, category, supplier)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getInventoryItemsReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// Toplam stok değerini getirir
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam stok değeri
  Future<double> getTotalStockValue({String? currency}) async {
    return await _repository.getTotalStockValue(currency: currency);
  }

  /// Türüne göre toplam stok değerini getirir
  /// [type]: Envanter öğesi türü
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam stok değeri
  Future<double> getTotalStockValueByType(InventoryItemType type,
      {String? currency}) async {
    return await _repository.getTotalStockValueByType(type, currency: currency);
  }

  /// Envanter öğesi sayısını getirir
  /// Returns: Toplam envanter öğesi sayısı
  Future<int> getCount() async {
    return await _repository.getInventoryItemsCount();
  }

  /// Türüne göre envanter öğesi sayısını getirir
  /// [type]: Envanter öğesi türü
  /// Returns: Envanter öğesi sayısı
  Future<int> getCountByType(InventoryItemType type) async {
    return await _repository.getInventoryItemsCountByType(type);
  }
}
