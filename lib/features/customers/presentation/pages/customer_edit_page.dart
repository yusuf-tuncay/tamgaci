// ========== CUSTOMER EDIT PAGE ==========
// lib/features/customers/presentation/pages/customer_edit_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_dropdown.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_branch.dart';
import '../providers/customer_providers.dart';
// Silinen modül: user_profile
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import 'package:flutter/services.dart';

class CustomerEditPage extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerEditPage({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends ConsumerState<CustomerEditPage>
    with TickerProviderStateMixin {
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
  bool _isTaxExempt = false;
  final List<CustomerBranch> _branches = [];

  // Loading state
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDeleting = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCustomerData();
  }

  String _formatMoneyTyping(String raw, {required bool allowNegative}) {
    if (raw.isEmpty) return '';
    var value = raw.replaceAll('.', '').replaceAll(',', '.');
    // Keep only allowed characters
    final reg = RegExp(allowNegative ? r'[^0-9\.-]' : r'[^0-9\.]');
    value = value.replaceAll(reg, '');
    // Ensure only one minus at start
    if (allowNegative) {
      final isNegative = value.startsWith('-');
      value = value.replaceAll('-', '');
      if (isNegative) value = '-$value';
    } else {
      value = value.replaceAll('-', '');
    }
    // Limit to two decimals
    final parts = value.split('.');
    if (parts.length > 2) {
      value = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    if (parts.length == 2 && parts[1].length > 2) {
      value = '${parts[0]}.${parts[1].substring(0, 2)}';
    }
    // Convert back to locale style (comma decimal)
    value = value.replaceAll('.', ',');
    return value;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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

  Future<void> _loadCustomerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await ref.read(customersProvider.future);
      final customer = customers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => throw Exception('Müşteri bulunamadı'),
      );

      // Form alanlarını doldur
      _nameController.text = customer.name;
      _customerCodeController.text = customer.customerCode ?? '';
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _taxNumberController.text = customer.taxNumber ?? '';
      _taxOfficeController.text = customer.taxOffice ?? '';
      _addressController.text = customer.address ?? '';
      _cityController.text = customer.city ?? '';
      _countryController.text = customer.country ?? '';
      _postalCodeController.text = customer.postalCode ?? '';
      _creditLimitController.text = customer.creditLimit.toString();
      _openingBalanceController.text =
          customer.openingBalance?.toString() ?? '';
      _maturityDaysController.text = customer.maturityDays?.toString() ?? '';
      _fixedDiscountRateController.text =
          customer.fixedDiscountRate?.toString() ?? '';
      _bankDetailsController.text = customer.bankDetails ?? '';
      _authorizedPersonNameController.text =
          customer.authorizedPersonName ?? '';
      _authorizedPersonPhoneController.text =
          customer.authorizedPersonPhone ?? '';
      _notesController.text = customer.notes ?? '';

      // Enum değerlerini ayarla
      _customerType = customer.customerType;
      _status = customer.status;
      _currency = customer.customerCurrency ?? 'TRY';
      _isTaxExempt = customer.isTaxExempt;
      _selectedCategory1Id = customer.category1;
      _selectedCategory2Id = customer.category2;

      // Şubeleri yükle
      _branches.clear();
      if (customer.branches != null) {
        _branches.addAll(customer.branches!);
      }

      setState(() {
        _isInitialized = true;
      });

      AppLogger.info('Customer data loaded successfully: ${customer.name}');
    } catch (e) {
      AppLogger.error('Error loading customer data', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müşteri verileri yüklenirken hata oluştu: $e'),
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

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuthService.currentUserId ?? 'system';
      final parsedCreditLimit =
          CurrencyHelper.parseCurrency(_creditLimitController.text);
      final parsedOpeningBalance =
          CurrencyHelper.parseCurrency(_openingBalanceController.text);
      final parsedFixedDiscount =
          CurrencyHelper.parseCurrency(_fixedDiscountRateController.text);

      // Debug mesajları
      debugPrint('DEBUG: Ödeme vadesi: ${_maturityDaysController.text}');
      debugPrint(
          'DEBUG: Sabit iskonto oranı: ${_fixedDiscountRateController.text}');
      debugPrint('DEBUG: Parsed fixed discount: $parsedFixedDiscount');

      // Mevcut müşteriyi güncelle
      final customers = await ref.read(customersProvider.future);
      final existingCustomer = customers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => throw Exception('Müşteri bulunamadı'),
      );

      final customer = existingCustomer.copyWith(
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
        openingBalance: parsedOpeningBalance,
        customerCurrency: _currency,
        maturityDays: int.tryParse(_maturityDaysController.text),
        fixedDiscountRate: parsedFixedDiscount,
        isTaxExempt: _isTaxExempt,
        isActive: existingCustomer.isActive,
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
        updatedAt: DateTime.now(),
        updatedBy: uid,
      );

      // Debug mesajları - güncellenmiş müşteri
      debugPrint(
          'DEBUG: Güncellenmiş müşteri - maturityDays: ${customer.maturityDays}');
      debugPrint(
          'DEBUG: Güncellenmiş müşteri - fixedDiscountRate: ${customer.fixedDiscountRate}');

      await ref.read(customerRepositoryProvider).updateCustomer(customer);
      AppLogger.info('Customer updated successfully: ${customer.name}');

      // Provider'ı zorla yenile
      ref.invalidate(customersProvider);

      // Debug: Provider yenilendikten sonra müşteri verilerini kontrol et
      debugPrint(
          'DEBUG: Provider yenilendikten sonra müşteri verileri kontrol ediliyor...');

      // Provider'ı zorla yenile ve bekle
      final _ = ref.refresh(customersProvider);

      final updatedCustomers = await ref.read(customersProvider.future);
      final updatedCustomer = updatedCustomers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => throw Exception('Müşteri bulunamadı'),
      );
      debugPrint(
          'DEBUG: Yenilenen müşteri - maturityDays: ${updatedCustomer.maturityDays}');
      debugPrint(
          'DEBUG: Yenilenen müşteri - fixedDiscountRate: ${updatedCustomer.fixedDiscountRate}');

      // Eğer hala NULL ise, Firestore'dan direkt çek
      if (updatedCustomer.maturityDays == null ||
          updatedCustomer.fixedDiscountRate == null) {
        debugPrint(
            'DEBUG: Provider verileri NULL, Firestore\'dan direkt çekiliyor...');
        // Firestore'dan direkt müşteri verisini çek
        final directCustomer = await ref
            .read(customerRepositoryProvider)
            .getCustomerById(widget.customerId);
        debugPrint(
            'DEBUG: Direkt Firestore müşteri - maturityDays: ${directCustomer?.maturityDays}');
        debugPrint(
            'DEBUG: Direkt Firestore müşteri - fixedDiscountRate: ${directCustomer?.fixedDiscountRate}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} başarıyla güncellendi'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error updating customer', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müşteri güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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

  Future<void> _deleteCustomer() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final customers = await ref.read(customersProvider.future);
      final customer = customers.firstWhere(
        (c) => c.id == widget.customerId,
        orElse: () => throw Exception('Müşteri bulunamadı'),
      );

      // Bakiye kontrolü
      if (customer.currentBalance != 0.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bu müşterinin ${CurrencyHelper.formatCurrency(customer.currentBalance, customer.customerCurrency ?? 'TRY')} bakiyesi var. Bakiye sıfır olmadığı sürece müşteri silinemez.',
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      await ref
          .read(customerRepositoryProvider)
          .deleteCustomer(widget.customerId);
      AppLogger.info('Customer deleted successfully: ${customer.name}');

      // Provider'ı yenile
      ref.invalidate(customersProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${customer.name} başarıyla silindi'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error deleting customer', e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Müşteri silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final customers = await ref.read(customersProvider.future);
    final customer = customers.firstWhere(
      (c) => c.id == widget.customerId,
      orElse: () => throw Exception('Müşteri bulunamadı'),
    );

    final canDelete = customer.currentBalance == 0.0;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Müşteri Sil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${customer.name} müşterisini silmek istediğinizden emin misiniz?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (!canDelete) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bu müşterinin ${CurrencyHelper.formatCurrency(customer.currentBalance, customer.customerCurrency ?? 'TRY')} bakiyesi var. Bakiye sıfır olmadığı sürece müşteri silinemez.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            if (canDelete)
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await _deleteCustomer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sil'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Müşteri Düzenle'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Müşteri bilgileri yükleniyor...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Müşteri Düzenle'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // Genel Bilgiler
                  _buildSectionCard(
                    title: 'Genel Bilgiler',
                    icon: Icons.person_outline,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Müşteri Adı / Ünvan *',
                        hint: 'Müşteri adını girin',
                        validator: (value) =>
                            Validators.required(value, 'Müşteri adı'),
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField(
                        label: 'Müşteri Kodu',
                        value: _customerCodeController.text.isNotEmpty
                            ? _customerCodeController.text
                            : 'Otomatik oluşturulacak',
                        icon: Icons.badge_outlined,
                        subtitle: 'Bu alan otomatik oluşturulur',
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Vergi Bilgileri
                  _buildSectionCard(
                    title: 'Vergi Bilgileri',
                    icon: Icons.receipt_long_outlined,
                    children: [
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
                      CheckboxListTile(
                        title: const Text('Vergiden Muaf'),
                        value: _isTaxExempt,
                        onChanged: (value) {
                          setState(() {
                            _isTaxExempt = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Adres Bilgileri
                  _buildSectionCard(
                    title: 'Adres Bilgileri',
                    icon: Icons.location_on_outlined,
                    children: [
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Kategori / Sınıflandırma
                  _buildSectionCard(
                    title: 'Kategori / Sınıflandırma',
                    icon: Icons.category_outlined,
                    children: [
                      _buildCategoriesRow(),
                      const SizedBox(height: 16),
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Finansal Bilgiler
                  _buildSectionCard(
                    title: 'Finansal Bilgiler',
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      // Para Birimi - Sadece Okunur (Güzel Görünüm)
                      _buildReadOnlyField(
                        label: 'Para Birimi',
                        value: _currency,
                        icon: Icons.currency_exchange,
                        subtitle: 'Bu alan değiştirilemez',
                      ),
                      const SizedBox(height: 16),

                      // Açılış Bakiyesi - Sadece Okunur (Güzel Görünüm)
                      _buildReadOnlyField(
                        label: 'Açılış Bakiyesi',
                        value: _openingBalanceController.text.isNotEmpty
                            ? '${_openingBalanceController.text} $_currency'
                            : '0,00 $_currency',
                        icon: Icons.account_balance,
                        subtitle: 'Bu alan değiştirilemez',
                      ),
                      const SizedBox(height: 20),

                      // Düzenlenebilir Alanlar
                      Row(
                        children: [
                          Expanded(
                            child: AutoFormattedTextField(
                              label: 'Kredi Limiti *',
                              hint: '0,00',
                              controller: _creditLimitController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: false),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.,]')),
                              ],
                              formatter: (raw) {
                                return _formatMoneyTyping(raw,
                                    allowNegative: false);
                              },
                              validator: (value) =>
                                  Validators.required(value, 'Kredi limiti'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _maturityDaysController,
                              label: 'Ödeme Vadesi (Gün) *',
                              hint: '30',
                              keyboardType: TextInputType.number,
                              validator: (value) => value?.isNotEmpty == true
                                  ? Validators.integer(value)
                                  : Validators.required(value, 'Ödeme vadesi'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AutoFormattedTextField(
                        label: 'Sabit İskonto Oranı (%) *',
                        hint: '0,00',
                        controller: _fixedDiscountRateController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        formatter: (raw) {
                          return _formatMoneyTyping(raw, allowNegative: false);
                        },
                        validator: (value) =>
                            Validators.required(value, 'Sabit iskonto oranı'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ek Bilgiler
                  _buildSectionCard(
                    title: 'Ek Bilgiler',
                    icon: Icons.info_outline,
                    children: [
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
                              validator: (value) => value?.isNotEmpty == true
                                  ? Validators.phone(value)
                                  : null,
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
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sistem Bilgileri
                  _buildSectionCard(
                    title: 'Sistem Bilgileri',
                    icon: Icons.settings_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildReadOnlyField(
                              label: 'Oluşturulma Tarihi',
                              value: 'Sistem tarafından belirlenir',
                              icon: Icons.calendar_today,
                              subtitle: 'Bu alan değiştirilemez',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReadOnlyField(
                              label: 'Güncellenme Tarihi',
                              value: 'Sistem tarafından belirlenir',
                              icon: Icons.update,
                              subtitle: 'Bu alan değiştirilemez',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildReadOnlyField(
                              label: 'Oluşturan Kişi',
                              value: 'Sistem',
                              icon: Icons.person_add,
                              subtitle: 'Bu alan değiştirilemez',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReadOnlyField(
                              label: 'Güncelleyen Kişi',
                              value: 'Sistem',
                              icon: Icons.person_outline,
                              subtitle: 'Bu alan değiştirilemez',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBranchesCard(),
                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Müşteri Düzenleme',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Müşteri bilgileri yükleniyor...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
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
                      IconButton(
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
                      IconButton(
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                    companyId: 'default_company', // Silinen modül: user_profile
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
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori oluşturulamadı: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
    return Container(
      width: double.infinity,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Şubeler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _addBranch,
                icon: const Icon(Icons.add),
                label: const Text('Şube Ekle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_branches.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'Henüz şube eklenmemiş',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          for (int i = 0; i < _branches.length; i++) ...[
            _buildBranchItem(i),
            if (i < _branches.length - 1) const SizedBox(height: 12),
          ],
        ],
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Şubeyi kaldır',
                onPressed: () => _removeBranch(index),
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: addressController,
            label: 'Adres',
            hint: 'Adres',
            onChanged: (val) {
              _branches[index] = _branches[index].copyWith(address: val);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: phoneController,
                  label: 'Telefon',
                  hint: '0555 123 45 67',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isNotEmpty == true
                      ? Validators.phone(value)
                      : null,
                  onChanged: (val) {
                    _branches[index] = _branches[index].copyWith(phone: val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: emailController,
                  label: 'E-posta',
                  hint: 'mail@ornek.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value?.isNotEmpty == true
                      ? Validators.email(value)
                      : null,
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

  Widget _buildActionButtons() {
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
        children: [
          Row(
            children: [
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
                  text: 'Güncelle',
                  onPressed: _isLoading ? null : _updateCustomer,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isDeleting ? null : _showDeleteConfirmationDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Müşteriyi Sil'),
            ),
          ),
        ],
      ),
    );
  }

  /// Sadece okunur alanlar için güzel görünüm
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
