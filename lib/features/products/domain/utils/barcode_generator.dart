// ========== BARCODE GENERATOR ==========
// lib/features/products/domain/utils/barcode_generator.dart

import 'dart:math';

/// GS1 barkod üretimi için utility sınıfı
class BarcodeGenerator {
  /// GS1 Company Prefix (Türkiye için 869)
  static const String _gs1Prefix = '869';

  /// Ürün kodu uzunluğu (GS1-13 için 13 karakter)
  static const int _barcodeLength = 13;

  /// GS1 barkod üret
  /// [companyCode]: Şirket kodu (3-5 haneli)
  /// [productCode]: Ürün kodu (kalan haneler)
  static String generateGS1Barcode({
    required String companyCode,
    required String productCode,
  }) {
    // Company code'u 5 haneli yap
    final paddedCompanyCode = companyCode.padLeft(5, '0');

    // Product code'u kalan hanelerle doldur
    final remainingDigits = _barcodeLength -
        _gs1Prefix.length -
        paddedCompanyCode.length -
        1; // -1 for check digit
    final paddedProductCode = productCode.padLeft(remainingDigits, '0');

    // GS1 prefix + company code + product code
    final barcodeWithoutCheck =
        _gs1Prefix + paddedCompanyCode + paddedProductCode;

    // Check digit hesapla
    final checkDigit = _calculateCheckDigit(barcodeWithoutCheck);

    return barcodeWithoutCheck + checkDigit.toString();
  }

  /// Rastgele GS1 barkod üret
  static String generateRandomGS1Barcode({
    String? companyCode,
  }) {
    final company = companyCode ?? _generateRandomCompanyCode();
    final productCode = _generateRandomProductCode();

    return generateGS1Barcode(
      companyCode: company,
      productCode: productCode,
    );
  }

  /// Check digit hesapla (EAN-13 algoritması)
  static int _calculateCheckDigit(String barcode) {
    int sum = 0;

    for (int i = 0; i < barcode.length; i++) {
      final digit = int.parse(barcode[i]);
      // Tek pozisyonlarda 3 ile çarp
      if (i % 2 == 1) {
        sum += digit * 3;
      } else {
        sum += digit;
      }
    }

    // Check digit = 10 - (sum % 10)
    final checkDigit = 10 - (sum % 10);
    return checkDigit == 10 ? 0 : checkDigit;
  }

  /// Rastgele şirket kodu üret (3-5 haneli)
  static String _generateRandomCompanyCode() {
    final random = Random();
    final length = random.nextInt(3) + 3; // 3-5 haneli
    final code = random.nextInt(99999).toString().padLeft(length, '0');
    return code.substring(0, length);
  }

  /// Rastgele ürün kodu üret
  static String _generateRandomProductCode() {
    final random = Random();
    return random.nextInt(999999).toString().padLeft(6, '0');
  }

  /// Barkod geçerliliğini kontrol et
  static bool isValidBarcode(String barcode) {
    if (barcode.length != _barcodeLength) return false;

    try {
      // Son karakter check digit
      final checkDigit = int.parse(barcode[barcode.length - 1]);
      final barcodeWithoutCheck = barcode.substring(0, barcode.length - 1);
      final calculatedCheckDigit = _calculateCheckDigit(barcodeWithoutCheck);

      return checkDigit == calculatedCheckDigit;
    } catch (e) {
      return false;
    }
  }

  /// GS1 barkod formatını kontrol et
  static bool isGS1Barcode(String barcode) {
    if (!isValidBarcode(barcode)) return false;
    return barcode.startsWith(_gs1Prefix);
  }

  /// Barkoddan şirket kodunu çıkar
  static String? extractCompanyCode(String barcode) {
    if (!isGS1Barcode(barcode)) return null;

    // GS1 prefix'ten sonraki 5 karakter şirket kodu
    return barcode.substring(3, 8);
  }

  /// Barkoddan ürün kodunu çıkar
  static String? extractProductCode(String barcode) {
    if (!isGS1Barcode(barcode)) return null;

    // Şirket kodundan sonraki karakterler ürün kodu (check digit hariç)
    return barcode.substring(8, 12);
  }
}
