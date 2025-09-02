// ========== lib/features/customers/presentation/pages/edit_customer_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/core/theme/constants.dart';
import 'package:tamgaci/features/customers/data/models/customer_entity.dart';
import 'package:tamgaci/features/customers/domain/entities/customer.dart';
import 'package:tamgaci/features/customers/presentation/providers/customer_providers.dart';

/// Müşteri düzenleme sayfası - CreateCustomerPage'e çok benzer ama mevcut verileri yükler
class EditCustomerPage extends ConsumerStatefulWidget {
  final String customerId;

  const EditCustomerPage({super.key, required this.customerId});

  @override
  ConsumerState<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends ConsumerState<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();

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
  bool _isActive = true;
  bool _isInitialized = false;

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
    final customerAsync = ref.watch(customerProvider(widget.customerId));
    final formState = ref.watch(customerFormProvider);

    return customerAsync.when(
      data: (customer) {
        if (customer != null && !_isInitialized) {
          _initializeForm(customer);
        }
        return _buildEditForm(formState);
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  /// Formu müşteri verileriyle doldur
  void _initializeForm(Customer customer) {
    _nameController.text = customer.name;
    _emailController.text = customer.email ?? '';
    _phoneController.text = customer.phone ?? '';
    _addressController.text = customer.address ?? '';
    _taxNumberController.text = customer.taxNumber ?? '';
    _taxOfficeController.text = customer.taxOffice ?? '';
    _cityController.text = customer.city ?? '';
    _countryController.text = customer.country ?? '';
    _postalCodeController.text = customer.postalCode ?? '';
    _notesController.text = customer.notes ?? '';

    _selectedType = customer.customerType;
    _isActive = customer.isActive;
    _isInitialized = true;

    // Form state'ini güncelle - build sırasında değil, sonrasında
    Future.microtask(() {
      ref
          .read(customerFormProvider.notifier)
          .initializeForEdit(widget.customerId);
    });
  }

  /// Düzenleme formu
  Widget _buildEditForm(CustomerFormState formState) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Müşteriyi Düzenle'),
        elevation: 0,
        backgroundColor: TamgaciConstants.appBarColor,
        foregroundColor: TamgaciConstants.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Form alanları (CreateCustomerPage ile aynı)
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

                    // Temel bilgiler bölümü
                    _buildBasicInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // İletişim bilgileri bölümü
                    _buildContactInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Adres bilgileri bölümü
                    _buildAddressInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceLG),

                    // Kurumsal bilgiler bölümü (sadece şirket tipinde)
                    if (_selectedType == CustomerType.company)
                      _buildCompanyInfoSection(),

                    if (_selectedType == CustomerType.company)
                      const SizedBox(height: TamgaciConstants.spaceLG),

                    // Ek bilgiler bölümü
                    _buildAdditionalInfoSection(),

                    const SizedBox(height: TamgaciConstants.spaceXXL),
                  ],
                ),
              ),
            ),

            // Güncelle butonu
            _buildUpdateButton(formState),
          ],
        ),
      ),
    );
  }

  /// Loading durumu
  Widget _buildLoading() {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteriyi Düzenle')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Hata durumu
  Widget _buildError(Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hata')),
      body: Center(child: Text('Hata: $error')),
    );
  }

  /// Hata mesajı (CreateCustomerPage ile aynı)
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
          const Icon(Icons.error_outline, color: TamgaciConstants.errorColor),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  /// Başarı mesajı (CreateCustomerPage ile aynı)
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
          const Icon(
            Icons.check_circle_outline,
            color: TamgaciConstants.successColor,
          ),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  /// Müşteri tipi seçimi (CreateCustomerPage ile aynı)
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
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
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
            hintText: 'Açık adres bilgisi',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        Row(
          children: [
            Expanded(
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
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Ülke',
                  hintText: 'Türkiye',
                  prefixIcon: Icon(Icons.public_outlined),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _postalCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Posta Kodu',
            hintText: '34000',
            prefixIcon: Icon(Icons.markunread_outlined),
          ),
        ),
      ],
    );
  }

  /// Kurumsal bilgiler bölümü
  Widget _buildCompanyInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kurumsal Bilgiler',
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
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Geçerli bir vergi numarası giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _taxOfficeController,
          decoration: const InputDecoration(
            labelText: 'Vergi Dairesi',
            hintText: 'Kadıköy',
            prefixIcon: Icon(Icons.account_balance_outlined),
          ),
        ),
      ],
    );
  }

  /// Ek bilgiler bölümü
  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ek Bilgiler',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: TamgaciConstants.textPrimary,
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notlar',
            hintText: 'Müşteri hakkında ek bilgiler...',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
        const SizedBox(height: TamgaciConstants.spaceMD),
        SwitchListTile(
          title: const Text('Aktif Müşteri'),
          subtitle: const Text('Müşteri aktif durumda mı?'),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
          activeThumbColor: TamgaciConstants.primaryColor,
        ),
      ],
    );
  }

  /// Güncelle butonu
  Widget _buildUpdateButton(CustomerFormState formState) {
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
            onPressed: formState.isLoading ? null : _updateCustomer,
            child: formState.isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TamgaciConstants.textOnPrimary,
                    ),
                  )
                : const Text('Değişiklikleri Kaydet'),
          ),
        ),
      ),
    );
  }

  /// Müşteri güncelleme işlemi
  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Mevcut müşteri verisini al
      final currentCustomer = await ref.read(
        customerProvider(widget.customerId).future,
      );
      if (currentCustomer == null) return;

      final updatedCustomer = currentCustomer.copyWith(
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
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(customerFormProvider.notifier)
          .saveCustomer(updatedCustomer);

      if (success != null && mounted) {
        // Provider'ları yenile
        ref.invalidate(customersProvider);
        ref.invalidate(customerProvider(widget.customerId));
        ref.invalidate(customerCountProvider);
        ref.invalidate(customerTypeStatsProvider);
        ref.invalidate(recentCustomersProvider);
        ref.invalidate(filteredCustomersProvider);
        ref.invalidate(searchResultsProvider);

        // Form state'ini temizle
        ref.read(customerFormProvider.notifier).clearForm();

        // Başarılı güncelleme sonrası detay sayfasına dön
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Müşteri başarıyla güncellendi'),
            backgroundColor: TamgaciConstants.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme başarısız: $e'),
            backgroundColor: TamgaciConstants.errorColor,
          ),
        );
      }
    }
  }
}
