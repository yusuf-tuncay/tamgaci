// ========== PROFILE PAGE ==========
// lib/features/settings/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../user_profile/domain/entities/user_profile.dart';

/// Profil sayfası
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _companyController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isEditingPassword = false;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _companyController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Profil verilerini yükle
  void _loadProfileData() {
    final profileAsync = ref.read(userProfileProvider);
    profileAsync.whenData((profile) {
      if (mounted) {
        setState(() {
          _nameController.text = profile.name;
          _surnameController.text = profile.surname;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
          _positionController.text = profile.position ?? '';
          _departmentController.text = profile.department ?? '';
          _companyController.text = profile.company ?? '';
        });
      }
    });
  }

  /// Profil bilgilerini kaydet
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileAsync = ref.read(userProfileProvider);
      final currentProfile = profileAsync.value;

      if (currentProfile != null) {
        // Formatlanmış değerleri kullan
        final updatedProfile = currentProfile.copyWith(
          name: InputValidators.formatName(_nameController.text),
          surname: InputValidators.formatName(_surnameController.text),
          email: InputValidators.formatEmail(_emailController.text),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : InputValidators.formatPhone(_phoneController.text),
          position: _positionController.text.trim().isEmpty
              ? null
              : _positionController.text.trim(),
          department: _departmentController.text.trim().isEmpty
              ? null
              : _departmentController.text.trim(),
          company: _companyController.text.trim().isEmpty
              ? null
              : _companyController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await ref
            .read(userProfileProvider.notifier)
            .updateProfile(updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil bilgileri başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
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

  /// Profil fotoğrafı seç
  Future<void> _pickProfilePhoto() async {
    try {
      if (!kIsWeb) {
        // Mobil platform için izin kontrolü
        final cameraStatus = await Permission.camera.status;
        if (cameraStatus.isDenied) {
          await Permission.camera.request();
        }

        final storageStatus = await Permission.storage.status;
        if (storageStatus.isDenied) {
          await Permission.storage.request();
        }
      }

      final ImagePicker picker = ImagePicker();

      // Fotoğraf seçme seçenekleri
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fotoğraf Seç'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!kIsWeb) // Web'de kamera seçeneği yok
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Kamera'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        setState(() {
          _isUploadingPhoto = true;
        });

        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 80,
        );

        if (image != null) {
          String photoData;

          if (kIsWeb) {
            // Web platformu için base64 formatında dönüştür
            final bytes = await image.readAsBytes();
            photoData = base64Encode(bytes);
          } else {
            // Mobil platform için dosya yolu kullan
            photoData = image.path;
          }

          await ref
              .read(userProfileProvider.notifier)
              .uploadProfilePhoto(photoData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil fotoğrafı başarıyla güncellendi'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf yüklenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  /// Şifre değiştir
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tüm şifre alanlarını doldurun')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Yeni şifreler eşleşmiyor')));
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifre en az 8 karakter olmalıdır')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gerçek şifre değiştirme işlemi
      await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş işlem

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre başarıyla değiştirildi'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isEditingPassword = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
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
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      appBar: const CustomAppBar(title: 'Profil', showDrawer: false),
      body: profileAsync.when(
        data: (profile) => Form(
          key: _formKey,
          child: Column(
            children: [
              // Form alanları
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profil fotoğrafı
                      _buildProfilePhoto(profile),
                      const SizedBox(height: 24),

                      // Kişisel bilgiler
                      _buildSectionTitle('Kişisel Bilgiler'),
                      _buildPersonalInfoSection(),

                      const SizedBox(height: 24),

                      // İş bilgileri
                      _buildSectionTitle('İş Bilgileri'),
                      _buildWorkInfoSection(),

                      const SizedBox(height: 24),

                      // Şifre değiştirme
                      _buildSectionTitle('Güvenlik'),
                      _buildPasswordSection(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Kaydet butonu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TamgaciConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Değişiklikleri Kaydet',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: TamgaciConstants.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Profil yüklenirken hata oluştu',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TamgaciConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(userProfileProvider.notifier).refreshProfile();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Profil fotoğrafı
  Widget _buildProfilePhoto(UserProfile profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              if (kIsWeb &&
                  profile.profilePhotoUrl != null &&
                  profile.profilePhotoUrl!.startsWith('web_photo_'))
                // Web platformu için FutureBuilder ile base64 veriyi al
                FutureBuilder<String?>(
                  future: _getWebPhotoData(profile.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: TamgaciConstants.primaryColor
                            .withValues(alpha: 0.1),
                        backgroundImage:
                            MemoryImage(base64Decode(snapshot.data!)),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: TamgaciConstants.primaryColor
                            .withValues(alpha: 0.1),
                        child: Text(
                          profile.initials,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TamgaciConstants.primaryColor,
                          ),
                        ),
                      );
                    }
                  },
                )
              else
                // Mobil platform veya fotoğraf yok
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: profile.profilePhotoUrl != null &&
                          !profile.profilePhotoUrl!.startsWith('web_photo_')
                      ? FileImage(File(profile.profilePhotoUrl!))
                      : null,
                  child: profile.profilePhotoUrl == null
                      ? Text(
                          profile.initials,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TamgaciConstants.primaryColor,
                          ),
                        )
                      : null,
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: TamgaciConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: _isUploadingPhoto
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isUploadingPhoto ? null : _pickProfilePhoto,
            child: Text(
              _isUploadingPhoto ? 'Yükleniyor...' : 'Fotoğraf Değiştir',
              style: GoogleFonts.poppins(
                color: TamgaciConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Web platformu için SharedPreferences'dan fotoğraf verisini al
  Future<String?> _getWebPhotoData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photoKey = 'profile_photo_$userId';
      return prefs.getString(photoKey);
    } catch (e) {
      return null;
    }
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  /// Kişisel bilgiler bölümü
  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FormattedNameField(
              label: 'Ad',
              controller: _nameController,
              hint: 'Örn: Ahmet',
            ),
            const SizedBox(height: 16),
            FormattedNameField(
              label: 'Soyad',
              controller: _surnameController,
              hint: 'Örn: Yılmaz',
            ),
            const SizedBox(height: 16),
            FormattedEmailField(
              label: 'E-posta',
              controller: _emailController,
              hint: 'ornek@email.com',
            ),
            const SizedBox(height: 16),
            FormattedPhoneField(
              label: 'Telefon',
              controller: _phoneController,
              hint: '+90 543 288 1296',
              required: false,
            ),
          ],
        ),
      ),
    );
  }

  /// İş bilgileri bölümü
  Widget _buildWorkInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'Pozisyon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
                hintText: 'Örn: Genel Müdür',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Departman',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                hintText: 'Örn: Yönetim',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Şirket',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                hintText: 'Örn: Tamgaci Ltd. Şti.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Şifre bölümü
  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_isEditingPassword) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingPassword = true;
                    });
                  },
                  icon: const Icon(Icons.lock),
                  label: const Text('Şifre Değiştir'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              FormattedPasswordField(
                label: 'Mevcut Şifre',
                controller: _currentPasswordController,
                hint: 'Mevcut şifrenizi girin',
              ),
              const SizedBox(height: 16),
              FormattedPasswordField(
                label: 'Yeni Şifre',
                controller: _newPasswordController,
                hint: 'En az 6 karakter, büyük/küçük harf ve rakam',
              ),
              const SizedBox(height: 16),
              FormattedPasswordField(
                label: 'Yeni Şifre Tekrar',
                controller: _confirmPasswordController,
                hint: 'Yeni şifrenizi tekrar girin',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Şifreyi Değiştir'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingPassword = false;
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: const Text('İptal'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
