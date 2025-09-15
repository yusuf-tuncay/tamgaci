// ========== INPUT VALIDATOR ==========
// lib/core/validation/input_validator.dart

/// Input validation utility class
class InputValidator {
  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Phone validation regex (Turkish phone numbers)
  static final RegExp _phoneRegex = RegExp(
    r'^(\+90|0)?[5][0-9]{9}$',
  );

  /// Name validation regex (Turkish characters included)
  static final RegExp _nameRegex = RegExp(
    r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]{2,50}$',
  );

  /// Password validation regex (at least 8 characters, 1 uppercase, 1 lowercase, 1 number)
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  /// URL validation regex
  static final RegExp _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validate email address
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  /// Validate phone number (Turkish format)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;

    // Remove all non-digit characters except +
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return _phoneRegex.hasMatch(cleanPhone);
  }

  /// Validate name (Turkish characters included)
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) return false;
    return _nameRegex.hasMatch(name);
  }

  /// Validate password
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return _passwordRegex.hasMatch(password);
  }

  /// Validate URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return _urlRegex.hasMatch(url);
  }

  /// Validate required field
  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validate minimum length
  static bool hasMinLength(String? value, int minLength) {
    if (value == null) return false;
    return value.trim().length >= minLength;
  }

  /// Validate maximum length
  static bool hasMaxLength(String? value, int maxLength) {
    if (value == null) return false;
    return value.trim().length <= maxLength;
  }

  /// Validate length range
  static bool hasLengthRange(String? value, int minLength, int maxLength) {
    if (value == null) return false;
    final length = value.trim().length;
    return length >= minLength && length <= maxLength;
  }

  /// Validate numeric value
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value.replaceAll(',', '.')) != null;
  }

  /// Validate integer value
  static bool isInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  /// Validate positive number
  static bool isPositiveNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    final number = double.tryParse(value.replaceAll(',', '.'));
    return number != null && number > 0;
  }

  /// Validate non-negative number
  static bool isNonNegativeNumber(String? value) {
    if (value == null || value.isEmpty) return false;
    final number = double.tryParse(value.replaceAll(',', '.'));
    return number != null && number >= 0;
  }

  /// Validate date format (DD/MM/YYYY)
  static bool isValidDateFormat(String? date) {
    if (date == null || date.isEmpty) return false;

    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(date)) return false;

    try {
      final parts = date.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > 2100) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate time format (HH:MM)
  static bool isValidTimeFormat(String? time) {
    if (time == null || time.isEmpty) return false;

    final timeRegex = RegExp(r'^\d{2}:\d{2}$');
    if (!timeRegex.hasMatch(time)) return false;

    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23) return false;
      if (minute < 0 || minute > 59) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate Turkish tax number (11 digits)
  static bool isValidTaxNumber(String? taxNumber) {
    if (taxNumber == null || taxNumber.isEmpty) return false;

    final cleanTaxNumber = taxNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanTaxNumber.length != 11) return false;

    // Turkish tax number validation algorithm
    final digits = cleanTaxNumber.split('').map(int.parse).toList();

    // First digit cannot be 0
    if (digits[0] == 0) return false;

    // Calculate checksum
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }

    final remainder = sum % 11;
    final checkDigit1 = remainder < 2 ? remainder : 11 - remainder;

    if (digits[9] != checkDigit1) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }

    final remainder2 = sum % 11;
    final checkDigit2 = remainder2 < 2 ? remainder2 : 11 - remainder2;

    return digits[10] == checkDigit2;
  }

  /// Validate Turkish ID number (11 digits)
  static bool isValidTurkishId(String? idNumber) {
    if (idNumber == null || idNumber.isEmpty) return false;

    final cleanId = idNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanId.length != 11) return false;

    // Turkish ID number validation algorithm
    final digits = cleanId.split('').map(int.parse).toList();

    // First digit cannot be 0
    if (digits[0] == 0) return false;

    // Calculate checksum
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }

    final remainder = sum % 11;
    final checkDigit1 = remainder < 2 ? remainder : 11 - remainder;

    if (digits[9] != checkDigit1) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }

    final remainder2 = sum % 11;
    final checkDigit2 = remainder2 < 2 ? remainder2 : 11 - remainder2;

    return digits[10] == checkDigit2;
  }

  /// Validate credit card number (Luhn algorithm)
  static bool isValidCreditCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return false;

    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanCardNumber.length < 13 || cleanCardNumber.length > 19) {
      return false;
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = cleanCardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanCardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validate IBAN (Turkish format)
  static bool isValidIban(String? iban) {
    if (iban == null || iban.isEmpty) return false;

    final cleanIban = iban.replaceAll(RegExp(r'[^\w]'), '').toUpperCase();
    if (cleanIban.length != 26) return false;

    // Turkish IBAN format: TR + 2 check digits + 22 digits
    if (!cleanIban.startsWith('TR')) return false;

    // Move first 4 characters to end
    final rearranged = cleanIban.substring(4) + cleanIban.substring(0, 4);

    // Convert letters to numbers (A=10, B=11, ..., Z=35)
    String numericString = '';
    for (int i = 0; i < rearranged.length; i++) {
      final char = rearranged[i];
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        numericString += (char.codeUnitAt(0) - 55).toString();
      } else {
        numericString += char;
      }
    }

    // Calculate mod 97
    int remainder = 0;
    for (int i = 0; i < numericString.length; i++) {
      remainder = (remainder * 10 + int.parse(numericString[i])) % 97;
    }

    return remainder == 1;
  }

  /// Get validation error message
  static String? getValidationError(String? value, ValidationType type) {
    switch (type) {
      case ValidationType.email:
        if (!isValidEmail(value)) {
          return 'Geçerli bir e-posta adresi giriniz';
        }
        break;
      case ValidationType.phone:
        if (!isValidPhone(value)) {
          return 'Geçerli bir telefon numarası giriniz';
        }
        break;
      case ValidationType.name:
        if (!isValidName(value)) {
          return 'Geçerli bir isim giriniz (2-50 karakter)';
        }
        break;
      case ValidationType.password:
        if (!isValidPassword(value)) {
          return 'Şifre en az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam içermelidir';
        }
        break;
      case ValidationType.required:
        if (!isRequired(value)) {
          return 'Bu alan zorunludur';
        }
        break;
      case ValidationType.numeric:
        if (!isNumeric(value)) {
          return 'Geçerli bir sayı giriniz';
        }
        break;
      case ValidationType.positiveNumber:
        if (!isPositiveNumber(value)) {
          return 'Pozitif bir sayı giriniz';
        }
        break;
      case ValidationType.nonNegativeNumber:
        if (!isNonNegativeNumber(value)) {
          return 'Sıfır veya pozitif bir sayı giriniz';
        }
        break;
      case ValidationType.date:
        if (!isValidDateFormat(value)) {
          return 'Geçerli bir tarih giriniz (GG/AA/YYYY)';
        }
        break;
      case ValidationType.time:
        if (!isValidTimeFormat(value)) {
          return 'Geçerli bir saat giriniz (SS:DD)';
        }
        break;
      case ValidationType.taxNumber:
        if (!isValidTaxNumber(value)) {
          return 'Geçerli bir vergi numarası giriniz';
        }
        break;
      case ValidationType.turkishId:
        if (!isValidTurkishId(value)) {
          return 'Geçerli bir TC kimlik numarası giriniz';
        }
        break;
      case ValidationType.creditCard:
        if (!isValidCreditCard(value)) {
          return 'Geçerli bir kredi kartı numarası giriniz';
        }
        break;
      case ValidationType.iban:
        if (!isValidIban(value)) {
          return 'Geçerli bir IBAN giriniz';
        }
        break;
    }
    return null;
  }
}

/// Validation types enum
enum ValidationType {
  email,
  phone,
  name,
  password,
  required,
  numeric,
  positiveNumber,
  nonNegativeNumber,
  date,
  time,
  taxNumber,
  turkishId,
  creditCard,
  iban,
}
