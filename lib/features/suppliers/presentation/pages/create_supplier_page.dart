// ========== CREATE/EDIT SUPPLIER PAGE ==========
// lib/features/suppliers/presentation/pages/create_supplier_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';

/// Tedarikçi oluşturma/düzenleme sayfası
class CreateSupplierPage extends ConsumerStatefulWidget {
  final String? supplierId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateSupplierPage({super.key, this.supplierId});

  @override
  ConsumerState<CreateSupplierPage> createState() => _CreateSupplierPageState();
}

class _CreateSupplierPageState extends ConsumerState<CreateSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedStatus = 'Aktif';

  final List<String> _statusOptions = ['Aktif', 'Pasif', 'Askıya Alınmış'];

  @override
  void initState() {
    super.initState();
    _loadSupplierData();
  }

  void _loadSupplierData() {
    if (widget.supplierId != null) {
      // Düzenleme modu - mock veri yükle
      _nameController.text = 'ABC Tedarik Ltd.';
      _contactPersonController.text = 'Ahmet Yılmaz';
      _emailController.text = 'ahmet@abctedarik.com';
      _phoneController.text = '+90 555 123 45 67';
      _addressController.text = 'Atatürk Caddesi No:123, İstanbul';
      _taxNumberController.text = '1234567890';
      _taxOfficeController.text = 'Kadıköy';
      _bankNameController.text = 'Ziraat Bankası';
      _bankAccountController.text = 'TR12 3456 7890 1234 5678 90';
      _notesController.text = 'Güvenilir tedarikçi';
      _selectedStatus = 'Aktif';
      _creditLimitController.text = '50000.0';
      _currentBalanceController.text = '0.0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _creditLimitController.dispose();
    _currentBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Formu kaydet
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final supplier = Supplier(
        id: widget.supplierId ?? '',
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        taxNumber: _taxNumberController.text.trim(),
        taxOffice: _taxOfficeController.text.trim(),
        bankName: _bankNameController.text.trim(),
        bankAccount: _bankAccountController.text.trim(),
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0.0,
        currentBalance: double.tryParse(_currentBalanceController.text) ?? 0.0,
        status: _getStatusFromString(_selectedStatus),
        createdAt: widget.supplierId == null ? DateTime.now() : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.supplierId != null) {
        await ref
            .read(supplierOperationsProvider.notifier)
            .updateSupplier(supplier);
        // Provider'ları yenile
        ref.invalidate(suppliersProvider);
        ref.invalidate(supplierProvider(widget.supplierId!));
        ref.invalidate(suppliersStreamProvider);
      } else {
        await ref
            .read(supplierOperationsProvider.notifier)
            .createSupplier(supplier);
        // Provider'ları yenile
        ref.invalidate(suppliersProvider);
        ref.invalidate(suppliersStreamProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.supplierId == null
                  ? 'Tedarikçi başarıyla oluşturuldu'
                  : 'Tedarikçi başarıyla güncellendi',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  /// String'den SupplierStatus'e dönüştürme
  SupplierStatus _getStatusFromString(String status) {
    switch (status) {
      case 'Aktif':
        return SupplierStatus.active;
      case 'Pasif':
        return SupplierStatus.inactive;
      case 'Askıya Alınmış':
        return SupplierStatus.suspended;
      default:
        return SupplierStatus.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplierId != null;

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: isEditing ? 'Tedarikçi Düzenle' : 'Yeni Tedarikçi',
        showDrawer: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temel Bilgiler Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temel Bilgiler',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tedarikçi Adı
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tedarikçi Adı *',
                          hintText: 'Örn: ABC Tedarik Ltd.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tedarikçi adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // İletişim Kişisi
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'İletişim Kişisi',
                          hintText: 'Örn: Ahmet Yılmaz',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Durum
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(labelText: 'Durum'),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // İletişim Bilgileri Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İletişim Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // E-posta
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          hintText: 'ornek@email.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Geçerli bir e-posta adresi girin';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Telefon
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                          hintText: '+90 555 123 45 67',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Adres
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adres',
                          hintText: 'Tam adres bilgisi',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vergi Bilgileri Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vergi Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vergi Numarası
                      TextFormField(
                        controller: _taxNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Vergi Numarası',
                          hintText: '1234567890',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vergi Dairesi
                      TextFormField(
                        controller: _taxOfficeController,
                        decoration: const InputDecoration(
                          labelText: 'Vergi Dairesi',
                          hintText: 'Kadıköy',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Banka Bilgileri Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banka Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Banka Adı
                      TextFormField(
                        controller: _bankNameController,
                        decoration: const InputDecoration(
                          labelText: 'Banka Adı',
                          hintText: 'Ziraat Bankası',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hesap Numarası
                      TextFormField(
                        controller: _bankAccountController,
                        decoration: const InputDecoration(
                          labelText: 'Hesap Numarası',
                          hintText: 'TR12 3456 7890 1234 5678 90',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kredi Limiti
                      TextFormField(
                        controller: _creditLimitController,
                        decoration: const InputDecoration(
                          labelText: 'Kredi Limiti (₺)',
                          hintText: '50000',
                          prefixText: '₺ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Mevcut Bakiye
                      TextFormField(
                        controller: _currentBalanceController,
                        decoration: const InputDecoration(
                          labelText: 'Mevcut Bakiye (₺)',
                          hintText: '0',
                          prefixText: '₺ ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notlar Kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notlar',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notlar',
                          hintText: 'Ek notlar (opsiyonel)',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TamgaciConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isEditing ? 'Güncelle' : 'Kaydet',
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
