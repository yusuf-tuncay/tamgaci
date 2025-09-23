// ========== VALIDATORS ==========
// lib/core/utils/validators.dart

/// Form doğrulama yardımcı sınıfı
class Validators {
  /// Zorunlu alan kontrolü
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur';
    }
    return null;
  }

  /// E-posta formatı kontrolü
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Telefon numarası formatı kontrolü
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    // Türkiye telefon numarası formatı (0555 123 45 67, +90 555 123 45 67, vb.)
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Geçerli bir telefon numarası girin (0555 123 45 67)';
    }
    return null;
  }

  /// Vergi numarası formatı kontrolü
  static String? taxNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    final cleanTaxNumber = value.replaceAll(RegExp(r'[\s\-]'), '');

    // T.C. Kimlik No (11 haneli)
    if (cleanTaxNumber.length == 11) {
      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanTaxNumber)) {
        return 'T.C. Kimlik No 11 haneli olmalıdır';
      }

      // T.C. Kimlik No algoritması kontrolü
      if (!_isValidTurkishId(cleanTaxNumber)) {
        return 'Geçersiz T.C. Kimlik No';
      }
    }
    // Vergi Numarası (10 haneli)
    else if (cleanTaxNumber.length == 10) {
      if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanTaxNumber)) {
        return 'Vergi numarası 10 haneli olmalıdır';
      }

      // Vergi numarası algoritması kontrolü
      if (!_isValidTaxNumber(cleanTaxNumber)) {
        return 'Geçersiz vergi numarası';
      }
    } else {
      return 'T.C. Kimlik No (11 hane) veya Vergi No (10 hane) girin';
    }

    return null;
  }

  /// Ondalık sayı kontrolü
  static String? decimal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    final cleanValue = value.replaceAll(',', '.');
    final decimalRegex = RegExp(r'^\d+(\.\d+)?$');

    if (!decimalRegex.hasMatch(cleanValue)) {
      return 'Geçerli bir sayı girin (örn: 123.45)';
    }

    final doubleValue = double.tryParse(cleanValue);
    if (doubleValue == null) {
      return 'Geçerli bir sayı girin';
    }

    if (doubleValue < 0) {
      return 'Negatif değer giremezsiniz';
    }

    return null;
  }

  /// Tam sayı kontrolü
  static String? integer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    final integerRegex = RegExp(r'^\d+$');

    if (!integerRegex.hasMatch(value.trim())) {
      return 'Geçerli bir tam sayı girin';
    }

    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return 'Geçerli bir tam sayı girin';
    }

    if (intValue < 0) {
      return 'Negatif değer giremezsiniz';
    }

    return null;
  }

  /// URL formatı kontrolü
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Zorunlu değilse boş bırakılabilir
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Geçerli bir URL girin (örn: https://www.ornek.com)';
    }

    return null;
  }

  /// T.C. Kimlik No algoritması kontrolü
  static bool _isValidTurkishId(String id) {
    if (id.length != 11 || !RegExp(r'^[0-9]{11}$').hasMatch(id)) {
      return false;
    }

    // İlk hane 0 olamaz
    if (id[0] == '0') {
      return false;
    }

    // 1, 3, 5, 7, 9. hanelerin toplamı
    int oddSum = 0;
    for (int i = 0; i < 9; i += 2) {
      oddSum += int.parse(id[i]);
    }

    // 2, 4, 6, 8. hanelerin toplamı
    int evenSum = 0;
    for (int i = 1; i < 8; i += 2) {
      evenSum += int.parse(id[i]);
    }

    // 10. hane kontrolü
    int checkDigit1 = (oddSum * 7 - evenSum) % 10;
    if (checkDigit1 != int.parse(id[9])) {
      return false;
    }

    // 11. hane kontrolü
    int totalSum = oddSum + evenSum + checkDigit1;
    int checkDigit2 = totalSum % 10;
    if (checkDigit2 != int.parse(id[10])) {
      return false;
    }

    return true;
  }

  /// Vergi numarası algoritması kontrolü
  static bool _isValidTaxNumber(String taxNumber) {
    if (taxNumber.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(taxNumber)) {
      return false;
    }

    // İlk hane 0 olamaz
    if (taxNumber[0] == '0') {
      return false;
    }

    // Vergi numarası algoritması
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int digit = int.parse(taxNumber[i]);
      int temp = (digit + (9 - i)) % 10;
      int power = (temp * (1 << (9 - i))) % 9;
      sum += power;
    }

    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(taxNumber[9]);
  }
}
