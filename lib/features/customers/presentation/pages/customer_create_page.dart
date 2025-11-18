// ========== CUSTOMER CREATE PAGE ==========
// lib/features/customers/presentation/pages/customer_create_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_branch.dart';
import '../providers/customer_providers.dart';
// Silinen modül: user_profile
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../customers/data/services/customer_transaction_service.dart';
import '../../../../core/services/business/transaction_service.dart';
import '../../../../core/utils/currency_helper.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerCreatePage extends ConsumerStatefulWidget {
  const CustomerCreatePage({super.key});

  @override
  ConsumerState<CustomerCreatePage> createState() => _CustomerCreatePageState();
}

class _CustomerCreatePageState extends ConsumerState<CustomerCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Form controllers
  final _nameController = TextEditingController();
  final _customerCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _maturityDaysController = TextEditingController();
  final _fixedDiscountRateController = TextEditingController();
  final _bankDetailsController = TextEditingController();
  final _authorizedPersonNameController = TextEditingController();
  final _authorizedPersonPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Form values
  CustomerType _customerType = CustomerType.individual;
  CustomerStatus _status = CustomerStatus.active;
  String _currency = 'TRY';
  String? _selectedCategory1Id;
  String? _selectedCategory2Id;
  final List<String> _categories1 = [];
  final List<String> _categories2 = [];
  bool _isCustomer = true;
  bool _isSupplier = false;
  bool _isTaxExempt = false;
  final List<CustomerBranch> _branches = [];

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateCustomerCode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customerCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _maturityDaysController.dispose();
    _fixedDiscountRateController.dispose();
    _bankDetailsController.dispose();
    _authorizedPersonNameController.dispose();
    _authorizedPersonPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateCustomerCode() {
    final now = DateTime.now();
    final code =
        'CUST${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(8)}';
    _customerCodeController.text = code;
  }

  void _addBranch() {
    setState(() {
      _branches.add(CustomerBranch(
        id: _uuid.v4(),
        name: 'Yeni Şube',
        address: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });
  }

  void _removeBranch(int index) {
    setState(() {
      _branches.removeAt(index);
    });
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuthService.currentUserId ?? 'system';
      // Silinen modül: user_profile - company name kaldırıldı
      const companyName = 'Şirket'; // Varsayılan değer

      // Mevcut kullanıcı için tenantId oluştur (eğer yoksa)
      await FirebaseAuthService.createTenantIdForCurrentUser();

      final parsedCreditLimit =
          CurrencyHelper.parseCurrency(_creditLimitController.text);
      final parsedOpeningBalance =
          CurrencyHelper.parseCurrency(_openingBalanceController.text);
      final parsedFixedDiscount =
          CurrencyHelper.parseCurrency(_fixedDiscountRateController.text);

      // Yeni müşteri oluştur
      final customer = Customer(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        customerCode: _customerCodeController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        taxNumber: _taxNumberController.text.trim().isNotEmpty
            ? _taxNumberController.text.trim()
            : null,
        taxOffice: _taxOfficeController.text.trim().isNotEmpty
            ? _taxOfficeController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        country: _countryController.text.trim().isNotEmpty
            ? _countryController.text.trim()
            : null,
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        category1: _selectedCategory1Id,
        category2: _selectedCategory2Id,
        customerType: _customerType,
        status: _status,
        creditLimit: parsedCreditLimit,
        currentBalance: 0.0,
        openingBalance: parsedOpeningBalance,
        customerCurrency: _currency,
        maturityDays: int.tryParse(_maturityDaysController.text),
        fixedDiscountRate: parsedFixedDiscount,
        isTaxExempt: _isTaxExempt,
        isActive: true,
        bankDetails: _bankDetailsController.text.trim().isNotEmpty
            ? _bankDetailsController.text.trim()
            : null,
        authorizedPersonName:
            _authorizedPersonNameController.text.trim().isNotEmpty
                ? _authorizedPersonNameController.text.trim()
                : null,
        authorizedPersonPhone:
            _authorizedPersonPhoneController.text.trim().isNotEmpty
                ? _authorizedPersonPhoneController.text.trim()
                : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        branches: _branches.isEmpty ? null : List.from(_branches),
        companyId: companyName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: uid,
      );

      // Firebase'e kaydetmeden önce tenantId'yi ekle
      final customerWithTenantId = customer.copyWith(
        companyId: companyName,
      );

      await ref
          .read(customerRepositoryProvider)
          .createCustomer(customerWithTenantId);
      AppLogger.info('Customer created successfully: ${customer.name}');

      // Açılış bakiyesi işlemi oluştur (ekstreye yansısın ve bakiye hesaplansın)
      if ((parsedOpeningBalance).abs() > 0) {
        try {
          final txService = CustomerTransactionService();
          final txType = parsedOpeningBalance >= 0
              ? TransactionType.credit
              : TransactionType.debit;
          await txService.addCustomerTransaction(
            customerId: customer.id,
            type: txType,
            amount: parsedOpeningBalance.abs(),
            currency: _currency,
            description: 'Açılış bakiyesi',
            reference: 'opening_balance',
            companyId: companyName,
            createdBy: uid,
          );
          AppLogger.info('Opening balance transaction created successfully');
        } catch (e) {
          AppLogger.warning('Could not create opening balance transaction: $e');
          // Müşteri oluşturuldu ama açılış bakiyesi işlemi oluşturulamadı
          // Bu durumda müşteri yine de başarılı sayılmalı
        }
      }

      // Provider'ı yenile
      ref.invalidate(customersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Satış Yap',
              textColor: Colors.white,
              onPressed: () {
                context.go('/sales/create');
              },
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error creating customer', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müşteri oluşturulurken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _taxNumberController.clear();
    _taxOfficeController.clear();
    _addressController.clear();
    _cityController.clear();
    _countryController.clear();
    _postalCodeController.clear();
    _creditLimitController.clear();
    _openingBalanceController.clear();
    _maturityDaysController.clear();
    _fixedDiscountRateController.clear();
    _bankDetailsController.clear();
    _authorizedPersonNameController.clear();
    _authorizedPersonPhoneController.clear();
    _notesController.clear();

    setState(() {
      _customerType = CustomerType.individual;
      _status = CustomerStatus.active;
      _currency = 'TRY';
      _isCustomer = true;
      _isSupplier = false;
      _isTaxExempt = false;
      _selectedCategory1Id = null;
      _selectedCategory2Id = null;
      _branches.clear();
    });

    _generateCustomerCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Müşteri'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
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
                            Icons.person_add,
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
                                'Yeni Müşteri',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Yeni müşteri bilgilerini girin',
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
              const SizedBox(height: 8),

              // Genel Bilgiler
              _buildPremiumSectionHeader(
                  'Genel Bilgiler', Icons.person_outline),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Müşteri Adı / Ünvan *',
                      hintText: 'Müşteri adını girin',
                      prefixIcon:
                          const Icon(Icons.person, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) =>
                        Validators.required(value, 'Müşteri adı'),
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customerCodeController,
                          decoration: InputDecoration(
                            labelText: 'Müşteri Kodu',
                            hintText: 'Otomatik oluşturulur',
                            prefixIcon: const Icon(Icons.qr_code,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _generateCustomerCode,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: 'Yeni kod oluştur',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefon Numarası',
                            hintText: '0555 123 45 67',
                            prefixIcon: const Icon(Icons.phone,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.isNotEmpty == true
                              ? Validators.phone(value)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-posta Adresi',
                            hintText: 'ornek@email.com',
                            prefixIcon: const Icon(Icons.email,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value?.isNotEmpty == true
                              ? Validators.email(value)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Vergi Bilgileri
              _buildPremiumSectionHeader('Vergi Bilgileri', Icons.receipt),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _taxNumberController,
                          decoration: InputDecoration(
                            labelText: 'Vergi Numarası / T.C. Kimlik No',
                            hintText: '1234567890',
                            prefixIcon: const Icon(Icons.badge,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) => value?.isNotEmpty == true
                              ? Validators.taxNumber(value)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _taxOfficeController,
                          decoration: InputDecoration(
                            labelText: 'Vergi Dairesi',
                            hintText: 'Kadıköy Vergi Dairesi',
                            prefixIcon: const Icon(Icons.account_balance,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Adres Bilgileri
              _buildPremiumSectionHeader('Adres Bilgileri', Icons.location_on),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Açık Adres',
                      hintText: 'Mahalle, sokak, bina no, daire no',
                      prefixIcon: const Icon(Icons.location_on,
                          color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'Şehir',
                            hintText: 'İstanbul',
                            prefixIcon: const Icon(Icons.location_city,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: InputDecoration(
                            labelText: 'Ülke',
                            hintText: 'Türkiye',
                            prefixIcon: const Icon(Icons.public,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Posta Kodu',
                            hintText: '34000',
                            prefixIcon: const Icon(Icons.markunread_mailbox,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Kategori / Sınıflandırma
              _buildPremiumSectionHeader(
                  'Kategori / Sınıflandırma', Icons.category),
              const SizedBox(height: 8),
              // Kategori 1
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
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory1Id,
                    decoration: InputDecoration(
                      labelText: 'Kategori 1',
                      hintText: 'Kategori seçin',
                      prefixIcon:
                          const Icon(Icons.category, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
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
                ),
              ),
              const SizedBox(height: 8),

              // Kategori 2
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
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory2Id,
                    decoration: InputDecoration(
                      labelText: 'Kategori 2',
                      hintText: 'Kategori seçin',
                      prefixIcon:
                          const Icon(Icons.category, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
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
                ),
              ),
              const SizedBox(height: 8),

              // Müşteri/Tedarikçi Seçimi
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.swap_horiz,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Müşteri / Tedarikçi Seçimi',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isCustomer
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isCustomer
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  'Müşteri',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: _isCustomer
                                        ? AppColors.primary
                                        : Colors.grey[700],
                                  ),
                                ),
                                value: _isCustomer,
                                onChanged: (value) {
                                  setState(() {
                                    _isCustomer = value ?? false;
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isSupplier
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isSupplier
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: CheckboxListTile(
                                title: Text(
                                  'Tedarikçi',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: _isSupplier
                                        ? AppColors.primary
                                        : Colors.grey[700],
                                  ),
                                ),
                                value: _isSupplier,
                                onChanged: (value) {
                                  setState(() {
                                    _isSupplier = value ?? false;
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Müşteri Tipi ve Durum
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CustomerType>(
                          initialValue: _customerType,
                          decoration: InputDecoration(
                            labelText: 'Müşteri Tipi',
                            prefixIcon: const Icon(Icons.person,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: CustomerType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _customerType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<CustomerStatus>(
                          initialValue: _status,
                          decoration: InputDecoration(
                            labelText: 'Durum',
                            prefixIcon: const Icon(Icons.flag,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: CustomerStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status.displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Finansal Bilgiler
              _buildPremiumSectionHeader(
                  'Finansal Bilgiler', Icons.account_balance_wallet),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: InputDecoration(
                            labelText: 'Para Birimi',
                            prefixIcon: const Icon(Icons.attach_money,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: const [
                            'TRY',
                            'USD',
                            'EUR',
                            'GBP',
                            'CHF',
                            'JPY',
                            'CAD',
                            'AUD',
                            'DKK',
                            'SEK',
                            'NOK',
                            'SAR',
                            'KWD',
                            'BGN',
                            'RON',
                            'RUB',
                            'IRR',
                            'CNY',
                            'PKR',
                            'QAR',
                            'XDR',
                            'XAU',
                            'AED'
                          ].map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _currency = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _creditLimitController,
                          decoration: InputDecoration(
                            labelText: 'Kredi Limiti',
                            hintText: '0,00',
                            prefixIcon: const Icon(Icons.monetization_on,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _openingBalanceController,
                          decoration: InputDecoration(
                            labelText: 'Açılış Bakiyesi',
                            hintText: '0,00 (eksi değer girilebilir)',
                            prefixIcon: const Icon(Icons.account_balance_wallet,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[-0-9.,]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maturityDaysController,
                          decoration: InputDecoration(
                            labelText: 'Ödeme Vadesi (Gün)',
                            hintText: '30',
                            prefixIcon: const Icon(Icons.schedule,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isNotEmpty == true
                              ? Validators.integer(value)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _fixedDiscountRateController,
                    decoration: InputDecoration(
                      labelText: 'Sabit İskonto Oranı (%)',
                      hintText: '0,00',
                      prefixIcon:
                          const Icon(Icons.percent, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Vergiden Muaf Checkbox
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt_long,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Vergiden Muaf',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          value: _isTaxExempt,
                          onChanged: (value) {
                            setState(() {
                              _isTaxExempt = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Ek Bilgiler
              _buildPremiumSectionHeader('Ek Bilgiler', Icons.note),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _bankDetailsController,
                    decoration: InputDecoration(
                      labelText: 'Banka Bilgileri',
                      hintText: 'Banka adı, IBAN, hesap numarası',
                      prefixIcon: const Icon(Icons.account_balance,
                          color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _authorizedPersonNameController,
                          decoration: InputDecoration(
                            labelText: 'Yetkili Kişi Adı',
                            hintText: 'Ad Soyad',
                            prefixIcon: const Icon(Icons.person_pin,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _authorizedPersonPhoneController,
                          decoration: InputDecoration(
                            labelText: 'Yetkili Kişi Telefonu',
                            hintText: '0555 123 45 67',
                            prefixIcon: const Icon(Icons.phone,
                                color: AppColors.primary),
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
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                  padding: const EdgeInsets.all(12),
                  child: TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notlar',
                      hintText: 'Müşteriyle ilgili önemli bilgiler',
                      prefixIcon:
                          const Icon(Icons.note_add, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildBranchesCard(),
              const SizedBox(height: 32),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: CustomButton(
                        text: 'Temizle',
                        onPressed: _clearForm,
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: CustomButton(
                        text: 'İptal',
                        onPressed: () => Navigator.of(context).pop(),
                        variant: ButtonVariant.outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: 'Müşteriyi Kaydet',
                        onPressed: _isLoading ? null : _saveCustomer,
                        isLoading: _isLoading,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSectionHeader(String title, IconData icon) {
    return Container(
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchesCard() {
    return Container(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Şubeler',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _addBranch,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      'Şube Ekle',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_branches.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz şube eklenmemiş',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yeni şube eklemek için yukarıdaki butona tıklayın',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            if (_branches.isNotEmpty) ...[
              for (int i = 0; i < _branches.length; i++) ...[
                _buildBranchItem(i),
                if (i < _branches.length - 1) const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBranchItem(int index) {
    final branch = _branches[index];
    final nameController = TextEditingController(text: branch.name);
    final addressController = TextEditingController(text: branch.address);
    final phoneController = TextEditingController(text: branch.phone ?? '');
    final emailController = TextEditingController(text: branch.email ?? '');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with branch number and delete button
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Şube ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    tooltip: 'Şubeyi kaldır',
                    onPressed: () => _removeBranch(index),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Şube Adı
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Şube Adı',
                hintText: 'Örn: Merkez',
                prefixIcon:
                    const Icon(Icons.business, color: AppColors.primary),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (val) {
                _branches[index] = _branches[index].copyWith(name: val);
              },
            ),
            const SizedBox(height: 12),

            // Adres
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Adres',
                hintText: 'Şube adresi',
                prefixIcon:
                    const Icon(Icons.location_on, color: AppColors.primary),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (val) {
                _branches[index] = _branches[index].copyWith(address: val);
              },
            ),
            const SizedBox(height: 12),

            // Telefon ve E-posta
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefon',
                      hintText: '0555 123 45 67',
                      prefixIcon:
                          const Icon(Icons.phone, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (val) {
                      _branches[index] = _branches[index].copyWith(phone: val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'E-posta',
                      hintText: 'mail@ornek.com',
                      prefixIcon:
                          const Icon(Icons.email, color: AppColors.primary),
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
                            color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (val) {
                      _branches[index] = _branches[index].copyWith(email: val);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCategory1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : null,
          title: Text(
            'Kategori 1 - Yeni Kategori Ekle',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              hintText: 'Örn: Teknoloji',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _categories1.add(controller.text);
                    _selectedCategory1Id = controller.text;
                  });
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _addCategory2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : null,
          title: Text(
            'Kategori 2 - Yeni Kategori Ekle',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              hintText: 'Örn: Teknoloji',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
              fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _categories2.add(controller.text);
                    _selectedCategory2Id = controller.text;
                  });
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }
}
