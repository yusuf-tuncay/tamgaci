import 'package:tamgaci/features/inventory/domain/entities/inventory_item.dart';

/// Inventory Item Repository Interface
/// Bu interface, envanter öğesi ile ilgili tüm veri işlemlerini tanımlar.
abstract class InventoryItemRepository {
  /// Tüm envanter öğelerini getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getAllInventoryItems({
    int? limit,
    int? offset,
  });

  /// ID'ye göre envanter öğesi getirir
  /// [id]: Envanter öğesi ID'si
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> getInventoryItemById(String id);

  /// SKU'ya göre envanter öğesi getirir
  /// [sku]: SKU kodu
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> getInventoryItemBySku(String sku);

  /// Barkod'a göre envanter öğesi getirir
  /// [barcode]: Barkod
  /// Returns: Envanter öğesi veya null
  Future<InventoryItem?> getInventoryItemByBarcode(String barcode);

  /// Türüne göre envanter öğelerini getirir
  /// [type]: Envanter öğesi türü
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsByType(
    InventoryItemType type, {
    int? limit,
    int? offset,
  });

  /// Duruma göre envanter öğelerini getirir
  /// [status]: Envanter öğesi durumu
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsByStatus(
    InventoryItemStatus status, {
    int? limit,
    int? offset,
  });

  /// Kategoriye göre envanter öğelerini getirir
  /// [category]: Kategori
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsByCategory(
    String category, {
    int? limit,
    int? offset,
  });

  /// Tedarikçiye göre envanter öğelerini getirir
  /// [supplierId]: Tedarikçi ID'si
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsBySupplier(
    String supplierId, {
    int? limit,
    int? offset,
  });

  /// Stok seviyesine göre envanter öğelerini getirir
  /// [stockLevel]: Stok seviyesi (low, normal, high)
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsByStockLevel(
    String stockLevel, {
    int? limit,
    int? offset,
  });

  /// Yeniden sipariş noktasına ulaşan öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getInventoryItemsAtReorderPoint({
    int? limit,
    int? offset,
  });

  /// Stokta olmayan öğeleri getirir
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getOutOfStockItems({
    int? limit,
    int? offset,
  });

  /// Son kullanma tarihi yaklaşan öğeleri getirir
  /// [days]: Kaç gün içinde
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> getExpiringItems(
    int days, {
    int? limit,
    int? offset,
  });

  /// Yeni envanter öğesi oluşturur
  /// [inventoryItem]: Oluşturulacak envanter öğesi
  /// Returns: Oluşturulan envanter öğesi
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem);

  /// Envanter öğesi günceller
  /// [inventoryItem]: Güncellenecek envanter öğesi
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> updateInventoryItem(InventoryItem inventoryItem);

  /// Envanter öğesi siler
  /// [id]: Silinecek envanter öğesi ID'si
  Future<void> deleteInventoryItem(String id);

  /// Envanter öğesi durumunu günceller
  /// [id]: Envanter öğesi ID'si
  /// [status]: Yeni durum
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> updateInventoryItemStatus(
      String id, InventoryItemStatus status);

  /// Stok miktarını günceller
  /// [id]: Envanter öğesi ID'si
  /// [quantity]: Yeni stok miktarı
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> updateStockQuantity(String id, double quantity);

  /// Envanter öğesi arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum öğe sayısı
  /// [offset]: Atlanacak öğe sayısı
  /// Returns: Envanter öğesi listesi
  Future<List<InventoryItem>> searchInventoryItems(
    String query, {
    int? limit,
    int? offset,
  });

  /// Envanter öğesi sayısını getirir
  /// Returns: Toplam envanter öğesi sayısı
  Future<int> getInventoryItemsCount();

  /// Türüne göre envanter öğesi sayısını getirir
  /// [type]: Envanter öğesi türü
  /// Returns: Envanter öğesi sayısı
  Future<int> getInventoryItemsCountByType(InventoryItemType type);

  /// Toplam stok değerini getirir
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam stok değeri
  Future<double> getTotalStockValue({String? currency});

  /// Türüne göre toplam stok değerini getirir
  /// [type]: Envanter öğesi türü
  /// [currency]: Para birimi (opsiyonel)
  /// Returns: Toplam stok değeri
  Future<double> getTotalStockValueByType(InventoryItemType type,
      {String? currency});

  /// Envanter öğesi raporu oluşturur
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [groupBy]: Gruplama türü (type, category, supplier)
  /// Returns: Rapor verileri
  Future<Map<String, dynamic>> getInventoryItemsReport(
    DateTime startDate,
    DateTime endDate, {
    String? groupBy,
  });

  /// Envanter öğesi istatistiklerini getirir
  /// Returns: İstatistik verileri
  Future<Map<String, dynamic>> getInventoryItemsStatistics();

  /// Envanter öğesi numarası oluşturur
  /// [type]: Envanter öğesi türü
  /// Returns: Envanter öğesi numarası
  Future<String> generateInventoryItemNumber(InventoryItemType type);

  /// Envanter öğesi kopyalar
  /// [id]: Kopyalanacak envanter öğesi ID'si
  /// Returns: Kopyalanan envanter öğesi
  Future<InventoryItem> duplicateInventoryItem(String id);

  /// Envanter öğesi arşivler
  /// [id]: Envanter öğesi ID'si
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> archiveInventoryItem(String id);

  /// Envanter öğesi aktifleştirir
  /// [id]: Envanter öğesi ID'si
  /// Returns: Güncellenmiş envanter öğesi
  Future<InventoryItem> activateInventoryItem(String id);
}
