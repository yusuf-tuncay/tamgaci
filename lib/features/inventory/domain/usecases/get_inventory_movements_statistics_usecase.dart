import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareketleri istatistikleri use case'i
class GetInventoryMovementsStatisticsUseCase {
  final InventoryMovementRepository _repository;

  GetInventoryMovementsStatisticsUseCase(this._repository);

  /// Envanter hareketleri istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getInventoryMovementsStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Envanter hareketleri raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, item, location)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  }) async {
    return await _repository.getInventoryMovementsReport(
      startDate,
      endDate,
      groupBy: groupBy,
    );
  }

  /// En çok hareket edilen öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Öğe listesi
  Future<List<Map<String, dynamic>>> getTopMovedItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopMovedItems(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// En çok hareket edilen lokasyonları getirir
  /// [limit]: Maksimum lokasyon sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Lokasyon listesi
  Future<List<Map<String, dynamic>>> getTopLocations({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getTopLocations(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Envanter hareket toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: Hareket türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotal({
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  }) async {
    return await _repository.getInventoryMovementsTotal(
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// Öğeye göre envanter hareket toplamını getirir
  /// [itemId]: Öğe ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: Hareket türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getTotalByItem(
    String itemId, {
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  }) async {
    return await _repository.getInventoryMovementsTotalByItem(
      itemId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }

  /// Envanter hareket sayısını getirir
  /// Returns: Toplam envanter hareket sayısı
  Future<int> getCount() async {
    return await _repository.getInventoryMovementsCount();
  }

  /// Öğeye göre envanter hareket sayısını getirir
  /// [itemId]: Öğe ID'si
  /// Returns: Envanter hareket sayısı
  Future<int> getCountByItem(String itemId) async {
    return await _repository.getInventoryMovementsCountByItem(itemId);
  }

  /// Tarih aralığına göre envanter hareket sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Envanter hareket sayısı
  Future<int> getCountByDateRange(DateTime startDate, DateTime endDate) async {
    return await _repository.getInventoryMovementsCountByDateRange(
        startDate, endDate);
  }
}
