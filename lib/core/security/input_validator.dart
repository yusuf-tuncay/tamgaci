/// Comprehensive input validation class
class InputValidator {
  /// Email validation
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.error('E-posta adresi gereklidir');
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Geçerli bir e-posta adresi giriniz');
    }

    if (email.length > 254) {
      return ValidationResult.error('E-posta adresi çok uzun');
    }

    return ValidationResult.success();
  }

  /// Phone number validation
  static ValidationResult validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.error('Telefon numarası gereklidir');
    }

    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return ValidationResult.error('Geçerli bir telefon numarası giriniz');
    }

    return ValidationResult.success();
  }

  /// Turkish phone number validation
  static ValidationResult validateTurkishPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.error('Telefon numarası gereklidir');
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Turkish mobile numbers start with 5
    if (cleanPhone.startsWith('5') && cleanPhone.length == 11) {
      return ValidationResult.success();
    }

    // Turkish landline numbers
    if (cleanPhone.startsWith('2') && cleanPhone.length == 11) {
      return ValidationResult.success();
    }

    return ValidationResult.error(
        'Geçerli bir Türkiye telefon numarası giriniz');
  }

  /// Name validation
  static ValidationResult validateName(String? name) {
    if (name == null || name.isEmpty) {
      return ValidationResult.error('İsim gereklidir');
    }

    if (name.length < 2) {
      return ValidationResult.error('İsim en az 2 karakter olmalıdır');
    }

    if (name.length > 100) {
      return ValidationResult.error('İsim çok uzun');
    }

    // Check for valid characters (letters, spaces, Turkish characters)
    final nameRegex = RegExp(r'^[a-zA-ZçğıöşüÇĞIİÖŞÜ\s]+$');
    if (!nameRegex.hasMatch(name)) {
      return ValidationResult.error('İsim sadece harf ve boşluk içerebilir');
    }

    return ValidationResult.success();
  }

  /// Company name validation
  static ValidationResult validateCompanyName(String? name) {
    if (name == null || name.isEmpty) {
      return ValidationResult.error('Şirket adı gereklidir');
    }

    if (name.length < 2) {
      return ValidationResult.error('Şirket adı en az 2 karakter olmalıdır');
    }

    if (name.length > 200) {
      return ValidationResult.error('Şirket adı çok uzun');
    }

    return ValidationResult.success();
  }

  /// Tax number validation (Turkish)
  static ValidationResult validateTaxNumber(String? taxNumber) {
    if (taxNumber == null || taxNumber.isEmpty) {
      return ValidationResult.success(); // Tax number is optional
    }

    final cleanTaxNumber = taxNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanTaxNumber.length != 10) {
      return ValidationResult.error('Vergi numarası 10 haneli olmalıdır');
    }

    // Turkish tax number validation algorithm
    if (!_isValidTurkishTaxNumber(cleanTaxNumber)) {
      return ValidationResult.error('Geçersiz vergi numarası');
    }

    return ValidationResult.success();
  }

  /// TCKN (Turkish ID) validation
  static ValidationResult validateTCKN(String? tckn) {
    if (tckn == null || tckn.isEmpty) {
      return ValidationResult.success(); // TCKN is optional
    }

    final cleanTCKN = tckn.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanTCKN.length != 11) {
      return ValidationResult.error('TC Kimlik No 11 haneli olmalıdır');
    }

    if (!_isValidTCKN(cleanTCKN)) {
      return ValidationResult.error('Geçersiz TC Kimlik No');
    }

    return ValidationResult.success();
  }

  /// Password validation
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.error('Şifre gereklidir');
    }

    if (password.length < 8) {
      return ValidationResult.error('Şifre en az 8 karakter olmalıdır');
    }

    if (password.length > 128) {
      return ValidationResult.error('Şifre çok uzun');
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult.error('Şifre en az bir büyük harf içermelidir');
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult.error('Şifre en az bir küçük harf içermelidir');
    }

    // Check for at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult.error('Şifre en az bir rakam içermelidir');
    }

    return ValidationResult.success();
  }

  /// Amount validation
  static ValidationResult validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return ValidationResult.error('Miktar gereklidir');
    }

    final amountValue = double.tryParse(amount.replaceAll(',', '.'));
    if (amountValue == null) {
      return ValidationResult.error('Geçerli bir miktar giriniz');
    }

    if (amountValue < 0) {
      return ValidationResult.error('Miktar negatif olamaz');
    }

    if (amountValue > 999999999.99) {
      return ValidationResult.error('Miktar çok büyük');
    }

    return ValidationResult.success();
  }

  /// Quantity validation
  static ValidationResult validateQuantity(String? quantity) {
    if (quantity == null || quantity.isEmpty) {
      return ValidationResult.error('Miktar gereklidir');
    }

    final quantityValue = int.tryParse(quantity);
    if (quantityValue == null) {
      return ValidationResult.error('Geçerli bir miktar giriniz');
    }

    if (quantityValue < 0) {
      return ValidationResult.error('Miktar negatif olamaz');
    }

    if (quantityValue > 999999) {
      return ValidationResult.error('Miktar çok büyük');
    }

    return ValidationResult.success();
  }

  /// Address validation
  static ValidationResult validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return ValidationResult.success(); // Address is optional
    }

    if (address.length > 500) {
      return ValidationResult.error('Adres çok uzun');
    }

    return ValidationResult.success();
  }

  /// Notes validation
  static ValidationResult validateNotes(String? notes) {
    if (notes == null || notes.isEmpty) {
      return ValidationResult.success(); // Notes are optional
    }

    if (notes.length > 1000) {
      return ValidationResult.error('Notlar çok uzun');
    }

    return ValidationResult.success();
  }

  /// URL validation
  static ValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult.success(); // URL is optional
    }

    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(url)) {
      return ValidationResult.error('Geçerli bir URL giriniz');
    }

    return ValidationResult.success();
  }

  /// Turkish tax number validation algorithm
  static bool _isValidTurkishTaxNumber(String taxNumber) {
    if (taxNumber.length != 10) return false;

    final digits = taxNumber.split('').map(int.parse).toList();

    // First 9 digits
    final first9 = digits.take(9).toList();

    // Calculate check digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      int temp = (first9[i] + (10 - i - 1)) % 10;
      sum += temp * (1 << (10 - i - 1)) % 9;
    }

    int checkDigit = (10 - (sum % 10)) % 10;

    return checkDigit == digits[9];
  }

  /// Turkish TCKN validation algorithm
  static bool _isValidTCKN(String tckn) {
    if (tckn.length != 11) return false;

    final digits = tckn.split('').map(int.parse).toList();

    // All digits cannot be the same
    if (digits.every((digit) => digit == digits[0])) return false;

    // Calculate check digits
    int sum1 = 0;
    int sum2 = 0;

    for (int i = 0; i < 9; i++) {
      if (i % 2 == 0) {
        sum1 += digits[i];
      } else {
        sum2 += digits[i];
      }
    }

    int check1 = (sum1 * 7 - sum2) % 10;
    int check2 = (sum1 + sum2 + check1) % 10;

    return check1 == digits[9] && check2 == digits[10];
  }

  /// Validate multiple fields at once
  static Map<String, ValidationResult> validateFields(
      Map<String, String?> fields) {
    final results = <String, ValidationResult>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      ValidationResult result;

      switch (fieldName.toLowerCase()) {
        case 'email':
          result = validateEmail(value);
          break;
        case 'phone':
        case 'telefon':
          result = validateTurkishPhone(value);
          break;
        case 'name':
        case 'isim':
          result = validateName(value);
          break;
        case 'companyname':
        case 'sirketadi':
          result = validateCompanyName(value);
          break;
        case 'taxnumber':
        case 'vergino':
          result = validateTaxNumber(value);
          break;
        case 'tckn':
        case 'tcno':
          result = validateTCKN(value);
          break;
        case 'password':
        case 'sifre':
          result = validatePassword(value);
          break;
        case 'amount':
        case 'miktar':
          result = validateAmount(value);
          break;
        case 'quantity':
        case 'adet':
          result = validateQuantity(value);
          break;
        case 'address':
        case 'adres':
          result = validateAddress(value);
          break;
        case 'notes':
        case 'notlar':
          result = validateNotes(value);
          break;
        case 'url':
          result = validateUrl(value);
          break;
        default:
          result = ValidationResult.success();
      }

      results[fieldName] = result;
    }

    return results;
  }
}

/// Validation result class
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => const ValidationResult._(true, null);

  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $errorMessage';
  }
}

/// Email validation (boolean)
bool isValidEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email) && email.length <= 254;
}

/// Phone validation (boolean)
bool isValidPhone(String? phone) {
  if (phone == null || phone.isEmpty) return false;
  final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
  return cleanPhone.length >= 10 && cleanPhone.length <= 15;
}

/// Name validation (boolean)
bool isValidName(String? name) {
  if (name == null || name.isEmpty) return false;
  return name.length >= 2 && name.length <= 100;
}

/// Password validation (boolean)
bool isValidPassword(String? password) {
  if (password == null || password.isEmpty) return false;
  return password.length >= 6;
}
