import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/company_info.dart';
import '../providers/company_providers.dart';
import 'package:tamgaci/features/auth/presentation/providers/auth_providers.dart';
import 'package:tamgaci/core/services/tenant_service.dart';
import '../../../../core/theme/constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';

/// Firma bilgileri ayarlar sayfası
class CompanySettingsPage extends ConsumerStatefulWidget {
  const CompanySettingsPage({super.key});

  @override
  ConsumerState<CompanySettingsPage> createState() =>
      _CompanySettingsPageState();
}

class _CompanySettingsPageState extends ConsumerState<CompanySettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveCompanyInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Tenant ID ve User ID'yi al
      final tenantService = TenantService();
      final tenantId = await tenantService.getUserTenantId();
      final user = ref.read(currentUserProvider);

      final companyInfo = CompanyInfo(
        id: '',
        tenantId: tenantId,
        createdBy: user?.id,
        name: _nameController.text,
        taxNumber: _taxNumberController.text.isNotEmpty
            ? _taxNumberController.text
            : null,
        taxOffice: _taxOfficeController.text.isNotEmpty
            ? _taxOfficeController.text
            : null,
        address:
            _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        district: _districtController.text.isNotEmpty
            ? _districtController.text
            : null,
        postalCode: _postalCodeController.text.isNotEmpty
            ? _postalCodeController.text
            : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        website:
            _websiteController.text.isNotEmpty ? _websiteController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final useCase = ref.read(saveCompanyInfoUseCaseProvider);
      await useCase.call(companyInfo);

      // Provider'ı refresh et
      ref.read(companyInfoRefreshProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Firma bilgileri başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
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

  @override
  Widget build(BuildContext context) {
    // Company info'yu yükle
    final companyInfoAsync = ref.watch(companyInfoWithRefreshProvider);
    // User bilgilerini yükle (register esnasında girilen bilgiler)
    final user = ref.watch(currentUserProvider);

    // Company info varsa onu kullan, yoksa user settings'ten al
    companyInfoAsync.when(
      data: (companyInfo) {
        if (companyInfo != null && mounted) {
          // Company info varsa onu kullan
          _nameController.text = companyInfo.name;
          _taxNumberController.text = companyInfo.taxNumber ?? '';
          _taxOfficeController.text = companyInfo.taxOffice ?? '';
          _addressController.text = companyInfo.address ?? '';
          _cityController.text = companyInfo.city ?? '';
          _districtController.text = companyInfo.district ?? '';
          _postalCodeController.text = companyInfo.postalCode ?? '';
          _phoneController.text = companyInfo.phone ?? '';
          _emailController.text = companyInfo.email ?? '';
          // Website controller'ı sadece boşsa doldur
          if (_websiteController.text.isEmpty) {
            _websiteController.text = companyInfo.website ?? '';
          }
        } else if (user != null && mounted) {
          // Company info yoksa user settings'ten register bilgilerini kullan
          final settings = user.settings;
          if (settings != null) {
            // Form alanlarını doldur
            _nameController.text =
                settings['companyName'] ?? settings['businessName'] ?? '';
            _taxNumberController.text = settings['taxId'] ?? '';
            _taxOfficeController.text = settings['taxOffice'] ?? '';
            _addressController.text = settings['billingAddress'] ?? '';

            // Address bilgilerini parse et
            final address = settings['address'] as Map<String, dynamic>?;
            if (address != null) {
              _cityController.text = address['city'] ?? '';
              _districtController.text = address['district'] ?? '';
              _postalCodeController.text = address['postalCode'] ?? '';
            }

            _phoneController.text = user.phone ?? '';
            _emailController.text = user.email;
            _websiteController.text = '';
          }
        }
      },
      loading: () {},
      error: (error, stack) {},
    );

    return ResponsiveScaffold(
      appBar: const CustomAppBar(
        title: 'Firma Bilgileri',
        showBackButton: true,
      ),
      drawerContent: const SizedBox.shrink(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Firma Adı *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Firma adı gerekli';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _taxNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Vergi No',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _taxOfficeController,
                              decoration: const InputDecoration(
                                labelText: 'Vergi Dairesi',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adres Bilgileri',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Adres',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'Şehir',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _districtController,
                              decoration: const InputDecoration(
                                labelText: 'İlçe',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Posta Kodu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefon',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'E-posta',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Web Sitesi',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Website field changed
                        },
                        onTap: () {
                          // Website field tapped
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCompanyInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Kaydet',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
