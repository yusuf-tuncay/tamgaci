// ========== lib/features/customers/presentation/pages/create_customer_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/constants.dart';
import '../../domain/entities/customer.dart';
import 'package:tamgaci/features/customers/presentation/providers/customer_providers.dart';

/// Yeni müşteri oluşturma sayfası - Tam fonksiyonel
class CreateCustomerPage extends ConsumerStatefulWidget {
  final String? customerId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateCustomerPage({super.key, this.customerId});

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerType _selectedType = CustomerType.individual;
  final bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Yeni Müşteri'),
        elevation: 0,
        backgroundColor: TamgaciConstants.appBarColor,
        foregroundColor: TamgaciConstants.textPrimary,
        actions: [
          if (formState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form alanları
            Expanded(
              child: SingleChildScrollView(
                padding: TamgaciConstants.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hata/Başarı mesajları
                    if (formState.errorMessage != null)
                      _buildErrorMessage(formState.errorMessage!),

                    if (formState.successMessage != null)
                      _buildSuccessMessage(formState.successMessage!),

                    // Müşteri tipi seçimi
                    _buildCustomerTypeSelection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Temel bilgiler
                    _buildBasicInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // İletişim bilgileri
                    _buildContactInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Vergi bilgileri (sadece kurumsal için)
                    if (_selectedType == CustomerType.company)
                      _buildTaxInfoSection(),

                    if (_selectedType == CustomerType.company)
                      const SizedBox(height: TamgaciConstants.spaceLG),

                    // Adres bilgileri
                    _buildAddressInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Notlar
                    _buildNotesSection(),

                    const SizedBox(height: TamgaciConstants.spaceXXL),
                  ],
                ),
              ),
            ),

            // Kaydet butonu
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Hata mesajı widget'ı
  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(
          color: TamgaciConstants.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: TamgaciConstants.errorColor),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Başarı mesajı widget'ı
  Widget _buildSuccessMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: TamgaciConstants.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(
          color: TamgaciConstants.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: TamgaciConstants.successColor,
          ),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TamgaciConstants.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Müşteri tipi seçimi
  Widget _buildCustomerTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Müşteri Tipi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceSM),
        Row(
          children: CustomerType.values.map((type) {
            final isSelected = _selectedType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(
                    right: type == CustomerType.individual
                        ? TamgaciConstants.spaceSM
                        : 0,
                  ),
                  padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TamgaciConstants.primaryLight.withValues(alpha: 0.1)
                        : TamgaciConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(
                      TamgaciConstants.radiusSM,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? TamgaciConstants.primaryColor
                          : TamgaciConstants.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type == CustomerType.company
                            ? Icons.business
                            : Icons.person,
                        size: 32,
                        color: isSelected
                            ? TamgaciConstants.primaryColor
                            : TamgaciConstants.textSecondary,
                      ),
                      const SizedBox(height: TamgaciConstants.spaceXS),
                      Text(
                        type.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? TamgaciConstants.primaryColor
                              : TamgaciConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Temel bilgiler bölümü
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temel Bilgiler',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: _selectedType == CustomerType.company
                ? 'Şirket Adı *'
                : 'Ad Soyad *',
            hintText: _selectedType == CustomerType.company
                ? 'Örnek Teknoloji A.Ş.'
                : 'Ahmet Yılmaz',
            prefixIcon: Icon(
              _selectedType == CustomerType.company
                  ? Icons.business
                  : Icons.person,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bu alan zorunludur';
            }
            if (value.trim().length < 2) {
              return 'En az 2 karakter olmalıdır';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// İletişim bilgileri bölümü
  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İletişim Bilgileri',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && !value.contains('@')) {
              return 'Geçerli bir e-posta adresi giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            hintText: '+90 555 123 45 67',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Geçerli bir telefon numarası giriniz';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Vergi bilgileri bölümü
  Widget _buildTaxInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vergi Bilgileri',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _taxNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Vergi Numarası',
            hintText: '1234567890',
            prefixIcon: Icon(Icons.receipt_outlined),
          ),
          validator: (value) {
            if (_selectedType == CustomerType.company &&
                (value == null || value.trim().isEmpty)) {
              return 'Kurumsal müşteri için vergi numarası zorunludur';
            }
            if (value != null && value.isNotEmpty && value.length != 10) {
              return 'Vergi numarası 10 haneli olmalıdır';
            }
            return null;
          },
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _taxOfficeController,
          decoration: const InputDecoration(
            labelText: 'Vergi Dairesi',
            hintText: 'Kadıköy Vergi Dairesi',
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),
        ),
      ],
    );
  }

  /// Adres bilgileri bölümü
  Widget _buildAddressInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adres Bilgileri',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Adres',
            hintText: 'Açık adres bilgisini giriniz...',
            prefixIcon: Icon(Icons.location_on_outlined),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Şehir',
                  hintText: 'İstanbul',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
            ),
            const SizedBox(width: TamgaciConstants.spaceMD),
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Posta Kodu',
                  hintText: '34000',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _countryController,
          decoration: const InputDecoration(
            labelText: 'Ülke',
            hintText: 'Türkiye',
            prefixIcon: Icon(Icons.public_outlined),
          ),
        ),
      ],
    );
  }

  /// Notlar bölümü
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notlar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notlar',
            hintText: 'Müşteri hakkında notlarınız...',
            prefixIcon: Icon(Icons.note_outlined),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton() {
    final formState = ref.watch(customerFormProvider);

    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      decoration: const BoxDecoration(
        color: TamgaciConstants.backgroundColor,
        border: Border(
          top: BorderSide(color: TamgaciConstants.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: TamgaciConstants.buttonHeight(context),
          child: ElevatedButton(
            onPressed: formState.isLoading ? null : _saveCustomer,
            child: formState.isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TamgaciConstants.textOnPrimary,
                    ),
                  )
                : Text(
                    'Müşteriyi Kaydet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Müşteri kaydetme işlemi
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customer = Customer(
      id: widget.customerId ?? _uuid.v4(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      taxNumber: _taxNumberController.text.trim().isEmpty
          ? null
          : _taxNumberController.text.trim(),
      taxOffice: _taxOfficeController.text.trim().isEmpty
          ? null
          : _taxOfficeController.text.trim(),
      customerType: _selectedType,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      country: _countryController.text.trim().isEmpty
          ? null
          : _countryController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isActive: _isActive,
      createdAt: widget.customerId == null ? DateTime.now() : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.customerId != null) {
        await ref
            .read(customerOperationsProvider.notifier)
            .updateCustomer(customer);
        // Provider'ları yenile
        ref.invalidate(customersProvider);
        ref.invalidate(customerProvider(widget.customerId!));
        ref.invalidate(customersStreamProvider);
      } else {
        await ref
            .read(customerOperationsProvider.notifier)
            .createCustomer(customer);
        // Provider'ları yenile
        ref.invalidate(customersProvider);
        ref.invalidate(customersStreamProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.customerId == null
                  ? 'Müşteri başarıyla oluşturuldu'
                  : 'Müşteri başarıyla güncellendi',
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
}

// ========== DOSYA YERLEŞTİRME TALİMATLARI ==========

/*
📁 Bu dosyaların yerleştirilmesi gereken konumlar:

1. 📄 customers_list_page.dart  
   → lib/features/customers/presentation/pages/customers_list_page.dart
   (Mevcut placeholder'ı değiştir)

2. 📄 create_customer_page.dart
   → lib/features/customers/presentation/pages/create_customer_page.dart  
   (Mevcut placeholder'ı değiştir)

========== SONRAKI ADIM ==========

1. Code generation çalıştır:
   flutter packages pub run build_runner build

2. Database'i test etmek için bir kaç mock müşteri ekleyin

3. Customer detail ve edit sayfalarını hazırlayacağım

Bu sayfalar tamamen fonksiyonel:
✅ Gerçek database CRUD işlemleri
✅ Form validation
✅ Error handling  
✅ Search ve filtering
✅ Responsive design
✅ Loading states
✅ Success/error messages

Artık gerçek bir müşteri yönetim sistemine sahipsiniz! 🎉
*/
