// ========== FORM VALIDATORS ==========
// lib/core/validation/form_validators.dart

import 'package:flutter/material.dart';
import 'package:tamgaci/core/validation/input_validator.dart';
import 'package:tamgaci/core/validation/data_sanitizer.dart';

/// Form validation mixin for widgets
mixin FormValidationMixin<T extends StatefulWidget> on State<T> {
  final Map<String, String?> _fieldErrors = {};
  final Map<String, TextEditingController> _controllers = {};

  /// Get field error message
  String? getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  /// Set field error message
  void setFieldError(String fieldName, String? error) {
    setState(() {
      _fieldErrors[fieldName] = error;
    });
  }

  /// Clear field error
  void clearFieldError(String fieldName) {
    setState(() {
      _fieldErrors.remove(fieldName);
    });
  }

  /// Clear all field errors
  void clearAllFieldErrors() {
    setState(() {
      _fieldErrors.clear();
    });
  }

  /// Check if form is valid
  bool get isFormValid => _fieldErrors.isEmpty;

  /// Validate single field
  bool validateField(String fieldName, String value, ValidationType type) {
    final sanitizedValue = DataSanitizer.sanitizeText(value);
    String? errorMessage;

    switch (type) {
      case ValidationType.email:
        if (!InputValidator.isValidEmail(sanitizedValue)) {
          errorMessage = 'Geçerli bir e-posta adresi giriniz';
        }
        break;
      case ValidationType.phone:
        if (!InputValidator.isValidPhone(sanitizedValue)) {
          errorMessage = 'Geçerli bir telefon numarası giriniz';
        }
        break;
      case ValidationType.name:
        if (!InputValidator.isValidName(sanitizedValue)) {
          errorMessage = 'Geçerli bir isim giriniz (2-50 karakter)';
        }
        break;
      case ValidationType.password:
        if (!InputValidator.isValidPassword(sanitizedValue)) {
          errorMessage =
              'Şifre en az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam içermelidir';
        }
        break;
      case ValidationType.required:
        if (!InputValidator.isRequired(sanitizedValue)) {
          errorMessage = 'Bu alan zorunludur';
        }
        break;
      case ValidationType.numeric:
        if (!InputValidator.isNumeric(sanitizedValue)) {
          errorMessage = 'Geçerli bir sayı giriniz';
        }
        break;
      case ValidationType.positiveNumber:
        if (!InputValidator.isPositiveNumber(sanitizedValue)) {
          errorMessage = 'Pozitif bir sayı giriniz';
        }
        break;
      case ValidationType.nonNegativeNumber:
        if (!InputValidator.isNonNegativeNumber(sanitizedValue)) {
          errorMessage = 'Sıfır veya pozitif bir sayı giriniz';
        }
        break;
      case ValidationType.date:
        if (!InputValidator.isValidDateFormat(sanitizedValue)) {
          errorMessage = 'Geçerli bir tarih giriniz (GG/AA/YYYY)';
        }
        break;
      case ValidationType.time:
        if (!InputValidator.isValidTimeFormat(sanitizedValue)) {
          errorMessage = 'Geçerli bir saat giriniz (SS:DD)';
        }
        break;
      case ValidationType.taxNumber:
        if (!InputValidator.isValidTaxNumber(sanitizedValue)) {
          errorMessage = 'Geçerli bir vergi numarası giriniz';
        }
        break;
      case ValidationType.turkishId:
        if (!InputValidator.isValidTurkishId(sanitizedValue)) {
          errorMessage = 'Geçerli bir TC kimlik numarası giriniz';
        }
        break;
      case ValidationType.creditCard:
        if (!InputValidator.isValidCreditCard(sanitizedValue)) {
          errorMessage = 'Geçerli bir kredi kartı numarası giriniz';
        }
        break;
      case ValidationType.iban:
        if (!InputValidator.isValidIban(sanitizedValue)) {
          errorMessage = 'Geçerli bir IBAN giriniz';
        }
        break;
    }

    setFieldError(fieldName, errorMessage);
    return errorMessage == null;
  }

  /// Validate all fields
  bool validateAllFields(Map<String, ValidationType> fieldValidations) {
    bool isValid = true;

    for (final entry in fieldValidations.entries) {
      final fieldName = entry.key;
      final validationType = entry.value;
      final controller = _controllers[fieldName];
      final value = controller?.text ?? '';

      if (!validateField(fieldName, value, validationType)) {
        isValid = false;
      }
    }

    return isValid;
  }

  /// Get controller for field
  TextEditingController getController(String fieldName) {
    if (!_controllers.containsKey(fieldName)) {
      _controllers[fieldName] = TextEditingController();
    }
    return _controllers[fieldName]!;
  }

  /// Dispose all controllers
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Form validator class
class FormValidator {
  final Map<String, String?> _fieldErrors = {};

  /// Validate field
  bool validateField(String fieldName, String value, ValidationType type) {
    final sanitizedValue = DataSanitizer.sanitizeText(value);
    final errorMessage =
        InputValidator.getValidationError(sanitizedValue, type);

    _fieldErrors[fieldName] = errorMessage;
    return errorMessage == null;
  }

  /// Get field error
  String? getFieldError(String fieldName) {
    return _fieldErrors[fieldName];
  }

  /// Clear field error
  void clearFieldError(String fieldName) {
    _fieldErrors.remove(fieldName);
  }

  /// Clear all errors
  void clearAllErrors() {
    _fieldErrors.clear();
  }

  /// Check if form is valid
  bool get isFormValid => _fieldErrors.isEmpty;

  /// Get all errors
  Map<String, String?> get allErrors => Map.unmodifiable(_fieldErrors);
}

/// Validated text field widget
class ValidatedTextField extends StatefulWidget {
  final String fieldName;
  final ValidationType validationType;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final FormValidator? formValidator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final InputDecoration? decoration;

  const ValidatedTextField({
    super.key,
    required this.fieldName,
    required this.validationType,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.formValidator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.decoration,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  late TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          readOnly: widget.readOnly,
          decoration: widget.decoration ??
              InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
          onChanged: (value) {
            if (widget.formValidator != null) {
              final isValid = widget.formValidator!.validateField(
                widget.fieldName,
                value,
                widget.validationType,
              );
              setState(() {
                _errorMessage = isValid
                    ? null
                    : widget.formValidator!.getFieldError(widget.fieldName);
              });
            }
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
        ),
      ],
    );
  }
}

/// Validation helper methods
class ValidationHelper {
  /// Validate email
  static bool isValidEmail(String? email) {
    return InputValidator.isValidEmail(email);
  }

  /// Validate phone
  static bool isValidPhone(String? phone) {
    return InputValidator.isValidPhone(phone);
  }

  /// Validate name
  static bool isValidName(String? name) {
    return InputValidator.isValidName(name);
  }

  /// Validate password
  static bool isValidPassword(String? password) {
    return InputValidator.isValidPassword(password);
  }

  /// Validate required field
  static bool isRequired(String? value) {
    return InputValidator.isRequired(value);
  }

  /// Validate numeric value
  static bool isNumeric(String? value) {
    return InputValidator.isNumeric(value);
  }

  /// Validate positive number
  static bool isPositiveNumber(String? value) {
    return InputValidator.isPositiveNumber(value);
  }

  /// Validate non-negative number
  static bool isNonNegativeNumber(String? value) {
    return InputValidator.isNonNegativeNumber(value);
  }

  /// Validate date format
  static bool isValidDateFormat(String? date) {
    return InputValidator.isValidDateFormat(date);
  }

  /// Validate time format
  static bool isValidTimeFormat(String? time) {
    return InputValidator.isValidTimeFormat(time);
  }

  /// Validate tax number
  static bool isValidTaxNumber(String? taxNumber) {
    return InputValidator.isValidTaxNumber(taxNumber);
  }

  /// Validate Turkish ID
  static bool isValidTurkishId(String? idNumber) {
    return InputValidator.isValidTurkishId(idNumber);
  }

  /// Validate credit card
  static bool isValidCreditCard(String? cardNumber) {
    return InputValidator.isValidCreditCard(cardNumber);
  }

  /// Validate IBAN
  static bool isValidIban(String? iban) {
    return InputValidator.isValidIban(iban);
  }
}
