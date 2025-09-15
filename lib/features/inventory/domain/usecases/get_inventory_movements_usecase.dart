import 'package:tamgaci/features/inventory/domain/entities/inventory_movement.dart';
import 'package:tamgaci/features/inventory/domain/repositories/inventory_movement_repository.dart';

/// Envanter hareketleri getirme use case'i
class GetInventoryMovementsUseCase {
  final InventoryMovementRepository _repository;

  GetInventoryMovementsUseCase(this._repository);

  /// Tüm envanter hareketlerini getirir
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> call({
    int? limit,
    int? offset,
  }) async {
    return await _repository.getAllInventoryMovements(
      limit: limit,
      offset: offset,
    );
  }

  /// Öğeye göre envanter hareketleri getirir
  /// [itemId]: Öğe ID'si
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByItem(
    String itemId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByItem(
      itemId,
      limit: limit,
      offset: offset,
    );
  }

  /// Tarih aralığına göre envanter hareketleri getirir
  /// [startDate]: Başlangıç tarihi
  /// [endDate]: Bitiş tarihi
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByDateRange(
      startDate,
      endDate,
      limit: limit,
      offset: offset,
    );
  }

  /// Türüne göre envanter hareketleri getirir
  /// [type]: Envanter hareket türü
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByType(
    InventoryMovementType type, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByType(
      type,
      limit: limit,
      offset: offset,
    );
  }

  /// Duruma göre envanter hareketleri getirir
  /// [status]: Envanter hareket durumu
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByStatus(
    InventoryMovementStatus status, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByStatus(
      status,
      limit: limit,
      offset: offset,
    );
  }

  /// Lokasyona göre envanter hareketleri getirir
  /// [location]: Lokasyon
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByLocation(
    String location, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByLocation(
      location,
      limit: limit,
      offset: offset,
    );
  }

  /// Referansa göre envanter hareketleri getirir
  /// [referenceType]: Referans türü
  /// [referenceId]: Referans ID'si
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> getByReference(
    String referenceType,
    String referenceId, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.getInventoryMovementsByReference(
      referenceType,
      referenceId,
      limit: limit,
      offset: offset,
    );
  }

  /// Envanter hareket arama
  /// [query]: Arama sorgusu
  /// [limit]: Maksimum hareket sayısı
  /// [offset]: Atlanacak hareket sayısı
  /// Returns: Envanter hareket listesi
  Future<List<InventoryMovement>> search(
    String query, {
    int? limit,
    int? offset,
  }) async {
    return await _repository.searchInventoryMovements(
      query,
      limit: limit,
      offset: offset,
    );
  }
}
