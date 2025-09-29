// ========== CASH PAYMENTS PAGE ==========
// lib/features/payments/presentation/pages/cash_payments_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_type.dart';
import '../../domain/entities/payment_status.dart';
import '../providers/payment_providers.dart';
import '../../../customers/presentation/providers/customer_providers.dart';
import '../../data/repositories/firebase_payment_repository.dart';

class CashPaymentsPage extends ConsumerStatefulWidget {
  const CashPaymentsPage({super.key});

  @override
  ConsumerState<CashPaymentsPage> createState() => _CashPaymentsPageState();
}

class _CashPaymentsPageState extends ConsumerState<CashPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  final _bankAccountController = TextEditingController();

  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  PaymentType _selectedType = PaymentType.cash;
  String _selectedCurrency = 'TRY';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nakit, Kredi Kartı, Banka'),
        backgroundColor: Colors.green[50],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/payments/history');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildCustomerSelection(),
                const SizedBox(height: 20),
                _buildPaymentTypeSelection(),
                const SizedBox(height: 20),
                _buildAmountAndCurrency(),
                const SizedBox(height: 20),
                _buildDateSelection(),
                const SizedBox(height: 20),
                _buildDescriptionAndReference(),
                const SizedBox(height: 20),
                if (_selectedType == PaymentType.bank) ...[
                  _buildBankAccountSelection(),
                  const SizedBox(height: 20),
                ],
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monetization_on,
              color: Colors.green[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nakit, Kredi Kartı, Banka İşlemleri',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Müşterilerden tahsilat işlemlerinizi yönetin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Müşteri Seçimi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final customersAsync = ref.watch(customersProvider);
              return customersAsync.when(
                data: (customers) {
                  return CustomDropdown<String>(
                    value: _selectedCustomerId.isEmpty
                        ? null
                        : _selectedCustomerId,
                    label: 'Müşteri Seçin *',
                    items: customers.map((customer) => customer.id).toList(),
                    itemBuilder: (customerId) {
                      final customer =
                          customers.firstWhere((c) => c.id == customerId);
                      return Text(customer.name);
                    },
                    onChanged: (customerId) {
                      if (customerId != null) {
                        final customer =
                            customers.firstWhere((c) => c.id == customerId);
                        setState(() {
                          _selectedCustomerId = customerId;
                          _selectedCustomerName = customer.name;
                        });
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text('Hata: $error'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tahsilat Türü',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomDropdown<PaymentType>(
            value: _selectedType,
            label: 'Tahsilat Türü *',
            items: const [
              PaymentType.cash,
              PaymentType.creditCard,
              PaymentType.bank,
            ],
            itemBuilder: (type) => Text(type.displayName),
            onChanged: (type) {
              setState(() {
                _selectedType = type!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountAndCurrency() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tutar ve Para Birimi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: _amountController,
                  label: 'Tutar *',
                  hint: '0,00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Tutar gerekli';
                    if (double.tryParse(value?.replaceAll(',', '.') ?? '') ==
                        null) {
                      return 'Geçerli bir tutar girin';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown<String>(
                  value: _selectedCurrency,
                  label: 'Para Birimi',
                  items: const ['TRY', 'USD', 'EUR', 'GBP'],
                  itemBuilder: (currency) => Text(currency),
                  onChanged: (currency) {
                    setState(() {
                      _selectedCurrency = currency!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tahsilat Tarihi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionAndReference() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Açıklama ve Referans',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,
            label: 'Açıklama',
            hint: 'Tahsilat açıklaması',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _referenceController,
            label: 'Referans No',
            hint: 'Fatura no, çek no vb.',
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Banka Hesabı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _bankAccountController,
            label: 'Banka Hesap Bilgisi',
            hint: 'Banka adı, IBAN vb.',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Tahsilat Kaydet',
            onPressed: _savePayment,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Temizle',
            onPressed: _clearForm,
            backgroundColor: Colors.grey[300]!,
            textColor: Colors.grey[700]!,
          ),
        ),
      ],
    );
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen müşteri seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payment = Payment(
        id: '', // Repository'de oluşturulacak
        tenantId: '', // Repository'de set edilecek
        customerId: _selectedCustomerId,
        customerName: _selectedCustomerName,
        type: _selectedType,
        status: PaymentStatus.completed,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        currency: _selectedCurrency,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        paymentDate: _selectedDate,
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        bankAccount: _selectedType == PaymentType.bank
            ? _bankAccountController.text.trim().isEmpty
                ? null
                : _bankAccountController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '', // Auth service'den alınacak
      );

      await ref.read(paymentRepositoryProvider).createPayment(payment);

      // Provider'ı yenile
      ref.invalidate(paymentsProvider);
      ref.invalidate(cashPaymentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_selectedCustomerName için tahsilat kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    setState(() {
      _selectedCustomerId = '';
      _selectedCustomerName = '';
      _selectedType = PaymentType.cash;
      _selectedCurrency = 'TRY';
      _selectedDate = DateTime.now();
    });
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();
    _bankAccountController.clear();
  }
}
