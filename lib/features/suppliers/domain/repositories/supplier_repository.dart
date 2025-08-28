// ========== SUPPLIER REPOSITORY INTERFACE ==========
// lib/features/suppliers/domain/repositories/supplier_repository.dart

import '../entities/supplier.dart';

/// Tedarikçi repository interface'i
abstract class SupplierRepository {
  /// Yeni tedarikçi oluştur
  Future<String> createSupplier(Supplier supplier);

  /// Tedarikçi güncelle
  Future<void> updateSupplier(Supplier supplier);

  /// Tedarikçi sil
  Future<void> deleteSupplier(String id);

  /// ID'ye göre tedarikçi getir
  Future<Supplier?> getSupplierById(String id);

  /// Tüm tedarikçileri getir
  Future<List<Supplier>> getAllSuppliers();

  /// Tedarikçi stream'i (tek tedarikçi)
  Stream<Supplier?> watchSupplierById(String id);

  /// Tüm tedarikçiler stream'i
  Stream<List<Supplier>> watchAllSuppliers();
}
