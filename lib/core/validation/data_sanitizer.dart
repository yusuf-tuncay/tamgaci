// ========== DATA SANITIZER ==========
// lib/core/validation/data_sanitizer.dart

/// Data sanitization utility class
class DataSanitizer {
  /// Sanitize text input
  static String sanitizeText(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp('[<>"\']'), '');
  }

  /// Sanitize email input
  static String sanitizeEmail(String? input) {
    if (input == null) return '';

    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// Sanitize phone number input
  static String sanitizePhone(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp(r'[^\d+\-\(\)\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize numeric input
  static String sanitizeNumeric(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
  }

  /// Sanitize name input
  static String sanitizeName(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize address input
  static String sanitizeAddress(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp('[<>"\']'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize description input
  static String sanitizeDescription(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp('[<>"\']'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize URL input
  static String sanitizeUrl(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// Sanitize search query
  static String sanitizeSearchQuery(String? input) {
    if (input == null) return '';

    return input
        .trim()
        .replaceAll(RegExp('[<>"\']'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitize password input
  static String sanitizePassword(String? input) {
    if (input == null) return '';

    return input.trim();
  }

  /// Sanitize code input (for product codes, etc.)
  static String sanitizeCode(String? input) {
    if (input == null) return '';

    return input.trim().toUpperCase().replaceAll(RegExp(r'[^\w]'), '');
  }

  /// Sanitize currency amount
  static String sanitizeCurrencyAmount(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
  }

  /// Sanitize percentage
  static String sanitizePercentage(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
  }

  /// Sanitize quantity
  static String sanitizeQuantity(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
  }

  /// Sanitize date input
  static String sanitizeDate(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d./-]'), '');
  }

  /// Sanitize time input
  static String sanitizeTime(String? input) {
    if (input == null) return '';

    return input.trim().replaceAll(RegExp(r'[^\d:]'), '');
  }
}
