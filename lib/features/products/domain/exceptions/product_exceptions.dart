// ========== PRODUCT EXCEPTIONS ==========
// lib/features/products/domain/exceptions/product_exceptions.dart

/// Ürün işlemleri için özel exception'lar
abstract class ProductException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ProductException(this.message, {this.code, this.details});

  @override
  String toString() => 'ProductException: $message';
}

/// Ürün bulunamadı hatası
class ProductNotFoundException extends ProductException {
  ProductNotFoundException(String productId)
      : super('Ürün bulunamadı: $productId', code: 'PRODUCT_NOT_FOUND');
}

/// Ürün zaten mevcut hatası
class ProductAlreadyExistsException extends ProductException {
  ProductAlreadyExistsException(String field, String value)
      : super('$field zaten mevcut: $value', code: 'PRODUCT_ALREADY_EXISTS');
}

/// Ürün doğrulama hatası
class ProductValidationException extends ProductException {
  ProductValidationException(String message)
      : super('Doğrulama hatası: $message', code: 'VALIDATION_ERROR');
}

/// Ürün yetki hatası
class ProductPermissionException extends ProductException {
  ProductPermissionException(String action)
      : super('Bu işlem için yetkiniz yok: $action', code: 'PERMISSION_DENIED');
}

/// Ürün stok hatası
class ProductStockException extends ProductException {
  ProductStockException(String message)
      : super('Stok hatası: $message', code: 'STOCK_ERROR');
}

/// Ürün fiyat hatası
class ProductPriceException extends ProductException {
  ProductPriceException(String message)
      : super('Fiyat hatası: $message', code: 'PRICE_ERROR');
}

/// Ürün barkod hatası
class ProductBarcodeException extends ProductException {
  ProductBarcodeException(String message)
      : super('Barkod hatası: $message', code: 'BARCODE_ERROR');
}

/// Ürün kategori hatası
class ProductCategoryException extends ProductException {
  ProductCategoryException(String message)
      : super('Kategori hatası: $message', code: 'CATEGORY_ERROR');
}

/// Ürün import/export hatası
class ProductImportExportException extends ProductException {
  ProductImportExportException(String message)
      : super('Import/Export hatası: $message', code: 'IMPORT_EXPORT_ERROR');
}

/// Ürün backup/restore hatası
class ProductBackupException extends ProductException {
  ProductBackupException(String message)
      : super('Backup/Restore hatası: $message', code: 'BACKUP_ERROR');
}

/// Ürün audit hatası
class ProductAuditException extends ProductException {
  ProductAuditException(String message)
      : super('Audit hatası: $message', code: 'AUDIT_ERROR');
}

/// Ürün rate limit hatası
class ProductRateLimitException extends ProductException {
  ProductRateLimitException(String message)
      : super('Rate limit hatası: $message', code: 'RATE_LIMIT_EXCEEDED');
}

/// Ürün network hatası
class ProductNetworkException extends ProductException {
  ProductNetworkException(String message)
      : super('Network hatası: $message', code: 'NETWORK_ERROR');
}

/// Ürün database hatası
class ProductDatabaseException extends ProductException {
  ProductDatabaseException(String message)
      : super('Database hatası: $message', code: 'DATABASE_ERROR');
}

/// Ürün cache hatası
class ProductCacheException extends ProductException {
  ProductCacheException(String message)
      : super('Cache hatası: $message', code: 'CACHE_ERROR');
}

/// Ürün file hatası
class ProductFileException extends ProductException {
  ProductFileException(String message)
      : super('Dosya hatası: $message', code: 'FILE_ERROR');
}

/// Ürün image hatası
class ProductImageException extends ProductException {
  ProductImageException(String message)
      : super('Resim hatası: $message', code: 'IMAGE_ERROR');
}

/// Ürün barcode generation hatası
class ProductBarcodeGenerationException extends ProductException {
  ProductBarcodeGenerationException(String message)
      : super('Barkod üretim hatası: $message',
            code: 'BARCODE_GENERATION_ERROR');
}

/// Ürün GS1 hatası
class ProductGS1Exception extends ProductException {
  ProductGS1Exception(String message)
      : super('GS1 hatası: $message', code: 'GS1_ERROR');
}

/// Ürün GTIP hatası
class ProductGTIPException extends ProductException {
  ProductGTIPException(String message)
      : super('GTIP hatası: $message', code: 'GTIP_ERROR');
}

/// Ürün currency hatası
class ProductCurrencyException extends ProductException {
  ProductCurrencyException(String message)
      : super('Para birimi hatası: $message', code: 'CURRENCY_ERROR');
}

/// Ürün tax hatası
class ProductTaxException extends ProductException {
  ProductTaxException(String message)
      : super('Vergi hatası: $message', code: 'TAX_ERROR');
}

/// Ürün discount hatası
class ProductDiscountException extends ProductException {
  ProductDiscountException(String message)
      : super('İndirim hatası: $message', code: 'DISCOUNT_ERROR');
}

/// Ürün variant hatası
class ProductVariantException extends ProductException {
  ProductVariantException(String message)
      : super('Varyant hatası: $message', code: 'VARIANT_ERROR');
}

/// Ürün attribute hatası
class ProductAttributeException extends ProductException {
  ProductAttributeException(String message)
      : super('Özellik hatası: $message', code: 'ATTRIBUTE_ERROR');
}

/// Ürün linked product hatası
class ProductLinkedProductException extends ProductException {
  ProductLinkedProductException(String message)
      : super('Bağlı ürün hatası: $message', code: 'LINKED_PRODUCT_ERROR');
}
