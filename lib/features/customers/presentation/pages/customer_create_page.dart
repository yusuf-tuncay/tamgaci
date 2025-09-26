// ========== CUSTOMER CREATE PAGE ==========
// lib/features/customers/presentation/pages/customer_create_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_branch.dart';
import '../providers/customer_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../customers/data/services/customer_transaction_service.dart';
import '../../../../core/services/business/transaction_service.dart';
import '../../../../core/utils/currency_helper.dart';
import 'package:tamgaci/core/routes/routes.dart';

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

  String _formatMoneyTyping(String raw, {required bool allowNegative}) {
    if (raw.isEmpty) return '';
    var value = raw.replaceAll('.', '').replaceAll(',', '.');
    final reg = RegExp(allowNegative ? r'[^0-9\.-]' : r'[^0-9\.]');
    value = value.replaceAll(reg, '');
    if (allowNegative) {
      final isNegative = value.startsWith('-');
      value = value.replaceAll('-', '');
      if (isNegative) value = '-$value';
    } else {
      value = value.replaceAll('-', '');
    }
    final parts = value.split('.');
    if (parts.length > 2) {
      value = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    if (parts.length == 2 && parts[1].length > 2) {
      value = '${parts[0]}.${parts[1].substring(0, 2)}';
    }
    value = value.replaceAll('.', ',');
    return value;
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
      final companyName = ref.read(userCompanyProvider);

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
                Navigator.of(context).pushNamed(
                  TamgaciRoutes.createSale,
                  arguments: {
                    'customerId': customer.id,
                    'customerName': customer.name,
                  },
                );
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Genel Bilgiler
              _buildSectionHeader('Genel Bilgiler'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                label: 'Müşteri Adı / Ünvan *',
                hint: 'Müşteri adını girin',
                validator: (value) => Validators.required(value, 'Müşteri adı'),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _customerCodeController,
                label: 'Müşteri Kodu',
                hint: 'Otomatik oluşturulur',
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _generateCustomerCode,
                  tooltip: 'Yeni kod oluştur',
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      label: 'Telefon Numarası',
                      hint: '0555 123 45 67',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isNotEmpty == true
                          ? Validators.phone(value)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      label: 'E-posta Adresi',
                      hint: 'ornek@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value?.isNotEmpty == true
                          ? Validators.email(value)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vergi Bilgileri
              _buildSectionHeader('Vergi Bilgileri'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _taxNumberController,
                      label: 'Vergi Numarası / T.C. Kimlik No',
                      hint: '1234567890',
                      validator: (value) => value?.isNotEmpty == true
                          ? Validators.taxNumber(value)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _taxOfficeController,
                      label: 'Vergi Dairesi',
                      hint: 'Kadıköy Vergi Dairesi',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Adres Bilgileri
              _buildSectionHeader('Adres Bilgileri'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                label: 'Açık Adres',
                hint: 'Mahalle, sokak, bina no, daire no',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'Şehir',
                      hint: 'İstanbul',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _countryController,
                      label: 'Ülke',
                      hint: 'Türkiye',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _postalCodeController,
                      label: 'Posta Kodu',
                      hint: '34000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kategori / Sınıflandırma
              _buildSectionHeader('Kategori / Sınıflandırma'),
              const SizedBox(height: 16),
              _buildCategoriesRow(),
              const SizedBox(height: 16),

              // Müşteri/Tedarikçi Seçimi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Müşteri / Tedarikçi Seçimi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Müşteri'),
                              value: _isCustomer,
                              onChanged: (value) {
                                setState(() {
                                  _isCustomer = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: CheckboxListTile(
                              title: const Text('Tedarikçi'),
                              value: _isSupplier,
                              onChanged: (value) {
                                setState(() {
                                  _isSupplier = value ?? false;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Müşteri Tipi ve Durum
              Row(
                children: [
                  Expanded(
                    child: CustomDropdown<CustomerType>(
                      value: _customerType,
                      label: 'Müşteri Tipi',
                      items: CustomerType.values,
                      itemBuilder: (type) => Text(type.displayName),
                      onChanged: (value) {
                        setState(() {
                          _customerType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomDropdown<CustomerStatus>(
                      value: _status,
                      label: 'Durum',
                      items: CustomerStatus.values,
                      itemBuilder: (status) => Text(status.displayName),
                      onChanged: (value) {
                        setState(() {
                          _status = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Finansal Bilgiler
              _buildSectionHeader('Finansal Bilgiler'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomDropdown<String>(
                      value: _currency,
                      label: 'Para Birimi',
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
                      ],
                      itemBuilder: (currency) => Text(currency),
                      onChanged: (value) {
                        setState(() {
                          _currency = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AutoFormattedTextField(
                      label: 'Kredi Limiti',
                      hint: '0,00',
                      controller: _creditLimitController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      formatter: (raw) {
                        return _formatMoneyTyping(raw, allowNegative: false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AutoFormattedTextField(
                      label: 'Açılış Bakiyesi',
                      hint: '0,00 (eksi değer girilebilir)',
                      controller: _openingBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
                      ],
                      formatter: (raw) {
                        return _formatMoneyTyping(raw, allowNegative: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _maturityDaysController,
                      label: 'Ödeme Vadesi (Gün)',
                      hint: '30',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isNotEmpty == true
                          ? Validators.integer(value)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AutoFormattedTextField(
                label: 'Sabit İskonto Oranı (%)',
                hint: '0,00',
                controller: _fixedDiscountRateController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                formatter: (raw) {
                  return _formatMoneyTyping(raw, allowNegative: false);
                },
              ),
              const SizedBox(height: 16),

              // Vergiden Muaf Checkbox
              CheckboxListTile(
                title: const Text('Vergiden Muaf'),
                value: _isTaxExempt,
                onChanged: (value) {
                  setState(() {
                    _isTaxExempt = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Ek Bilgiler
              _buildSectionHeader('Ek Bilgiler'),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _bankDetailsController,
                label: 'Banka Bilgileri',
                hint: 'Banka adı, IBAN, hesap numarası',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _authorizedPersonNameController,
                      label: 'Yetkili Kişi Adı',
                      hint: 'Ad Soyad',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _authorizedPersonPhoneController,
                      label: 'Yetkili Kişi Telefonu',
                      hint: '0555 123 45 67',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _notesController,
                label: 'Notlar',
                hint: 'Müşteriyle ilgili önemli bilgiler',
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              _buildBranchesCard(),
              const SizedBox(height: 32),

              // Butonlar
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Temizle',
                      onPressed: _clearForm,
                      variant: ButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'İptal',
                      onPressed: () => Navigator.of(context).pop(),
                      variant: ButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Kaydet',
                      onPressed: _isLoading ? null : _saveCustomer,
                      isLoading: _isLoading,
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final cats = ref.watch(customerCategoriesProvider(1));
              return cats.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, st) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Kategori 1 yüklenemedi: $e',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Kategori bulunamadı',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _showCreateCategoryDialog(level: 1);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomDropdown<String>(
                          value: _selectedCategory1Id,
                          label: 'Kategori 1',
                          items: list.map((c) => c.id).toList(),
                          itemBuilder: (id) => Text(
                            list.firstWhere((c) => c.id == id).name,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory1Id = val;
                            });
                          },
                          hint: 'Seçiniz',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          tooltip: 'Yeni kategori',
                          onPressed: () async {
                            await _showCreateCategoryDialog(level: 1);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final cats = ref.watch(customerCategoriesProvider(2));
              return cats.when(
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, st) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Kategori 2 yüklenemedi: $e',
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Kategori bulunamadı',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _showCreateCategoryDialog(level: 2);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomDropdown<String>(
                          value: _selectedCategory2Id,
                          label: 'Kategori 2',
                          items: list.map((c) => c.id).toList(),
                          itemBuilder: (id) => Text(
                            list.firstWhere((c) => c.id == id).name,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory2Id = val;
                            });
                          },
                          hint: 'Seçiniz',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          tooltip: 'Yeni kategori',
                          onPressed: () async {
                            await _showCreateCategoryDialog(level: 2);
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateCategoryDialog({required int level}) async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
              'Yeni Kategori (${level == 1 ? 'Kategori 1' : 'Kategori 2'})'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Kategori Adı',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                try {
                  await ref.read(createCustomerCategoryProvider((
                    name: name,
                    level: level,
                    parentId: null,
                    companyId: ref.read(userCompanyProvider),
                    userId: FirebaseAuthService.currentUserId ?? 'system',
                  )).future);

                  // Provider'ı yenile
                  ref.invalidate(customerCategoriesProvider(level));

                  if (mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name kategorisi başarıyla oluşturuldu'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori oluşturulamadı: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBranchesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Şubeler',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                OutlinedButton.icon(
                  onPressed: _addBranch,
                  icon: const Icon(Icons.add),
                  label: const Text('Şube Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_branches.isEmpty) const Text('Şube eklenmemiş'),
            for (int i = 0; i < _branches.length; i++) ...[
              _buildBranchItem(i),
              const SizedBox(height: 8),
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
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: nameController,
                  label: 'Şube Adı',
                  hint: 'Örn: Merkez',
                  onChanged: (val) {
                    _branches[index] = _branches[index].copyWith(name: val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Şubeyi kaldır',
                onPressed: () => _removeBranch(index),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: addressController,
                  label: 'Adres',
                  hint: 'Adres',
                  onChanged: (val) {
                    _branches[index] = _branches[index].copyWith(address: val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: phoneController,
                  label: 'Telefon',
                  hint: '0555 123 45 67',
                  onChanged: (val) {
                    _branches[index] = _branches[index].copyWith(phone: val);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: emailController,
                  label: 'E-posta',
                  hint: 'mail@ornek.com',
                  onChanged: (val) {
                    _branches[index] = _branches[index].copyWith(email: val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
