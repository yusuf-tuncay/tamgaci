// ========== CREATE/EDIT SUPPLIER PAGE ==========
// lib/features/suppliers/presentation/pages/create_supplier_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/supplier_providers.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_enums.dart';

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
  final _supplierCodeController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _paymentTermController = TextEditingController();
  final _category1Controller = TextEditingController();
  final _category2Controller = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedStatus = 'Aktif';
  String _selectedCurrency = 'TRY';
  String? _selectedCategory1Id;
  String? _selectedCategory2Id;

  final List<String> _statusOptions = ['Aktif', 'Pasif', 'Askıya Alınmış'];
  final List<String> _currencyOptions = ['TRY', 'USD', 'EUR', 'GBP'];
  final List<String> _categories1 = [
    'Elektronik',
    'Bilgisayar',
    'Ofis',
    'Mobilya',
    'Gıda'
  ];
  final List<String> _categories2 = [
    'Elektronik',
    'Bilgisayar',
    'Ofis',
    'Mobilya',
    'Gıda'
  ];

  @override
  void initState() {
    super.initState();
    _generateSupplierCode();
    _loadSupplierData();
  }

  void _generateSupplierCode() {
    final now = DateTime.now();
    final code =
        'SUPP${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
    _supplierCodeController.text = code;
  }

  void _addCategory1() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Kategori 1 - Yeni Kategori Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kategori Adı',
              hintText: 'Örn: Teknoloji',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _categories1.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _addCategory2() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Kategori 2 - Yeni Kategori Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kategori Adı',
              hintText: 'Örn: Teknoloji',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _categories2.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
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
      _selectedCurrency = 'TRY';
      _creditLimitController.text = '50000.0';
      _openingBalanceController.text = '0.0';
      _paymentTermController.text = '30';
      _category1Controller.text = 'Elektronik';
      _category2Controller.text = 'Bilgisayar';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _supplierCodeController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _paymentTermController.dispose();
    _category1Controller.dispose();
    _category2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Formu kaydet
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final supplier = Supplier(
        id: widget.supplierId ?? '',
        tenantId: '', // Repository'de set edilecek
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
        currency: _selectedCurrency,
        status: _getStatusFromString(_selectedStatus),
        supplierType: SupplierType.individual, // Varsayılan tedarikçi tipi
        companyId: '', // Varsayılan şirket ID
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
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
        showBackButton: true,
        automaticallyImplyLeading: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      TamgaciConstants.primaryColor,
                      TamgaciConstants.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          TamgaciConstants.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? 'Tedarikçi Düzenle'
                                    : 'Yeni Tedarikçi',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEditing
                                    ? 'Tedarikçi bilgilerini güncelleyin'
                                    : 'Yeni tedarikçi bilgilerini girin',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Temel Bilgiler Kartı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: TamgaciConstants.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Temel Bilgiler',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tedarikçi Adı
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tedarikçi Adı *',
                          hintText: 'Örn: ABC Tedarik Ltd.',
                          prefixIcon: const Icon(Icons.business,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tedarikçi adı gereklidir';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tedarikçi Kodu
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _supplierCodeController,
                              decoration: InputDecoration(
                                labelText: 'Tedarikçi Kodu',
                                hintText: 'Otomatik oluşturulur',
                                prefixIcon: const Icon(Icons.qr_code,
                                    color: TamgaciConstants.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: TamgaciConstants.primaryColor,
                                      width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: TamgaciConstants.primaryColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _generateSupplierCode,
                              icon: const Icon(Icons.refresh,
                                  color: Colors.white),
                              tooltip: 'Yeni kod oluştur',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // İletişim Kişisi
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: InputDecoration(
                          labelText: 'İletişim Kişisi',
                          hintText: 'Örn: Ahmet Yılmaz',
                          prefixIcon: const Icon(Icons.person,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Durum
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Durum',
                          prefixIcon: const Icon(Icons.flag,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
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
                      const SizedBox(height: 16),

                      // Para Birimi
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCurrency,
                        decoration: InputDecoration(
                          labelText: 'Para Birimi',
                          prefixIcon: const Icon(Icons.attach_money,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _currencyOptions.map((currency) {
                          return DropdownMenuItem(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Açılış Bakiyesi
                      TextFormField(
                        controller: _openingBalanceController,
                        decoration: InputDecoration(
                          labelText: 'Açılış Bakiyesi',
                          hintText: '0.00 (eksi değer girebilirsiniz)',
                          prefixIcon: const Icon(Icons.account_balance_wallet,
                              color: TamgaciConstants.primaryColor),
                          suffixText: _selectedCurrency == 'TRY'
                              ? '₺'
                              : _selectedCurrency,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true, signed: true),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final double? balance = double.tryParse(value);
                            if (balance == null) {
                              return 'Geçerli bir sayı girin';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vade (Gün)
                      TextFormField(
                        controller: _paymentTermController,
                        decoration: InputDecoration(
                          labelText: 'Vade (Gün)',
                          hintText: '30',
                          prefixIcon: const Icon(Icons.schedule,
                              color: TamgaciConstants.primaryColor),
                          suffixText: 'gün',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final int? days = int.tryParse(value);
                            if (days == null || days <= 0) {
                              return 'Geçerli bir gün sayısı girin';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kategori 1
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory1Id,
                        decoration: InputDecoration(
                          labelText: 'Kategori 1',
                          hintText: 'Kategori seçin',
                          prefixIcon: const Icon(Icons.category,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          ..._categories1.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                          const DropdownMenuItem(
                            value: 'ADD_NEW_CATEGORY_1',
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 8),
                                Text('Yeni Kategori Ekle'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'ADD_NEW_CATEGORY_1') {
                            _addCategory1();
                          } else {
                            setState(() {
                              _selectedCategory1Id = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kategori 2
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory2Id,
                        decoration: InputDecoration(
                          labelText: 'Kategori 2',
                          hintText: 'Kategori seçin',
                          prefixIcon: const Icon(Icons.category,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: [
                          ..._categories2.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                          const DropdownMenuItem(
                            value: 'ADD_NEW_CATEGORY_2',
                            child: Row(
                              children: [
                                Icon(Icons.add, size: 16),
                                SizedBox(width: 8),
                                Text('Yeni Kategori Ekle'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == 'ADD_NEW_CATEGORY_2') {
                            _addCategory2();
                          } else {
                            setState(() {
                              _selectedCategory2Id = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // İletişim Bilgileri Kartı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.contact_phone,
                                color: TamgaciConstants.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'İletişim Bilgileri',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // E-posta
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          hintText: 'ornek@email.com',
                          prefixIcon: const Icon(Icons.email,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
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
                        decoration: InputDecoration(
                          labelText: 'Telefon',
                          hintText: '+90 555 123 45 67',
                          prefixIcon: const Icon(Icons.phone,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Adres
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adres',
                          hintText: 'Tam adres bilgisi',
                          prefixIcon: const Icon(Icons.location_on,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Vergi Bilgileri Kartı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.receipt,
                                color: TamgaciConstants.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Vergi Bilgileri',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Vergi Numarası
                      TextFormField(
                        controller: _taxNumberController,
                        decoration: InputDecoration(
                          labelText: 'Vergi Numarası',
                          hintText: '1234567890',
                          prefixIcon: const Icon(Icons.badge,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vergi Dairesi
                      TextFormField(
                        controller: _taxOfficeController,
                        decoration: InputDecoration(
                          labelText: 'Vergi Dairesi',
                          hintText: 'Kadıköy',
                          prefixIcon: const Icon(Icons.account_balance,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Banka Bilgileri Kartı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance,
                                color: TamgaciConstants.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Banka Bilgileri',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Banka Adı
                      TextFormField(
                        controller: _bankNameController,
                        decoration: InputDecoration(
                          labelText: 'Banka Adı',
                          hintText: 'Ziraat Bankası',
                          prefixIcon: const Icon(Icons.business,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Hesap Numarası
                      TextFormField(
                        controller: _bankAccountController,
                        decoration: InputDecoration(
                          labelText: 'Hesap Numarası',
                          hintText: 'TR12 3456 7890 1234 5678 90',
                          prefixIcon: const Icon(Icons.credit_card,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kredi Limiti
                      TextFormField(
                        controller: _creditLimitController,
                        decoration: InputDecoration(
                          labelText: 'Kredi Limiti',
                          hintText: '50000',
                          prefixIcon: const Icon(Icons.monetization_on,
                              color: TamgaciConstants.primaryColor),
                          prefixText: _selectedCurrency == 'TRY'
                              ? '₺ '
                              : '$_selectedCurrency ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notlar Kartı
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: TamgaciConstants.primaryColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.note,
                                color: TamgaciConstants.primaryColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Notlar',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notlar',
                          hintText: 'Ek notlar (opsiyonel)',
                          prefixIcon: const Icon(Icons.edit_note,
                              color: TamgaciConstants.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: TamgaciConstants.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Kaydet Butonu
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          TamgaciConstants.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TamgaciConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.update : Icons.save,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing
                            ? 'Tedarikçiyi Güncelle'
                            : 'Tedarikçiyi Kaydet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
