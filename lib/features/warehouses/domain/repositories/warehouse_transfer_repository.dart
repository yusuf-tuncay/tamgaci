import '../entities/warehouse_transfer.dart';

/// Warehouse Transfer Repository Interface
abstract class WarehouseTransferRepository {
  /// Transfer oluştur
  Future<WarehouseTransfer> createTransfer(WarehouseTransfer transfer);
  
  /// Transfer güncelle
  Future<WarehouseTransfer> updateTransfer(WarehouseTransfer transfer);
  
  /// Transfer sil
  Future<void> deleteTransfer(String id);
  
  /// Transfer getir
  Future<WarehouseTransfer?> getTransfer(String id);
  
  /// Tüm transferleri getir
  Future<List<WarehouseTransfer>> getTransfers();
  
  /// Depo transferlerini getir
  Future<List<WarehouseTransfer>> getTransfersByWarehouse(String warehouseId);
  
  /// Ürün transferlerini getir
  Future<List<WarehouseTransfer>> getTransfersByProduct(String productId);
  
  /// Transfer durumuna göre getir
  Future<List<WarehouseTransfer>> getTransfersByStatus(String status);
  
  /// Bekleyen transferleri getir
  Future<List<WarehouseTransfer>> getPendingTransfers();
  
  /// Transfer tamamla
  Future<WarehouseTransfer> completeTransfer(String id);
  
  /// Transfer iptal et
  Future<WarehouseTransfer> cancelTransfer(String id);
}
