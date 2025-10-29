import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/company_info.dart';
import '../providers/company_providers.dart';
import 'package:tamgaci/features/auth/presentation/providers/auth_providers.dart';
import 'package:tamgaci/core/services/tenant_service.dart';
import 'package:tamgaci/core/services/storage/company_logo_service.dart';
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
  bool _isUploadingLogo = false;
  String? _currentLogoUrl;
  Uint8List? _localLogoBytes;

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

  /// Logo seç ve yükle
  Future<void> _pickAndUploadLogo() async {
    try {
      final CompanyLogoService logoService = CompanyLogoService();
      final ImagePicker picker = ImagePicker();

      // Galeriden logo seç
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploadingLogo = true;
        });

        try {
          String logoUrl;

          if (kIsWeb) {
            // Web için bytes kullan
            final bytes = await image.readAsBytes();
            setState(() {
              _localLogoBytes = bytes;
            });
            logoUrl = await logoService.uploadCompanyLogoBytes(bytes);
          } else {
            // Mobil için file kullan
            final file = File(image.path);
            logoUrl = await logoService.uploadCompanyLogo(file);
          }

          setState(() {
            _currentLogoUrl = logoUrl;
            _isUploadingLogo = false;
          });

          // Logo yüklendikten sonra hemen company bilgilerini güncelle
          debugPrint('🔄 Logo URL Firebase\'e kaydediliyor: $logoUrl');
          await _updateCompanyLogoInFirebase(logoUrl);
          debugPrint('✅ Logo URL Firebase\'e kaydedildi');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Logo başarıyla yüklendi ve kaydedildi'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          setState(() {
            _isUploadingLogo = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logo yüklenirken hata: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logo seçilirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Logo sil
  Future<void> _deleteLogo() async {
    if (_currentLogoUrl == null) return;

    try {
      final CompanyLogoService logoService = CompanyLogoService();
      await logoService.deleteCompanyLogo(_currentLogoUrl!);

      // Firebase'deki company bilgilerinden de logo URL'sini kaldır
      await _updateCompanyLogoInFirebase('');

      setState(() {
        _currentLogoUrl = null;
        _localLogoBytes = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo silindi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logo silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Placeholder logo widget
  Widget _buildPlaceholderLogo() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Logo Yok',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Logo URL'sini Firebase'deki company bilgilerine kaydet
  Future<void> _updateCompanyLogoInFirebase(String logoUrl) async {
    try {
      debugPrint('🔄 Company info güncelleniyor...');
      // Mevcut company bilgilerini al
      final companyInfoAsync = ref.read(companyInfoWithRefreshProvider);

      await companyInfoAsync.when(
        data: (companyInfo) async {
          if (companyInfo != null) {
            debugPrint(
                '📝 Mevcut company info güncelleniyor: ${companyInfo.name}');
            // Mevcut company bilgilerini güncelle
            final updatedCompanyInfo = companyInfo.copyWith(
              logoUrl: logoUrl.isEmpty ? null : logoUrl,
              updatedAt: DateTime.now(),
            );

            // Firebase'e kaydet
            final useCase = ref.read(saveCompanyInfoUseCaseProvider);
            await useCase.call(updatedCompanyInfo);
            debugPrint('✅ Company info Firebase\'e kaydedildi');

            // Provider'ı refresh et
            ref.read(companyInfoRefreshProvider.notifier).state++;
            debugPrint('🔄 Provider refresh edildi');
          } else if (logoUrl.isNotEmpty) {
            debugPrint('📝 Yeni company info oluşturuluyor...');
            // Company info yoksa ve logo varsa yeni oluştur
            final tenantService = TenantService();
            final tenantId = await tenantService.getUserTenantId();
            final user = ref.read(currentUserProvider);

            final newCompanyInfo = CompanyInfo(
              id: '',
              tenantId: tenantId,
              createdBy: user.value?.id,
              name: _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Firma Adı',
              logoUrl: logoUrl,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final useCase = ref.read(saveCompanyInfoUseCaseProvider);
            await useCase.call(newCompanyInfo);
            debugPrint('✅ Yeni company info Firebase\'e kaydedildi');

            // Provider'ı refresh et
            ref.read(companyInfoRefreshProvider.notifier).state++;
            debugPrint('🔄 Provider refresh edildi');
          }
        },
        loading: () async {
          debugPrint('⏳ Company info yükleniyor...');
          // Loading durumunda bekle
        },
        error: (error, stack) async {
          debugPrint('❌ Company info yüklenirken hata: $error');
        },
      );
    } catch (e) {
      debugPrint('❌ Logo Firebase\'e kaydedilirken hata: $e');
      // Hata olsa bile devam et, kullanıcıya bildir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logo kaydedilirken hata: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
        createdBy: user.value?.id,
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
        logoUrl: _currentLogoUrl,
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
          // Logo URL'yi set et
          _currentLogoUrl = companyInfo.logoUrl;
        } else if (user.value != null && mounted) {
          // Company info yoksa user settings'ten register bilgilerini kullan
          final settings = user.value!.settings;
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

            _phoneController.text = user.value!.phone ?? '';
            _emailController.text = user.value!.email;
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
                        'Firma Logosu',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            // Logo gösterimi
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _currentLogoUrl != null ||
                                        _localLogoBytes != null
                                    ? kIsWeb && _localLogoBytes != null
                                        ? Image.memory(
                                            _localLogoBytes!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return _buildPlaceholderLogo();
                                            },
                                          )
                                        : _currentLogoUrl != null
                                            ? Image.network(
                                                _currentLogoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return _buildPlaceholderLogo();
                                                },
                                              )
                                            : _buildPlaceholderLogo()
                                    : _buildPlaceholderLogo(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Logo yükleme butonları
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _isUploadingLogo
                                      ? null
                                      : _pickAndUploadLogo,
                                  icon: _isUploadingLogo
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.upload),
                                  label: Text(
                                    _isUploadingLogo
                                        ? 'Yükleniyor...'
                                        : 'Logo Yükle',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                if (_currentLogoUrl != null ||
                                    _localLogoBytes != null) ...[
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: _deleteLogo,
                                    icon: const Icon(Icons.delete),
                                    label: Text(
                                      'Sil',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Önerilen boyut: 200x200 px\nDesteklenen formatlar: JPG, PNG',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
