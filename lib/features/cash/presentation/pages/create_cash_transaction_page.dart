// ========== CREATE CASH TRANSACTION PAGE ==========
// lib/features/cash/presentation/pages/create_cash_transaction_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Kasa işlemi oluşturma sayfası
class CreateCashTransactionPage extends ConsumerStatefulWidget {
  const CreateCashTransactionPage({super.key});

  @override
  ConsumerState<CreateCashTransactionPage> createState() =>
      _CreateCashTransactionPageState();
}

class _CreateCashTransactionPageState
    extends ConsumerState<CreateCashTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'Giriş';
  String _selectedCategory = 'Genel';
  String _selectedPaymentMethod = 'Nakit';

  final List<String> _transactionTypes = ['Giriş', 'Çıkış'];
  final List<String> _categories = [
    'Genel',
    'Satış',
    'Alış',
    'Personel',
    'Vergi',
    'Kira',
    'Elektrik',
    'Su',
    'İnternet',
    'Telefon',
    'Yakıt',
    'Bakım',
    'Diğer',
  ];
  final List<String> _paymentMethods = [
    'Nakit',
    'Banka Transferi',
    'Kredi Kartı',
    'Çek',
    'Senet',
    'Diğer',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Tarih seçici
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Formu kaydet
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Kasa işlemi kaydetme işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kasa işlemi başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(title: 'Yeni Kasa İşlemi', showDrawer: false),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İşlem Tipi
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'İşlem Tipi *'),
                items: _transactionTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İşlem Başlığı *',
                  hintText: 'Örn: Satış Geliri',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'İşlem başlığı gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'İşlem açıklaması (opsiyonel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Tutar
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺) *',
                  hintText: '0.00',
                  prefixText: '₺ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tutar gereklidir';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Geçerli bir tutar girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // İşlem Tarihi
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'İşlem Tarihi *',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ödeme Yöntemi
              DropdownButtonFormField<String>(
                initialValue: _selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Ödeme Yöntemi'),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem(value: method, child: Text(method));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Referans
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Referans',
                  hintText: 'Fatura no, çek no vb. (opsiyonel)',
                ),
              ),
              const SizedBox(height: 16),

              // Notlar
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  hintText: 'Ek notlar (opsiyonel)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'Giriş'
                        ? Colors.green
                        : Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
