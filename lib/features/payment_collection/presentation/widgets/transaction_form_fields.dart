// ========== TRANSACTION FORM FIELDS ==========
// lib/features/payment_collection/presentation/widgets/transaction_form_fields.dart

import 'package:flutter/material.dart';
import '../../domain/entities/payment_enums.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_source.dart';
import '../models/payment_transaction_form_model.dart';

/// İşlem form alanları widget'ı
class TransactionFormFields {
  /// İşlem türü alanı
  static Widget buildTransactionTypeField({
    required PaymentTransactionFormModel formState,
    required Function(PaymentTransactionType?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<PaymentTransactionType?>(
      initialValue: formState.type,
      decoration: const InputDecoration(
        labelText: 'İşlem Türü',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: PaymentTransactionType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getTypeText(type)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null) {
          return 'İşlem türü seçilmelidir';
        }
        return null;
      },
    );
  }

  /// İşlem yönü alanı
  static Widget buildDirectionField({
    required PaymentTransactionFormModel formState,
    required Function(PaymentDirection?) onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<PaymentDirection?>(
      initialValue: formState.direction,
      decoration: const InputDecoration(
        labelText: 'İşlem Yönü',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.swap_horiz),
      ),
      items: PaymentDirection.values.map((direction) {
        return DropdownMenuItem(
          value: direction,
          child: Text(_getDirectionText(direction)),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null) {
          return 'İşlem yönü seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Tutar alanı
  static Widget buildAmountField({
    required PaymentTransactionFormModel formState,
    required Function(double?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.amount?.toString(),
      decoration: const InputDecoration(
        labelText: 'Tutar',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {
        final amount = double.tryParse(value);
        onChanged(amount);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tutar girilmelidir';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Geçerli bir tutar girilmelidir';
        }
        return null;
      },
    );
  }

  /// Para birimi alanı
  static Widget buildCurrencyField({
    required PaymentTransactionFormModel formState,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: formState.currency,
      decoration: const InputDecoration(
        labelText: 'Para Birimi',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.currency_exchange),
      ),
      items: const [
        DropdownMenuItem(value: 'TRY', child: Text('TRY')),
        DropdownMenuItem(value: 'USD', child: Text('USD')),
        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
      ],
      onChanged: (value) => onChanged(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Para birimi seçilmelidir';
        }
        return null;
      },
    );
  }

  /// İşlem tarihi alanı
  static Widget buildTransactionDateField({
    required PaymentTransactionFormModel formState,
    required Function(DateTime?) onChanged,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: formState.transactionDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'İşlem Tarihi',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          formState.transactionDate != null
              ? _formatDate(formState.transactionDate!)
              : 'Tarih seçin',
        ),
      ),
    );
  }

  /// Vade tarihi alanı
  static Widget buildDueDateField({
    required PaymentTransactionFormModel formState,
    required Function(DateTime?) onChanged,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: formState.dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Vade Tarihi',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.schedule),
        ),
        child: Text(
          formState.dueDate != null
              ? _formatDate(formState.dueDate!)
              : 'Vade tarihi seçin',
        ),
      ),
    );
  }

  /// Müşteri alanı
  static Widget buildCustomerField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.customerId,
      decoration: const InputDecoration(
        labelText: 'Müşteri',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
        hintText: 'Müşteri ID girin',
      ),
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
      validator: (value) {
        if (formState.isCustomerSelectionRequired &&
            (value == null || value.isEmpty)) {
          return 'Müşteri seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Tedarikçi alanı
  static Widget buildSupplierField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.supplierId,
      decoration: const InputDecoration(
        labelText: 'Tedarikçi',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
        hintText: 'Tedarikçi ID girin',
      ),
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
      validator: (value) {
        if (formState.isSupplierSelectionRequired &&
            (value == null || value.isEmpty)) {
          return 'Tedarikçi seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Hesap alanı
  static Widget buildAccountField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.accountId,
      decoration: const InputDecoration(
        labelText: 'Hesap',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_balance),
        hintText: 'Hesap ID girin',
      ),
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Hesap seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Ödeme yöntemi alanı
  static Widget buildPaymentMethodField({
    required PaymentTransactionFormModel formState,
    required List<PaymentMethod> paymentMethods,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: formState.paymentMethodId,
      decoration: const InputDecoration(
        labelText: 'Ödeme Yöntemi',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: paymentMethods.map((method) {
        return DropdownMenuItem(
          value: method.id,
          child: Text(method.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ödeme yöntemi seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Ödeme kaynağı alanı
  static Widget buildPaymentSourceField({
    required PaymentTransactionFormModel formState,
    required List<PaymentSource> paymentSources,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: formState.paymentSourceId,
      decoration: const InputDecoration(
        labelText: 'Ödeme Kaynağı',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.source),
      ),
      items: paymentSources.map((source) {
        return DropdownMenuItem(
          value: source.id,
          child: Text(source.name),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (formState.isPaymentSourceRequired &&
            (value == null || value.isEmpty)) {
          return 'Ödeme kaynağı seçilmelidir';
        }
        return null;
      },
    );
  }

  /// Açıklama alanı
  static Widget buildDescriptionField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.description,
      decoration: const InputDecoration(
        labelText: 'Açıklama',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
        hintText: 'İşlem açıklaması',
      ),
      maxLines: 3,
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
    );
  }

  /// Referans numarası alanı
  static Widget buildReferenceNumberField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.referenceNumber,
      decoration: const InputDecoration(
        labelText: 'Referans Numarası',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
        hintText: 'Referans numarası',
      ),
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
    );
  }

  /// Notlar alanı
  static Widget buildNotesField({
    required PaymentTransactionFormModel formState,
    required Function(String?) onChanged,
  }) {
    return TextFormField(
      initialValue: formState.notes,
      decoration: const InputDecoration(
        labelText: 'Notlar',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
        hintText: 'Ek notlar',
      ),
      maxLines: 3,
      onChanged: (value) {
        onChanged(value.isEmpty ? null : value);
      },
    );
  }

  // Helper methods
  static String _getTypeText(PaymentTransactionType type) {
    switch (type) {
      case PaymentTransactionType.cash:
        return 'Nakit';
      case PaymentTransactionType.creditCard:
        return 'Kredi Kartı';
      case PaymentTransactionType.eftTransfer:
        return 'EFT/Havale';
      case PaymentTransactionType.check:
        return 'Çek';
      case PaymentTransactionType.promissoryNote:
        return 'Senet';
      case PaymentTransactionType.debtReceipt:
        return 'Borç Fişi';
      case PaymentTransactionType.creditReceipt:
        return 'Alacak Fişi';
      case PaymentTransactionType.accountTransfer:
        return 'Hesap Transferi';
    }
  }

  static String _getDirectionText(PaymentDirection direction) {
    switch (direction) {
      case PaymentDirection.incoming:
        return 'Gelen';
      case PaymentDirection.outgoing:
        return 'Giden';
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
