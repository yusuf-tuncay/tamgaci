// ========== CREATE ACCOUNT PAGE ==========
// lib/features/cash_management/presentation/pages/create_account_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/account.dart';

/// Yeni hesap oluşturma sayfası
class CreateAccountPage extends ConsumerStatefulWidget {
  final String? accountId; // Düzenleme için ID, null ise yeni oluşturma

  const CreateAccountPage({super.key, this.accountId});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  AccountType _selectedType = AccountType.cash;
  AccountStatus _selectedStatus = AccountStatus.active;
  String _currencyCode = 'TRY';
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.accountId != null) {
      _loadAccountData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ibanController.dispose();
    _swiftCodeController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAccountData() {
    // Mock data loading - gerçek uygulamada provider'dan gelecek
    _nameController.text = 'Ana Nakit Kasa';
    _descriptionController.text = 'Günlük nakit işlemler için ana kasa';
    _currentBalance = 15000.0;
    _selectedType = AccountType.cash;
    _selectedStatus = AccountStatus.active;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      appBar: CustomAppBar(
        title: widget.accountId != null ? 'Hesap Düzenle' : 'Yeni Hesap',
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: _saveAccount,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      drawer: const TamgaciDrawerMenu(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: TamgaciConstants.paddingMedium(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Temel Bilgiler
              _buildSectionCard(
                'Temel Bilgiler',
                Icons.info_outline,
                [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Hesap Adı',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Hesap adı gereklidir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Açıklama',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedType,
                          label: 'Hesap Türü',
                          items: AccountType.values,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedStatus,
                          label: 'Durum',
                          items: AccountStatus.values,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: TextEditingController(
                              text: _currentBalance.toString()),
                          label: 'Mevcut Bakiye',
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _currentBalance = double.tryParse(value) ?? 0.0;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          value: _currencyCode,
                          label: 'Para Birimi',
                          items: const [
                            {'value': 'TRY', 'label': 'Türk Lirası (TRY)'},
                            {'value': 'USD', 'label': 'Amerikan Doları (USD)'},
                            {'value': 'EUR', 'label': 'Euro (EUR)'},
                          ],
                          onChanged: (value) {
                            setState(() {
                              _currencyCode = value as String;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Banka Bilgileri
              if (_selectedType == AccountType.bank ||
                  _selectedType == AccountType.credit)
                _buildSectionCard(
                  'Banka Bilgileri',
                  Icons.account_balance,
                  [
                    _buildTextField(
                      controller: _bankNameController,
                      label: 'Banka Adı',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _accountNumberController,
                      label: 'Hesap Numarası',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ibanController,
                      label: 'IBAN',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _swiftCodeController,
                      label: 'SWIFT Kodu',
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Kredi Bilgileri
              if (_selectedType == AccountType.credit)
                _buildSectionCard(
                  'Kredi Bilgileri',
                  Icons.credit_card,
                  [
                    _buildTextField(
                      controller: _creditLimitController,
                      label: 'Kredi Limiti',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _interestRateController,
                      label: 'Faiz Oranı (%)',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // İletişim Bilgileri
              _buildSectionCard(
                'İletişim Bilgileri',
                Icons.contact_phone,
                [
                  _buildTextField(
                    controller: _contactPersonController,
                    label: 'İletişim Kişisi',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: 'Telefon',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _contactEmailController,
                    label: 'E-posta',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adres',
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(TamgaciConstants.radiusMD),
                    ),
                  ),
                  child: Text(
                    widget.accountId != null
                        ? 'Hesabı Güncelle'
                        : 'Hesabı Kaydet',
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

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: TamgaciConstants.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required String label,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        ),
      ),
      items: items.map((item) {
        String displayName;
        if (item is AccountType) {
          displayName = item.displayName;
        } else if (item is AccountStatus) {
          displayName = item.displayName;
        } else if (item is Map<String, String>) {
          displayName = (item as Map<String, String>)['label']!;
        } else {
          displayName = item.toString();
        }

        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayName),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      // Form validation passed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Başarılı'),
          content: Text(
            widget.accountId != null
                ? 'Hesap başarıyla güncellendi!'
                : 'Hesap başarıyla oluşturuldu!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }
}
