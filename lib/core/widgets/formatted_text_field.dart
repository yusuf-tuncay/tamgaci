import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../validators/input_validators.dart';

/// Formatlanmış ad/soyad input alanı
class FormattedNameField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool required;
  final VoidCallback? onChanged;

  const FormattedNameField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.required = true,
    this.onChanged,
  });

  @override
  State<FormattedNameField> createState() => _FormattedNameFieldState();
}

class _FormattedNameFieldState extends State<FormattedNameField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.format_size),
          onPressed: () {
            final formattedValue =
                InputValidators.formatName(widget.controller.text);
            widget.controller.text = formattedValue;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: formattedValue.length),
            );
            widget.onChanged?.call();
          },
          tooltip: 'İlk harfleri büyük yap',
        ),
      ),
      inputFormatters: [InputFormatters.nameFormatter],
      validator: widget.validator ?? InputValidators.validateName,
      onChanged: (value) {
        widget.onChanged?.call();
      },
      textCapitalization: TextCapitalization.words,
    );
  }
}

/// Formatlanmış telefon numarası input alanı
class FormattedPhoneField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool required;
  final VoidCallback? onChanged;

  const FormattedPhoneField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.required = true,
    this.onChanged,
  });

  @override
  State<FormattedPhoneField> createState() => _FormattedPhoneFieldState();
}

class _FormattedPhoneFieldState extends State<FormattedPhoneField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint ?? '+90 543 288 1296',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            final formattedValue =
                InputValidators.formatPhone(widget.controller.text);
            widget.controller.text = formattedValue;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: formattedValue.length),
            );
            widget.onChanged?.call();
          },
          tooltip: 'Telefon formatını düzenle',
        ),
      ),
      inputFormatters: [InputFormatters.phoneFormatter],
      validator: widget.validator ?? InputValidators.validatePhone,
      onChanged: (value) {
        widget.onChanged?.call();
      },
      keyboardType: TextInputType.phone,
    );
  }
}

/// Formatlanmış e-posta input alanı
class FormattedEmailField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool required;
  final VoidCallback? onChanged;

  const FormattedEmailField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.required = true,
    this.onChanged,
  });

  @override
  State<FormattedEmailField> createState() => _FormattedEmailFieldState();
}

class _FormattedEmailFieldState extends State<FormattedEmailField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint ?? 'ornek@email.com',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.email),
          onPressed: () {
            final formattedValue =
                InputValidators.formatEmail(widget.controller.text);
            widget.controller.text = formattedValue;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: formattedValue.length),
            );
            widget.onChanged?.call();
          },
          tooltip: 'E-posta formatını düzenle',
        ),
      ),
      inputFormatters: [InputFormatters.emailFormatter],
      validator: widget.validator ?? InputValidators.validateEmail,
      onChanged: (value) {
        widget.onChanged?.call();
      },
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }
}

/// Formatlanmış parola input alanı
class FormattedPasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool required;
  final VoidCallback? onChanged;
  final bool showPasswordToggle;

  const FormattedPasswordField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.required = true,
    this.onChanged,
    this.showPasswordToggle = true,
  });

  @override
  State<FormattedPasswordField> createState() => _FormattedPasswordFieldState();
}

class _FormattedPasswordFieldState extends State<FormattedPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: widget.showPasswordToggle
            ? IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                tooltip: _obscureText ? 'Parolayı göster' : 'Parolayı gizle',
              )
            : null,
      ),
      inputFormatters: [InputFormatters.passwordFormatter],
      validator: widget.validator ?? InputValidators.validatePassword,
      onChanged: (value) {
        widget.onChanged?.call();
      },
      textInputAction: TextInputAction.done,
    );
  }
}

/// Otomatik formatlanan input alanı (genel kullanım için)
class AutoFormattedTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String Function(String)? formatter;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool required;
  final VoidCallback? onChanged;
  final Widget? suffixIcon;

  const AutoFormattedTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.formatter,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.required = true,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AutoFormattedTextField> createState() => _AutoFormattedTextFieldState();
}

class _AutoFormattedTextFieldState extends State<AutoFormattedTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        suffixIcon: widget.suffixIcon,
      ),
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: (value) {
        // Otomatik formatlama
        if (widget.formatter != null && value.isNotEmpty) {
          final formattedValue = widget.formatter!(value);
          if (formattedValue != value) {
            widget.controller.text = formattedValue;
            widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: formattedValue.length),
            );
          }
        }
        widget.onChanged?.call();
      },
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
    );
  }
}
