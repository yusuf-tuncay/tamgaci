// ========== PRODUCT VALIDATOR ==========
// lib/features/products/domain/validators/product_validator.dart

import '../entities/product.dart';

/// Ürün doğrulama sınıfı - Muhasebe standartlarına uygun
class ProductValidator {
  static const double _minPrice = 0.01;
  static const double _maxPrice = 999999999.99;
  static const double _minTaxRate = 0.0;
  static const double _maxTaxRate = 100.0;
  static const int _maxNameLength = 255;
  static const int _maxDescriptionLength = 2000;
  static const int _maxBarcodeLength = 50;
  static const int _maxSkuLength = 50;
  static const int _maxGtipLength = 12;
  static const int _maxCountryCodeLength = 3;

  /// Ürün oluşturma doğrulaması
  static ValidationResult validateCreate(Product product) {
    final errors = <String>[];

    // Zorunlu alanlar
    if (product.name.trim().isEmpty) {
      errors.add('Ürün adı zorunludur');
    } else if (product.name.length > _maxNameLength) {
      errors.add('Ürün adı en fazla $_maxNameLength karakter olabilir');
    }

    if (product.salesPrice < _minPrice || product.salesPrice > _maxPrice) {
      errors.add('Satış fiyatı $_minPrice - $_maxPrice arasında olmalıdır');
    }

    if (product.salesTaxRate < _minTaxRate ||
        product.salesTaxRate > _maxTaxRate) {
      errors.add('KDV oranı $_minTaxRate - $_maxTaxRate arasında olmalıdır');
    }

    // Açıklama doğrulaması
    if (product.description != null &&
        product.description!.length > _maxDescriptionLength) {
      errors.add('Açıklama en fazla $_maxDescriptionLength karakter olabilir');
    }

    // Barkod doğrulaması
    if (product.barcode != null) {
      if (product.barcode!.length > _maxBarcodeLength) {
        errors.add('Barkod en fazla $_maxBarcodeLength karakter olabilir');
      }
      if (!_isValidBarcode(product.barcode!)) {
        errors.add('Geçersiz barkod formatı');
      }
    }

    // SKU doğrulaması
    if (product.sku != null && product.sku!.length > _maxSkuLength) {
      errors.add('SKU en fazla $_maxSkuLength karakter olabilir');
    }

    // GTIP doğrulaması
    if (product.gtipCode != null) {
      if (product.gtipCode!.length > _maxGtipLength) {
        errors.add('GTIP kodu en fazla $_maxGtipLength karakter olabilir');
      }
      if (!_isValidGtipCode(product.gtipCode!)) {
        errors.add('Geçersiz GTIP kodu formatı');
      }
    }

    // Ülke kodu doğrulaması
    if (product.countryCode != null) {
      if (product.countryCode!.length > _maxCountryCodeLength) {
        errors
            .add('Ülke kodu en fazla $_maxCountryCodeLength karakter olabilir');
      }
      if (!_isValidCountryCode(product.countryCode!)) {
        errors.add('Geçersiz ülke kodu');
      }
    }

    // Para birimi doğrulaması
    if (!_isValidCurrency(product.salesCurrency)) {
      errors.add('Geçersiz satış para birimi');
    }

    if (product.purchaseCurrency != null &&
        !_isValidCurrency(product.purchaseCurrency!)) {
      errors.add('Geçersiz alış para birimi');
    }

    // İskonto doğrulaması
    if (product.purchaseDiscount != null) {
      if (product.purchaseDiscount! < 0 || product.purchaseDiscount! > 100) {
        errors.add('Alış iskontosu 0-100 arasında olmalıdır');
      }
    }

    // ÖTV doğrulaması
    if (product.sct != null) {
      if (product.sct! < 0 || product.sct! > 100) {
        errors.add('ÖTV oranı 0-100 arasında olmalıdır');
      }
    }

    // Kritik stok doğrulaması
    if (product.criticalStockQuantity != null &&
        product.criticalStockQuantity! < 0) {
      errors.add('Kritik stok miktarı negatif olamaz');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Ürün güncelleme doğrulaması
  static ValidationResult validateUpdate(
      Product oldProduct, Product newProduct) {
    final errors = <String>[];

    // Temel doğrulama
    final basicValidation = validateCreate(newProduct);
    if (!basicValidation.isValid) {
      errors.addAll(basicValidation.errors);
    }

    // Fiyat değişikliği kontrolü
    if (oldProduct.salesPrice != newProduct.salesPrice) {
      final priceChangePercent =
          ((newProduct.salesPrice - oldProduct.salesPrice) /
                  oldProduct.salesPrice *
                  100)
              .abs();
      if (priceChangePercent > 50) {
        errors.add('Fiyat değişikliği %50\'den fazla. Lütfen onaylayın.');
      }
    }

    // KDV oranı değişikliği kontrolü
    if (oldProduct.salesTaxRate != newProduct.salesTaxRate) {
      errors.add('KDV oranı değişikliği muhasebe departmanı onayı gerektirir');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Barkod geçerliliği kontrolü
  static bool _isValidBarcode(String barcode) {
    // Sadece rakam ve harf içerebilir
    return RegExp(r'^[A-Za-z0-9]+$').hasMatch(barcode);
  }

  /// GTIP kodu geçerliliği kontrolü
  static bool _isValidGtipCode(String gtipCode) {
    // 8-12 haneli rakam olmalı
    return RegExp(r'^\d{8,12}$').hasMatch(gtipCode);
  }

  /// Ülke kodu geçerliliği kontrolü
  static bool _isValidCountryCode(String countryCode) {
    // ISO 3166-1 alpha-2 veya alpha-3
    return RegExp(r'^[A-Z]{2,3}$').hasMatch(countryCode);
  }

  /// Para birimi geçerliliği kontrolü
  static bool _isValidCurrency(String currency) {
    const validCurrencies = [
      'TRY',
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CHF',
      'CAD',
      'AUD'
    ];
    return validCurrencies.contains(currency.toUpperCase());
  }

  /// Ürün silme doğrulaması
  static ValidationResult validateDelete(Product product) {
    final errors = <String>[];

    // Stokta ürün varsa silme engellenir
    if (product.totalStockQuantity > 0) {
      errors.add('Stokta ürün varken silme işlemi yapılamaz');
    }

    // Son 30 gün içinde satış varsa silme engellenir
    // TODO: Satış geçmişi kontrolü eklenebilir

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Doğrulama sonucu
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
}
