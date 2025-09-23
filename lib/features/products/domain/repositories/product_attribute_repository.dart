// ========== PRODUCT ATTRIBUTE REPOSITORY ==========
// lib/features/products/domain/repositories/product_attribute_repository.dart

import '../entities/product_attribute.dart';

/// Ürün özelliği repository interface'i
abstract class ProductAttributeRepository {
  /// Tüm ürün özelliklerini getir
  Stream<List<ProductAttribute>> getAllProductAttributes();

  /// Aktif ürün özelliklerini getir
  Stream<List<ProductAttribute>> getActiveProductAttributes();

  /// ID'ye göre ürün özelliği getir
  Future<ProductAttribute?> getProductAttributeById(String id);

  /// Özellik türüne göre özellikleri getir
  Stream<List<ProductAttribute>> getProductAttributesByType(AttributeType type);

  /// Arama yapılabilir özellikleri getir
  Stream<List<ProductAttribute>> getSearchableAttributes();

  /// Filtrelenebilir özellikleri getir
  Stream<List<ProductAttribute>> getFilterableAttributes();

  /// Görünür özellikleri getir
  Stream<List<ProductAttribute>> getVisibleAttributes();

  /// Zorunlu özellikleri getir
  Stream<List<ProductAttribute>> getRequiredAttributes();

  /// Ürün özelliği oluştur
  Future<void> createProductAttribute(ProductAttribute attribute);

  /// Ürün özelliği güncelle
  Future<void> updateProductAttribute(ProductAttribute attribute);

  /// Ürün özelliği sil
  Future<void> deleteProductAttribute(String id);

  /// Ürün özelliği durumunu değiştir
  Future<void> updateProductAttributeStatus(String id, bool isActive);

  /// Özellik sıralamasını güncelle
  Future<void> updateAttributeSortOrder(String id, int sortOrder);

  /// Toplam ürün özelliği sayısı
  Future<int> getActiveProductAttributeCount();

  /// Özellik türlerini getir
  Stream<List<AttributeType>> getAttributeTypes();

  /// Özellik değer türlerini getir
  Stream<List<AttributeValueType>> getAttributeValueTypes();
}
