// ========== PROMISSORY PAYMENTS PAGE ==========
// lib/features/payments/presentation/pages/promissory_payments_page.dart

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

class PromissoryPaymentsPage extends ConsumerStatefulWidget {
  const PromissoryPaymentsPage({super.key});

  @override
  ConsumerState<PromissoryPaymentsPage> createState() =>
      _PromissoryPaymentsPageState();
}

class _PromissoryPaymentsPageState
    extends ConsumerState<PromissoryPaymentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _promissoryNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  String _selectedCustomerId = '';
  String _selectedCustomerName = '';
  String _selectedCurrency = 'TRY';
  String _selectedType = 'receive'; // receive veya give
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void dispose() {
    _amountController.dispose();
    _promissoryNumberController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Senet Al/Ver'),
        backgroundColor: Colors.red[50],
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
              Colors.red[50]!,
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
                _buildSenetTypeSelection(),
                const SizedBox(height: 20),
                _buildAmountAndCurrency(),
                const SizedBox(height: 20),
                _buildSenetDetails(),
                const SizedBox(height: 20),
                _buildDateSelection(),
                const SizedBox(height: 20),
                _buildDescriptionAndReference(),
                const SizedBox(height: 20),
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
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description,
              color: Colors.red[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Senet Al/Ver',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Senet tahsilat ve ödeme işlemlerinizi yönetin',
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
                color: Colors.red[700],
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

  Widget _buildSenetTypeSelection() {
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
                Icons.swap_horiz,
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Senet Türü',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomDropdown<String>(
            value: _selectedType,
            label: 'Senet Türü *',
            items: const ['receive', 'give'],
            itemBuilder: (type) =>
                Text(type == 'receive' ? 'Senet Al' : 'Senet Ver'),
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
                color: Colors.red[700],
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
                  label: 'Senet Tutarı *',
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

  Widget _buildSenetDetails() {
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
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Senet Bilgileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _promissoryNumberController,
            label: 'Senet Numarası *',
            hint: 'Senet numarasını girin',
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Senet numarası gerekli';
              return null;
            },
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
                color: Colors.red[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tarih Bilgileri',
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
                child: InkWell(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Senet Tarihi',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.grey[600], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _dueDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vade Tarihi',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                color: Colors.grey[600], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _dueDate != null
                                  ? '${_dueDate!.day.toString().padLeft(2, '0')}.${_dueDate!.month.toString().padLeft(2, '0')}.${_dueDate!.year}'
                                  : 'Vade tarihi seçin',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: _dueDate != null
                                        ? Colors.grey[800]
                                        : Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                color: Colors.red[700],
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
            hint: 'Senet işlem açıklaması',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _referenceController,
            label: 'Referans No',
            hint: 'Fatura no, senet no vb.',
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
            text: _selectedType == 'receive'
                ? 'Senet Al Kaydet'
                : 'Senet Ver Kaydet',
            onPressed: _savePayment,
            backgroundColor: Colors.red,
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
        type: PaymentType.promissoryNote,
        status: PaymentStatus.pending, // Senetler genelde bekleyen durumda
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        currency: _selectedCurrency,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        paymentDate: _selectedDate,
        dueDate: _dueDate,
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        promissoryNoteNumber: _promissoryNumberController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: '', // Auth service'den alınacak
      );

      await ref.read(paymentRepositoryProvider).createPayment(payment);

      // Provider'ı yenile
      ref.invalidate(paymentsProvider);
      ref.invalidate(promissoryPaymentsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '$_selectedCustomerName için senet ${_selectedType == 'receive' ? 'alma' : 'verme'} kaydedildi'),
            backgroundColor: Colors.red,
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
      _selectedCurrency = 'TRY';
      _selectedType = 'receive';
      _selectedDate = DateTime.now();
      _dueDate = null;
    });
    _amountController.clear();
    _promissoryNumberController.clear();
    _descriptionController.clear();
    _referenceController.clear();
  }
}
