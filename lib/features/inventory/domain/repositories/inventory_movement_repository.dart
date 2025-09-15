import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';

/// Inventory Movement Repository Interface
/// Bu interface, envanter hareket ile ilgili tüm veri işlemlerini tanımlar.
abstract class InventoryMovementRepository {
  /// Tüm envanter hareketlerini getirir
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getAllInventoryMovements({
    int? limit,
    int? offset,
  });

  /// ID'ye göre envanter hareket getirir
  /// [id]: Envanter hareket ID'si
  /// Returns: Envanter hareket veya null
  Future<InventoryMovement?> getInventoryMovementById(String id);

  /// Hareket numarasına göre envanter hareket getirir
  /// [movementNumber]: Hareket numarası
  /// Returns: Envanter hareket veya null
  Future<InventoryMovement?> getInventoryMovementByNumber(
      String movementNumber);

  /// Öğeye göre envanter hareketleri getirir
  /// [itemId]: Öğe ID'si
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByItem(
    String itemId, {
    int? limit,
    int? offset,
  });

  /// Tarih aralığına göre envanter hareketleri getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  });

  /// Türüne göre envanter hareketleri getirir
  /// [type]: Envanter hareket türü
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByType(
    InventoryMovementType type, {
    int? limit,
    int? offset,
  });

  /// Duruma göre envanter hareketleri getirir
  /// [status]: Envanter hareket durumu
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByStatus(
    InventoryMovementStatus status, {
    int? limit,
    int? offset,
  });

  /// Lokasyona göre envanter hareketleri getirir
  /// [location]: Lokasyon
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByLocation(
    String location, {
    int? limit,
    int? offset,
  });

  /// Referansa göre envanter hareketleri getirir
  /// [referenceType]: Referans türü
  /// [referenceId]: Referans ID'si
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getInventoryMovementsByReference(
    String referenceType,
    String referenceId, {
    int? limit,
    int? offset,
  });

  /// Yeni envanter hareket oluşturur
  /// [inventoryMovement]: Oluşturulacak envanter hareket
  /// Returns: Oluşturulan envanter hareket
  Future<InventoryMovement> createInventoryMovement(
      InventoryMovement inventoryMovement);

  /// Envanter hareket günceller
  /// [inventoryMovement]: Güncellenecek envanter hareket
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> updateInventoryMovement(
      InventoryMovement inventoryMovement);

  /// Envanter hareket siler
  /// [id]: Silinecek envanter hareket ID'si
  Future<void> deleteInventoryMovement(String id);

  /// Envanter hareket durumunu günceller
  /// [id]: Envanter hareket ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> updateInventoryMovementStatus(
      String id, InventoryMovementStatus status);

  /// Envanter hareket arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> searchInventoryMovements(
    String query, {
    int? limit,
    int? offset,
  });

  /// Envanter hareket sayısını getirir
  /// Returns: Toplam envanter hareket sayısı
  Future<int> getInventoryMovementsCount();

  /// Öğeye göre envanter hareket sayısını getirir
  /// [itemId]: Öğe ID'si
  /// Returns: Envanter hareket sayısı
  Future<int> getInventoryMovementsCountByItem(String itemId);

  /// Tarih aralığına göre envanter hareket sayısını getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// Returns: Envanter hareket sayısı
  Future<int> getInventoryMovementsCountByDateRange(
      DateTime startDate, DateTime endDate);

  /// Envanter hareket toplamını getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: Hareket türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getInventoryMovementsTotal({
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  });

  /// Öğeye göre envanter hareket toplamını getirir
  /// [itemId]: Öğe ID'si
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// [type]: Hareket türü (opsiyonel)
  /// Returns: Toplam tutar
  Future<double> getInventoryMovementsTotalByItem(
    String itemId, {
    DateTime? startDate,
    DateTime? endDate,
    InventoryMovementType? type,
  });

  /// Envanter hareket raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, item, location)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getInventoryMovementsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// En çok hareket edilen öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Öğe listesi
  Future<List<Map<String, dynamic>>> getTopMovedItems({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// En çok hareket edilen lokasyonları getirir
  /// [limit]: Maksimum lokasyon sayısı
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: Lokasyon listesi
  Future<List<Map<String, dynamic>>> getTopLocations({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Envanter hareket istatistiklerini getirir
  /// [startDate]: Başlangıç tarihi (opsiyonel)
  /// [endDate]: Bitiş tarihi (opsiyonel)
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getInventoryMovementsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Envanter hareket numarası oluşturur
  /// [type]: Envanter hareket türü
  /// Returns: Envanter hareket numarası
  Future<String> generateInventoryMovementNumber(InventoryMovementType type);

  /// Envanter hareket kopyalar
  /// [id]: Kopyalanacak envanter hareket ID'si
  /// Returns: Kopyalanan envanter hareket
  Future<InventoryMovement> duplicateInventoryMovement(String id);

  /// Envanter hareket iptal eder
  /// [id]: Envanter hareket ID'si
  /// [reason]: İptal nedeni
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> cancelInventoryMovement(String id, String reason);

  /// Envanter hareket onaylar
  /// [id]: Envanter hareket ID'si
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> approveInventoryMovement(String id);

  /// Envanter hareket tamamlar
  /// [id]: Envanter hareket ID'si
  /// Returns: Güncellenmiş envanter hareket
  Future<InventoryMovement> completeInventoryMovement(String id);
}
