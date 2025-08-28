import 'package:flutter/services.dart';

/// Merkezi input validasyon ve maskeleme sistemi
class InputValidators {
  // Ad ve soyad için minimum ve maksimum karakter sayıları
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Telefon numarası için karakter sayıları
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Parola için karakter sayıları
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // E-posta için karakter sayıları
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;

  /// Ad ve soyad validasyonu
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < minNameLength) {
      return 'En az $minNameLength karakter olmalıdır';
    }

    if (trimmedValue.length > maxNameLength) {
      return 'En fazla $maxNameLength karakter olabilir';
    }

    // Sadece harf, boşluk ve Türkçe karakterlere izin ver
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Sadece harf ve boşluk kullanabilirsiniz';
    }

    return null;
  }

  /// Ad ve soyadı formatla (ilk harfleri büyük yap)
  static String formatName(String value) {
    if (value.trim().isEmpty) return value;

    // Her kelimenin ilk harfini büyük yap, diğerlerini küçük yap
    return value.trim().split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Telefon numarası validasyonu
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur';
    }

    // Sadece rakamları al
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < minPhoneLength) {
      return 'Telefon numarası en az $minPhoneLength haneli olmalıdır';
    }

    if (digitsOnly.length > maxPhoneLength) {
      return 'Telefon numarası en fazla $maxPhoneLength haneli olabilir';
    }

    // Türkiye telefon numarası formatı kontrolü (5xx xxx xxxx)
    if (digitsOnly.length == 10 && digitsOnly.startsWith('5')) {
      return null;
    }

    // Uluslararası format kontrolü (+90 5xx xxx xxxx)
    if (digitsOnly.length == 12 && digitsOnly.startsWith('905')) {
      return null;
    }

    return 'Geçerli bir telefon numarası giriniz';
  }

  /// Telefon numarasını formatla (+90 543 288 1296)
  static String formatPhone(String value) {
    // Sadece rakamları al
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) return value;

    // Türkiye numarası ise (+90) ekle
    if (digitsOnly.length == 10 && digitsOnly.startsWith('5')) {
      return '+90 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
    }

    // Zaten uluslararası format ise
    if (digitsOnly.length == 12 && digitsOnly.startsWith('905')) {
      return '+${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8)}';
    }

    // Diğer durumlar için basit formatlama
    if (digitsOnly.length >= 10) {
      return '+90 ${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6, 10)}';
    }

    return value;
  }

  /// Parola validasyonu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Parola zorunludur';
    }

    if (value.length < minPasswordLength) {
      return 'Parola en az $minPasswordLength karakter olmalıdır';
    }

    if (value.length > maxPasswordLength) {
      return 'Parola en fazla $maxPasswordLength karakter olabilir';
    }

    // En az bir büyük harf, bir küçük harf ve bir rakam içermeli
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigits = RegExp(r'[0-9]').hasMatch(value);

    if (!hasUpperCase) {
      return 'En az bir büyük harf içermelidir';
    }

    if (!hasLowerCase) {
      return 'En az bir küçük harf içermelidir';
    }

    if (!hasDigits) {
      return 'En az bir rakam içermelidir';
    }

    return null;
  }

  /// E-posta validasyonu
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < minEmailLength) {
      return 'E-posta adresi en az $minEmailLength karakter olmalıdır';
    }

    if (trimmedValue.length > maxEmailLength) {
      return 'E-posta adresi en fazla $maxEmailLength karakter olabilir';
    }

    // E-posta format kontrolü
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  /// E-posta formatla (küçük harfe çevir)
  static String formatEmail(String value) {
    return value.trim().toLowerCase();
  }
}

/// Input maskeleme için TextInputFormatter'lar
class InputFormatters {
  /// Ad ve soyad için formatter (sadece harf ve boşluk)
  static TextInputFormatter nameFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ\s]'),
  );

  /// Telefon numarası için formatter (sadece rakam ve bazı özel karakterler)
  static TextInputFormatter phoneFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[\d\s\(\)\+\-]'),
  );

  /// E-posta için formatter (e-posta karakterleri)
  static TextInputFormatter emailFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9@._%+\-]'),
  );

  /// Parola için formatter (tüm karakterlere izin ver)
  static TextInputFormatter passwordFormatter =
      FilteringTextInputFormatter.allow(
    RegExp(r'.*'),
  );
}
