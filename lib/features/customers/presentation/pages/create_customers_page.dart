// ========== lib/features/customers/presentation/pages/create_customer_page.dart ==========

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:tamgaci/features/customers/data/models/customer_entity.dart'; // Removed - using Firebase only
import 'package:uuid/uuid.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/services/firebase/firebase_auth_service.dart';
import '../../../../core/errors/error_dialog.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_enums.dart';
import '../../domain/entities/customer_branch.dart';
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
  final _customerCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _maturityDaysController = TextEditingController();
  final _fixedDiscountRateController = TextEditingController();
  final _authorizedPersonNameController = TextEditingController();
  final _authorizedPersonPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  CustomerType _selectedType = CustomerType.individual;
  String _currency = 'TRY';
  bool _isTaxExempt = false;
  bool _hasDifferentShippingAddress = false;
  String? _selectedCategory1Id;
  String? _selectedCategory2Id;
  final List<CustomerBranch> _branches = [];
  final Map<String, Map<String, TextEditingController>> _branchControllers = {};
  final bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomerData();
    } else {
      _generateCustomerCode();
    }
  }

  Future<void> _loadCustomerData() async {
    try {
      final customer =
          await ref.read(customerProvider(widget.customerId!).future);

      if (customer == null) {
        _generateCustomerCode();
        return;
      }

      setState(() {
        _nameController.text = customer.name;
        _customerCodeController.text = customer.customerCode ?? '';
        _emailController.text = customer.email ?? '';
        _phoneController.text = customer.phone ?? '';
        _addressController.text = customer.address ?? '';
        _shippingAddressController.text = customer.shippingAddress ?? '';
        _hasDifferentShippingAddress = customer.shippingAddress != null &&
            customer.shippingAddress!.isNotEmpty;
        _taxNumberController.text = customer.taxNumber ?? '';
        _taxOfficeController.text = customer.taxOffice ?? '';
        _cityController.text = customer.city ?? '';
        _countryController.text = customer.country ?? '';
        _postalCodeController.text = customer.postalCode ?? '';
        _openingBalanceController.text =
            customer.openingBalance?.toString() ?? '';
        _maturityDaysController.text = customer.maturityDays?.toString() ?? '';
        _fixedDiscountRateController.text =
            customer.fixedDiscountRate?.toString() ?? '';
        _authorizedPersonNameController.text =
            customer.authorizedPersonName ?? '';
        _authorizedPersonPhoneController.text =
            customer.authorizedPersonPhone ?? '';
        _notesController.text = customer.notes ?? '';
        _selectedType = customer.customerType;
        _currency = customer.customerCurrency ?? 'TRY';
        _isTaxExempt = customer.isTaxExempt;
        _selectedCategory1Id = customer.category1;
        _selectedCategory2Id = customer.category2;
        _disposeBranchControllers();
        _branches.clear();
        if (customer.branches != null) {
          _branches.addAll(customer.branches!);
          _initializeBranchControllers();
        }
      });
    } catch (e) {
      // Hata durumunda yeni kod oluştur
      _generateCustomerCode();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customerCodeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _shippingAddressController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _openingBalanceController.dispose();
    _maturityDaysController.dispose();
    _fixedDiscountRateController.dispose();
    _authorizedPersonNameController.dispose();
    _authorizedPersonPhoneController.dispose();
    _notesController.dispose();
    _disposeBranchControllers();
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
      final branchId = _uuid.v4();
      _branches.add(CustomerBranch(
        id: branchId,
        name: 'Yeni Şube',
        address: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      // Controller'ları oluştur
      _branchControllers[branchId] = {
        'name': TextEditingController(text: 'Yeni Şube'),
        'address': TextEditingController(text: ''),
        'phone': TextEditingController(text: ''),
        'email': TextEditingController(text: ''),
      };
    });
  }

  void _removeBranch(int index) {
    setState(() {
      final branch = _branches[index];
      // Controller'ları dispose et
      final controllers = _branchControllers[branch.id];
      if (controllers != null) {
        controllers['name']?.dispose();
        controllers['address']?.dispose();
        controllers['phone']?.dispose();
        controllers['email']?.dispose();
        _branchControllers.remove(branch.id);
      }
      _branches.removeAt(index);
    });
  }

  void _initializeBranchControllers() {
    for (final branch in _branches) {
      if (!_branchControllers.containsKey(branch.id)) {
        _branchControllers[branch.id] = {
          'name': TextEditingController(text: branch.name),
          'address': TextEditingController(text: branch.address),
          'phone': TextEditingController(text: branch.phone ?? ''),
          'email': TextEditingController(text: branch.email ?? ''),
        };
      }
    }
  }

  void _disposeBranchControllers() {
    for (final controllers in _branchControllers.values) {
      controllers['name']?.dispose();
      controllers['address']?.dispose();
      controllers['phone']?.dispose();
      controllers['email']?.dispose();
    }
    _branchControllers.clear();
  }

  Widget _buildHeaderCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.primaryContainer.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.person_add_alt_1, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Müşteri',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Yeni müşteri bilgilerini girin ve müşteri kodu otomatik oluşturulsun.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.8 : 0.95,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.4 : 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(customerFormProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: null,
        showDrawer: false,
        showBackButton: true,
        onBackPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/customers');
          }
        },
        actions: formState.isLoading
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form alanları
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLargeScreen = TamgaciConstants.isDesktop(context) ||
                        TamgaciConstants.isWideDesktop(context);
                    final maxWidth = isLargeScreen ? 1100.0 : null;
                    final horizontalPadding =
                        TamgaciConstants.pagePadding(context);
                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth ?? constraints.maxWidth,
                        ),
                        child: SingleChildScrollView(
                          padding: horizontalPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (formState.errorMessage != null)
                                _buildErrorMessage(formState.errorMessage!),
                              if (formState.successMessage != null)
                                _buildSuccessMessage(formState.successMessage!),
                              _buildHeaderCard(),
                              _buildCustomerTypeSelection(),
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildBasicInfoSection(),
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildContactInfoSection(),
                              if (_selectedType == CustomerType.company) ...[
                                const SizedBox(
                                    height: TamgaciConstants.spaceLG),
                                _buildTaxInfoSection(),
                              ],
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildAddressInfoSection(),
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildFinancialInfoSection(),
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildClassificationSection(),
                              if (_selectedType == CustomerType.company) ...[
                                const SizedBox(
                                    height: TamgaciConstants.spaceLG),
                                _buildAuthorizedPersonSection(),
                                const SizedBox(
                                    height: TamgaciConstants.spaceLG),
                                _buildBranchesSection(),
                              ],
                              const SizedBox(height: TamgaciConstants.spaceLG),
                              _buildNotesSection(),
                              const SizedBox(height: TamgaciConstants.spaceXL),
                              _buildSaveButton(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hata mesajı widget'ı
  Widget _buildErrorMessage(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background =
        colorScheme.errorContainer.withValues(alpha: isDark ? 0.35 : 0.7);
    final border = colorScheme.error.withValues(alpha: isDark ? 0.6 : 0.4);
    final textColor = colorScheme.onErrorContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Başarı mesajı widget'ı
  Widget _buildSuccessMessage(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final background =
        colorScheme.secondaryContainer.withValues(alpha: isDark ? 0.35 : 0.7);
    final border = colorScheme.secondary.withValues(alpha: isDark ? 0.5 : 0.3);
    final textColor = colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: TamgaciConstants.spaceSM),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Müşteri tipi seçimi
  Widget _buildCustomerTypeSelection() {
    return _buildSectionContainer(
      icon: Icons.people_alt_outlined,
      title: 'Müşteri Tipi',
      subtitle: 'Bireysel ya da kurumsal müşteri seçin',
      child: Row(
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
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.45)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    TamgaciConstants.radiusSM,
                  ),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 1.6 : 1,
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
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: TamgaciConstants.spaceXS),
                    Text(
                      type.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Temel bilgiler bölümü
  Widget _buildBasicInfoSection() {
    return _buildSectionContainer(
      icon: Icons.badge_outlined,
      title: 'Genel Bilgiler',
      subtitle: 'Zorunlu alanları doldurun',
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              label: _selectedType == CustomerType.company
                  ? 'Şirket Adı *'
                  : 'Ad Soyad *',
              hint: _selectedType == CustomerType.company
                  ? 'Örnek Teknoloji A.Ş.'
                  : 'Ahmet Yılmaz',
              icon: _selectedType == CustomerType.company
                  ? Icons.business
                  : Icons.person,
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
          const SizedBox(height: TamgaciConstants.spaceMD),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customerCodeController,
                  decoration: _buildInputDecoration(
                    label: 'Müşteri Kodu',
                    hint: 'Otomatik oluşturulur',
                    icon: Icons.qr_code_2_outlined,
                  ),
                ),
              ),
              const SizedBox(width: TamgaciConstants.spaceSM),
              IconButton(
                onPressed: _generateCustomerCode,
                icon: const Icon(Icons.refresh),
                tooltip: 'Yeni kod oluştur',
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// İletişim bilgileri bölümü
  Widget _buildContactInfoSection() {
    return _buildSectionContainer(
      icon: Icons.contact_mail_outlined,
      title: 'İletişim Bilgileri',
      subtitle: 'Telefon ve e-posta bilgileri',
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _buildInputDecoration(
              label: 'E-posta',
              hint: 'ornek@email.com',
              icon: Icons.email_outlined,
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
            decoration: _buildInputDecoration(
              label: 'Telefon',
              hint: '+90 555 123 45 67',
              icon: Icons.phone_outlined,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 10) {
                return 'Geçerli bir telefon numarası giriniz';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Vergi bilgileri bölümü
  Widget _buildTaxInfoSection() {
    return _buildSectionContainer(
      icon: Icons.receipt_long_outlined,
      title: 'Vergi Bilgileri',
      subtitle: 'Kurumsal müşteriler için zorunlu alanlar',
      child: Column(
        children: [
          TextFormField(
            controller: _taxNumberController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration(
              label: 'Vergi Numarası',
              hint: '1234567890',
              icon: Icons.receipt_outlined,
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
            decoration: _buildInputDecoration(
              label: 'Vergi Dairesi',
              hint: 'Kadıköy Vergi Dairesi',
              icon: Icons.account_balance_outlined,
            ),
          ),
        ],
      ),
    );
  }

  /// Adres bilgileri bölümü
  Widget _buildAddressInfoSection() {
    return _buildSectionContainer(
      icon: Icons.location_on_outlined,
      title: 'Adres Bilgileri',
      subtitle: 'Teslimat ve fatura adresi',
      child: Column(
        children: [
          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: _buildInputDecoration(
              label: 'Adres',
              hint: 'Açık adres bilgisini giriniz...',
              icon: Icons.location_on_outlined,
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
                  decoration: _buildInputDecoration(
                    label: 'Şehir',
                    hint: 'İstanbul',
                    icon: Icons.location_city_outlined,
                  ),
                ),
              ),
              const SizedBox(width: TamgaciConstants.spaceMD),
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(
                    label: 'Posta Kodu',
                    hint: '34000',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          TextFormField(
            controller: _countryController,
            decoration: _buildInputDecoration(
              label: 'Ülke',
              hint: 'Türkiye',
              icon: Icons.public_outlined,
            ),
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          Container(
            padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: CheckboxListTile(
              title: Text(
                'Sevk Adresi Farklı',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Sevk adresi fatura adresinden farklıysa işaretleyin',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _hasDifferentShippingAddress,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  _hasDifferentShippingAddress = value ?? false;
                  if (!_hasDifferentShippingAddress) {
                    _shippingAddressController.clear();
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (_hasDifferentShippingAddress) ...[
            const SizedBox(height: TamgaciConstants.spaceMD),
            TextFormField(
              controller: _shippingAddressController,
              maxLines: 3,
              decoration: _buildInputDecoration(
                label: 'Sevk Adresi *',
                hint: 'Sevk adresi bilgisini giriniz...',
                icon: Icons.local_shipping_outlined,
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (_hasDifferentShippingAddress &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Sevk adresi zorunludur';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Finansal bilgiler bölümü
  Widget _buildFinancialInfoSection() {
    return _buildSectionContainer(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Finansal Bilgiler',
      subtitle: 'Para birimi ve finansal ayarlar',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _currency,
            decoration: _buildInputDecoration(
              label: 'Para Birimi',
              hint: 'Para birimi seçin',
              icon: Icons.currency_exchange_outlined,
            ),
            items: const [
              DropdownMenuItem(value: 'TRY', child: Text('TRY - Türk Lirası')),
              DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
              DropdownMenuItem(
                  value: 'GBP', child: Text('GBP - British Pound')),
              DropdownMenuItem(value: 'CHF', child: Text('CHF - Swiss Franc')),
              DropdownMenuItem(value: 'JPY', child: Text('JPY - Japanese Yen')),
              DropdownMenuItem(
                  value: 'CAD', child: Text('CAD - Canadian Dollar')),
              DropdownMenuItem(
                  value: 'AUD', child: Text('AUD - Australian Dollar')),
              DropdownMenuItem(value: 'DKK', child: Text('DKK - Danish Krone')),
              DropdownMenuItem(
                  value: 'SEK', child: Text('SEK - Swedish Krona')),
              DropdownMenuItem(
                  value: 'NOK', child: Text('NOK - Norwegian Krone')),
              DropdownMenuItem(value: 'SAR', child: Text('SAR - Saudi Riyal')),
              DropdownMenuItem(
                  value: 'KWD', child: Text('KWD - Kuwaiti Dinar')),
              DropdownMenuItem(
                  value: 'BGN', child: Text('BGN - Bulgarian Lev')),
              DropdownMenuItem(value: 'RON', child: Text('RON - Romanian Leu')),
              DropdownMenuItem(
                  value: 'RUB', child: Text('RUB - Russian Ruble')),
              DropdownMenuItem(value: 'IRR', child: Text('IRR - Iranian Rial')),
              DropdownMenuItem(value: 'CNY', child: Text('CNY - Chinese Yuan')),
              DropdownMenuItem(
                  value: 'PKR', child: Text('PKR - Pakistani Rupee')),
              DropdownMenuItem(value: 'QAR', child: Text('QAR - Qatari Riyal')),
              DropdownMenuItem(value: 'AED', child: Text('AED - UAE Dirham')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _currency = value;
                });
              }
            },
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _openingBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-0-9.,]')),
                  ],
                  decoration: _buildInputDecoration(
                    label: 'Açılış Bakiyesi',
                    hint: '0,00 (eksi değer girilebilir)',
                    icon: Icons.account_balance_outlined,
                  ),
                ),
              ),
              const SizedBox(width: TamgaciConstants.spaceMD),
              Expanded(
                child: TextFormField(
                  controller: _maturityDaysController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: _buildInputDecoration(
                    label: 'Vade (Gün)',
                    hint: '30',
                    icon: Icons.schedule_outlined,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final days = int.tryParse(value);
                      if (days == null || days < 0) {
                        return 'Geçerli bir gün sayısı giriniz';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          TextFormField(
            controller: _fixedDiscountRateController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: false,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: _buildInputDecoration(
              label: 'Sabit İskonto (%)',
              hint: '0,00',
              icon: Icons.percent_outlined,
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final rate = CurrencyHelper.parseCurrency(value);
                if (rate < 0 || rate > 100) {
                  return 'İskonto oranı 0-100 arasında olmalıdır';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          Container(
            padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: CheckboxListTile(
              title: Text(
                'Vergiden Muaf',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Müşteri vergiden muaf tutulacak',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _isTaxExempt,
              tristate: false,
              onChanged: (value) {
                setState(() {
                  _isTaxExempt = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Sınıflandırma bölümü
  Widget _buildClassificationSection() {
    return _buildSectionContainer(
      icon: Icons.category_outlined,
      title: 'Sınıflandırma',
      subtitle: 'Kategori 1 ve Kategori 2 seçimi',
      child: Column(
        children: [
          // Kategori 1
          Consumer(
            builder: (context, ref, _) {
              final categoriesAsync = ref.watch(customerCategoriesProvider(1));
              return categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(
                                TamgaciConstants.radiusSM,
                              ),
                            ),
                            child: Text(
                              'Kategori bulunamadı',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              _showCreateCategoryDialog(ref, level: 1),
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
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
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedCategory1Id,
                          decoration: _buildInputDecoration(
                            label: 'Kategori 1',
                            hint: 'Seçiniz',
                            icon: Icons.category_outlined,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Seçiniz'),
                            ),
                            ...categories.map((category) {
                              return DropdownMenuItem<String?>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory1Id = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            _showCreateCategoryDialog(ref, level: 1),
                        icon: const Icon(Icons.add),
                        tooltip: 'Yeni kategori ekle',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text(
                  'Kategori yüklenemedi: $error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          // Kategori 2
          Consumer(
            builder: (context, ref, _) {
              final categoriesAsync = ref.watch(customerCategoriesProvider(2));
              return categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(
                                TamgaciConstants.radiusSM,
                              ),
                            ),
                            child: Text(
                              'Kategori bulunamadı',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              _showCreateCategoryDialog(ref, level: 2),
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
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
                        child: DropdownButtonFormField<String?>(
                          initialValue: _selectedCategory2Id,
                          decoration: _buildInputDecoration(
                            label: 'Kategori 2',
                            hint: 'Seçiniz',
                            icon: Icons.category_outlined,
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Seçiniz'),
                            ),
                            ...categories.map((category) {
                              return DropdownMenuItem<String?>(
                                value: category.id,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory2Id = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            _showCreateCategoryDialog(ref, level: 2),
                        icon: const Icon(Icons.add),
                        tooltip: 'Yeni kategori ekle',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Text(
                  'Kategori yüklenemedi: $error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Yeni kategori oluşturma dialog'u
  Future<void> _showCreateCategoryDialog(WidgetRef ref,
      {required int level}) async {
    final nameController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Yeni Kategori (${level == 1 ? 'Kategori 1' : 'Kategori 2'})',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          content: TextField(
            controller: nameController,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            decoration: InputDecoration(
              labelText: 'Kategori Adı',
              labelStyle: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
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
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                try {
                  final categoryId =
                      await ref.read(createCustomerCategoryProvider((
                    name: name,
                    level: level,
                    parentId: null,
                    companyId: 'default_company',
                    userId: FirebaseAuthService.currentUserId ?? 'system',
                  )).future);

                  // Provider'ı yenile
                  ref.invalidate(customerCategoriesProvider(level));

                  // Yeni oluşturulan kategoriyi seç
                  setState(() {
                    if (level == 1) {
                      _selectedCategory1Id = categoryId;
                    } else {
                      _selectedCategory2Id = categoryId;
                    }
                  });

                  if (mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name kategorisi başarıyla oluşturuldu'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  /// Yetkili kişi bölümü
  Widget _buildAuthorizedPersonSection() {
    return _buildSectionContainer(
      icon: Icons.person_pin_outlined,
      title: 'Yetkili Kişi Bilgileri',
      subtitle: 'Kurumsal müşteri yetkili kişi bilgileri',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _authorizedPersonNameController,
                  decoration: _buildInputDecoration(
                    label: 'Yetkili Kişi Adı',
                    hint: 'Ad Soyad',
                    icon: Icons.person_outlined,
                  ),
                ),
              ),
              const SizedBox(width: TamgaciConstants.spaceMD),
              Expanded(
                child: TextFormField(
                  controller: _authorizedPersonPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    label: 'Yetkili Kişi Telefonu',
                    hint: '0555 123 45 67',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        value.length < 10) {
                      return 'Geçerli bir telefon numarası giriniz';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Şubeler bölümü
  Widget _buildBranchesSection() {
    return _buildSectionContainer(
      icon: Icons.business_outlined,
      title: 'Şubeler',
      subtitle: 'Müşteri şube bilgileri',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Şube Listesi',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addBranch,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Şube Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          if (_branches.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Henüz şube eklenmemiş',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yeni şube eklemek için yukarıdaki butona tıklayın',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          if (_branches.isNotEmpty) ...[
            for (int i = 0; i < _branches.length; i++) ...[
              _buildBranchItem(i),
              if (i < _branches.length - 1)
                const SizedBox(height: TamgaciConstants.spaceMD),
            ],
          ],
        ],
      ),
    );
  }

  /// Şube item widget'ı
  Widget _buildBranchItem(int index) {
    final branch = _branches[index];

    // Controller'ları al veya oluştur
    if (!_branchControllers.containsKey(branch.id)) {
      _branchControllers[branch.id] = {
        'name': TextEditingController(text: branch.name),
        'address': TextEditingController(text: branch.address),
        'phone': TextEditingController(text: branch.phone ?? ''),
        'email': TextEditingController(text: branch.email ?? ''),
      };
    }

    final controllers = _branchControllers[branch.id]!;
    final nameController = controllers['name']!;
    final addressController = controllers['address']!;
    final phoneController = controllers['phone']!;
    final emailController = controllers['email']!;

    // Controller text'lerini güncelle (eğer branch değiştiyse)
    if (nameController.text != branch.name) {
      nameController.text = branch.name;
    }
    if (addressController.text != branch.address) {
      addressController.text = branch.address;
    }
    if (phoneController.text != (branch.phone ?? '')) {
      phoneController.text = branch.phone ?? '';
    }
    if (emailController.text != (branch.email ?? '')) {
      emailController.text = branch.email ?? '';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Şube ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
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
          const SizedBox(height: TamgaciConstants.spaceMD),
          TextFormField(
            controller: nameController,
            decoration: _buildInputDecoration(
              label: 'Şube Adı',
              hint: 'Örn: Merkez',
              icon: Icons.business_outlined,
            ),
            onChanged: (val) {
              setState(() {
                _branches[index] = _branches[index].copyWith(name: val);
              });
            },
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          TextFormField(
            controller: addressController,
            decoration: _buildInputDecoration(
              label: 'Adres',
              hint: 'Şube adresi',
              icon: Icons.location_on_outlined,
            ),
            maxLines: 2,
            onChanged: (val) {
              setState(() {
                _branches[index] = _branches[index].copyWith(address: val);
              });
            },
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    label: 'Telefon',
                    hint: '0555 123 45 67',
                    icon: Icons.phone_outlined,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _branches[index] = _branches[index].copyWith(phone: val);
                    });
                  },
                ),
              ),
              const SizedBox(width: TamgaciConstants.spaceMD),
              Expanded(
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    label: 'E-posta',
                    hint: 'mail@ornek.com',
                    icon: Icons.email_outlined,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _branches[index] = _branches[index].copyWith(email: val);
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

  /// Notlar bölümü
  Widget _buildNotesSection() {
    return _buildSectionContainer(
      icon: Icons.sticky_note_2_outlined,
      title: 'Notlar',
      subtitle: 'Müşteri hakkında özel notlar',
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        decoration: _buildInputDecoration(
          label: 'Notlar',
          hint: 'Müşteri hakkında notlarınız...',
          icon: Icons.note_outlined,
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    bool alignLabelWithHint = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary) : null,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest
          .withValues(alpha: isDark ? 0.35 : 0.85),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDark ? 0.4 : 0.6,
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.6,
        ),
      ),
    );
  }

  /// Kaydet butonu
  Widget _buildSaveButton() {
    final formState = ref.watch(customerFormProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: TamgaciConstants.paddingMedium(context),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.3 : 0.4,
            ),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: TamgaciConstants.buttonHeight(context),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
              ),
            ),
            onPressed: formState.isLoading ? null : _saveCustomer,
            child: formState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Text('Müşteriyi Kaydet'),
          ),
        ),
      ),
    );
  }

  /// Form validasyon hatalarını topla ve snackbar ile göster
  void _showValidationErrors() {
    final List<String> errors = [];

    // Müşteri Adı/Ünvanı kontrolü
    final nameValue = _nameController.text.trim();
    if (nameValue.isEmpty) {
      errors.add('• Müşteri Adı/Ünvanı zorunludur');
    } else if (nameValue.length < 2) {
      errors.add('• Müşteri Adı/Ünvanı en az 2 karakter olmalıdır');
    }

    // E-posta kontrolü
    final emailValue = _emailController.text.trim();
    if (emailValue.isNotEmpty && !emailValue.contains('@')) {
      errors.add('• Geçerli bir e-posta adresi giriniz');
    }

    // Telefon kontrolü
    final phoneValue = _phoneController.text.trim();
    if (phoneValue.isNotEmpty && phoneValue.length < 10) {
      errors.add('• Geçerli bir telefon numarası giriniz (en az 10 karakter)');
    }

    // Kurumsal müşteri için vergi numarası kontrolü
    if (_selectedType == CustomerType.company) {
      final taxNumberValue = _taxNumberController.text.trim();
      if (taxNumberValue.isEmpty) {
        errors.add('• Kurumsal müşteri için vergi numarası zorunludur');
      } else if (taxNumberValue.length != 10) {
        errors.add('• Vergi numarası 10 haneli olmalıdır');
      }
    }

    // Sevk adresi kontrolü
    if (_hasDifferentShippingAddress) {
      final shippingAddressValue = _shippingAddressController.text.trim();
      if (shippingAddressValue.isEmpty) {
        errors.add('• Sevk adresi zorunludur');
      }
    }

    // Vade (Gün) kontrolü
    final maturityDaysValue = _maturityDaysController.text.trim();
    if (maturityDaysValue.isNotEmpty) {
      final days = int.tryParse(maturityDaysValue);
      if (days == null || days < 0) {
        errors.add('• Vade (Gün) geçerli bir sayı olmalıdır');
      }
    }

    // Hata mesajını oluştur
    String errorMessage;
    if (errors.isEmpty) {
      errorMessage = 'Lütfen formu kontrol ediniz';
    } else if (errors.length == 1) {
      errorMessage = errors.first;
    } else {
      errorMessage = 'Lütfen şu alanları kontrol ediniz:\n${errors.join('\n')}';
    }

    // Snackbar göster
    if (!mounted) return;
    ErrorSnackBar.showValidationError(context, errorMessage);
  }

  /// Müşteri kaydetme işlemi
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      // Form validasyon hatalarını topla ve göster
      _showValidationErrors();
      return;
    }

    final parsedOpeningBalance = _openingBalanceController.text
            .trim()
            .isNotEmpty
        ? CurrencyHelper.parseCurrency(_openingBalanceController.text.trim())
        : null;

    final parsedFixedDiscount = _fixedDiscountRateController.text
            .trim()
            .isNotEmpty
        ? CurrencyHelper.parseCurrency(_fixedDiscountRateController.text.trim())
        : null;

    final customer = Customer(
      id: widget.customerId ?? _uuid.v4(),
      name: _nameController.text.trim(),
      customerCode: _customerCodeController.text.trim().isNotEmpty
          ? _customerCodeController.text.trim()
          : null,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      shippingAddress: _hasDifferentShippingAddress &&
              _shippingAddressController.text.trim().isNotEmpty
          ? _shippingAddressController.text.trim()
          : null,
      taxNumber: _taxNumberController.text.trim().isEmpty
          ? null
          : _taxNumberController.text.trim(),
      taxOffice: _taxOfficeController.text.trim().isEmpty
          ? null
          : _taxOfficeController.text.trim(),
      customerType: _selectedType,
      status: CustomerStatus.active,
      customerCurrency: _currency,
      openingBalance: parsedOpeningBalance,
      maturityDays: _maturityDaysController.text.trim().isNotEmpty
          ? int.tryParse(_maturityDaysController.text.trim())
          : null,
      fixedDiscountRate: parsedFixedDiscount,
      isTaxExempt: _isTaxExempt,
      category1: _selectedCategory1Id,
      category2: _selectedCategory2Id,
      authorizedPersonName:
          _authorizedPersonNameController.text.trim().isNotEmpty
              ? _authorizedPersonNameController.text.trim()
              : null,
      authorizedPersonPhone:
          _authorizedPersonPhoneController.text.trim().isNotEmpty
              ? _authorizedPersonPhoneController.text.trim()
              : null,
      branches: _branches.isEmpty ? null : List.from(_branches),
      companyId: 'default_company_id', // Get from user context
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
      createdBy: 'current_user_id', // Get from auth context
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

      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.customerId == null
                ? 'Müşteri başarıyla oluşturuldu'
                : 'Müşteri başarıyla güncellendi',
          ),
          backgroundColor: colorScheme.primary,
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/customers');
      }
    } catch (e) {
      if (!mounted) return;
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}
