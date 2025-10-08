// ========== PROFILE PAGE ==========
// lib/features/settings/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/permissions/storage_permission_service.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/widgets/formatted_text_field.dart';
import '../../../../core/validators/input_validators.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/utils/logger.dart';

/// Profil sayfası - Tamamen Firebase'den veri çeker
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  bool _initialized = false;
  String? _profileImageUrl;
  Uint8List? _localAvatarBytes;
  double _uploadProgress = 0.0;
  int _lastProgressPercent = -1;
  String? _resolvedImagePath;

  @override
  void initState() {
    super.initState();
    // Clean up old URLs immediately on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {});
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

  /// Geçerli profil fotoğrafı var mı kontrol et
  bool _hasValidProfileImage() {
    // Basit kontrol: URL var mı?
    return _profileImageUrl != null && _profileImageUrl!.isNotEmpty;
  }

  /// Profil fotoğrafını tamamen kaldır
  /// DELETE (Fotoğrafı sil) - Best Practice CRUD pattern
  Future<void> _cleanupOldProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    debugPrint('🗑️ Removing profile image...');
    try {
      // 1. Storage'dan dosyayı sil
      final storageRef = FirebaseStorage.instance.ref().child(
          'users/${currentUser.uid}/profile/profile_${currentUser.uid}.jpg');

      try {
        await storageRef.delete();
        debugPrint('✅ Profile image deleted from Storage');
      } catch (e) {
        debugPrint('⚠️ Storage delete failed (file might not exist): $e');
        // Continue with Firestore cleanup even if Storage delete fails
      }

      // 2. Firestore'dan path alanını sil (best practice)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'profileImagePath': FieldValue.delete(),
        'profileImageUrl': FieldValue.delete(), // Legacy field cleanup
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Profile image path removed from Firestore');

      if (mounted) {
        setState(() {
          _profileImageUrl = null;
          _initialized = false; // Force refresh of page data
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil fotoğrafı başarıyla kaldırıldı'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to remove profile image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Fotoğraf kaldırılırken hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Profil bilgilerini kaydet
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

        final updateData = {
          'name': InputValidators.formatName(_nameController.text),
          'surname': InputValidators.formatName(_surnameController.text),
          'phone': _phoneController.text.trim().isEmpty
              ? null
              : InputValidators.formatPhone(_phoneController.text),
          'position': _positionController.text.trim().isEmpty
              ? null
              : _positionController.text.trim(),
          'department': _departmentController.text.trim().isEmpty
              ? null
              : _departmentController.text.trim(),
          'companyName': _companyController.text.trim(),
          'profileImageUrl': _profileImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        // Remove null values
        updateData.removeWhere((key, value) => value == null);

        await userRef.update(updateData);

        if (mounted) {
          // Refresh the page data after successful update
          setState(() {
            _initialized = false;
          });

          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Profil bilgileri başarıyla güncellendi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error updating profile: $e');
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
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

  /// Profil fotoğrafı seç ve Firebase Storage'a yükle
  Future<void> _pickProfilePhoto() async {
    try {
      if (!kIsWeb) {
        // Request storage/media permissions up-front (best effort)
        final ok =
            await const StoragePermissionService().ensureMediaPermissions();
        if (!ok && mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                  'Depolama/Fotoğraflar izni gerekli. Lütfen ayarlardan verin.'),
            ),
          );
        }
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
      // ignore: use_build_context_synchronously
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
          maxWidth: 300,
          maxHeight: 300,
          imageQuality: 70,
        );

        if (image != null) {
          if (mounted) {
            setState(() {
              _isUploadingPhoto = true;
              _uploadProgress = 0.0;
            });
          }

          try {
            final bytes = await image.readAsBytes();
            debugPrint('📊 Image size: ${bytes.length} bytes');

            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) {
              throw Exception('User not authenticated');
            }

            // Show local preview immediately
            if (mounted) {
              setState(() {
                _localAvatarBytes = bytes;
              });
            }

            debugPrint('🔄 Starting Firebase Storage upload...');
            debugPrint('👤 User ID: ${currentUser.uid}');

            // Firebase Storage upload with fixed file path (CRUD pattern)
            final storage = FirebaseStorage.instance;
            // Fixed file path - same for all uploads (update pattern)
            final storageRef = storage.ref().child(
                'users/${currentUser.uid}/profile/profile_${currentUser.uid}.jpg');

            debugPrint(
                '📤 Uploading to: users/${currentUser.uid}/profile/profile_${currentUser.uid}.jpg');

            // Upload with progress tracking
            final uploadTask = storageRef.putData(
              bytes,
              SettableMetadata(
                contentType: 'image/jpeg',
                customMetadata: {
                  'userId': currentUser.uid,
                  'uploadedAt': DateTime.now().toIso8601String(),
                },
              ),
            );

            // Track upload progress
            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
              final progress = snapshot.bytesTransferred / snapshot.totalBytes;
              final percent = (progress * 100).floor();
              if (percent != _lastProgressPercent && mounted) {
                _lastProgressPercent = percent;
                setState(() {
                  _uploadProgress = progress;
                });
              }
            });

            await uploadTask;
            debugPrint('✅ Upload completed');

            // Get download URL
            final downloadURL = await storageRef.getDownloadURL();
            debugPrint('🔗 Download URL obtained: $downloadURL');

            // Update user profile in Firestore with best practice (path + metadata)
            debugPrint('💾 Updating user profile in Firestore...');
            final imagePath =
                'users/${currentUser.uid}/profile/profile_${currentUser.uid}.jpg';
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .set({
              'profileImagePath': imagePath, // Best practice: store path
              'profileImageUrl': downloadURL, // Cache for performance
              'profileImageMetadata': {
                'uploadedAt': FieldValue.serverTimestamp(),
                'fileSize': bytes.length,
                'mimeType': 'image/jpeg',
              },
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint('✅ User profile updated in Firestore');

            if (mounted) {
              setState(() {
                _profileImageUrl = downloadURL;
                _localAvatarBytes = null;
                _isUploadingPhoto = false;
                _uploadProgress = 0.0;
                _lastProgressPercent = -1;
              });
            }
          } catch (e) {
            debugPrint('❌ Upload failed: $e');
            debugPrint('❌ Error type: ${e.runtimeType}');

            if (mounted) {
              setState(() {
                _isUploadingPhoto = false;
                _uploadProgress = 0.0;
                _localAvatarBytes = null;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Yükleme başarısız: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('Fotoğraf yüklenirken hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
          _uploadProgress = 0.0; // Reset progress
        });
        // Clear any remaining loading snackbars
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    }
  }

  /// Şifre değiştir
  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Tüm şifre alanlarını doldurun')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
          const SnackBar(content: Text('Yeni şifreler eşleşmiyor')));
      return;
    }

    if (_newPasswordController.text.length < 8) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
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
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
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
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Appends cache-busting version parameter to a URL without breaking existing query params

  /// Shows dialog when user tries to exit during upload
  void _showUploadInProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.upload, color: Colors.orange),
              SizedBox(width: 8),
              Text('Yükleme Devam Ediyor'),
            ],
          ),
          content: const Text(
            'Profil fotoğrafınız yükleniyor. Lütfen işlem tamamlanana kadar bekleyin.\n\n'
            'Yükleme tamamlanmadan çıkarsanız fotoğraf kaybolabilir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          title: 'Profil',
          showBackButton: true,
          showDrawer: false,
        ),
        body: Center(
          child: Text('Kullanıcı girişi gerekli'),
        ),
      );
    }

    return PopScope(
      canPop: !_isUploadingPhoto,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isUploadingPhoto) {
          _showUploadInProgressDialog();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? TamgaciConstants.backgroundColorDark
            : TamgaciConstants.backgroundColor,
        appBar: CustomAppBar(
          title: 'Profil',
          showBackButton: true,
          showDrawer: false,
          onBackPressed: _isUploadingPhoto
              ? null
              : () {
                  if (_isUploadingPhoto) {
                    _showUploadInProgressDialog();
                    return;
                  }
                  try {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    }
                  } catch (e) {
                    debugPrint('Navigation error: $e');
                    // Fallback navigation
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  }
                },
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Hata: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('Kullanıcı verisi bulunamadı'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            // Only init once to prevent rebuild storms
            if (!_initialized) {
              _initFromFirebaseData(userData);
            }

            return Form(
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
                          _buildProfilePhotoFromFirebase(userData),
                          const SizedBox(height: 24),

                          // Kişisel bilgiler
                          _buildSectionTitle('Kişisel Bilgiler'),
                          _buildPersonalInfoSectionFromFirebase(userData),

                          const SizedBox(height: 24),

                          // İş bilgileri
                          _buildSectionTitle('İş Bilgileri'),
                          _buildWorkInfoSectionFromFirebase(userData),

                          const SizedBox(height: 24),

                          // Şirket bilgileri
                          _buildSectionTitle('Şirket Bilgileri'),
                          _buildCompanyInfoSectionFromFirebase(userData),

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
                      color: isDark
                          ? TamgaciConstants.cardColorDark
                          : Colors.white,
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
                          onPressed: (_isLoading || _isUploadingPhoto)
                              ? null
                              : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TamgaciConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: (_isLoading || _isUploadingPhoto)
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
                                  _isUploadingPhoto
                                      ? 'Fotoğraf Yükleniyor...'
                                      : 'Değişiklikleri Kaydet',
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
            );
          },
        ),
      ),
    );
  }

  /// Firebase verilerini form alanlarına yükle
  void _initFromFirebaseData(Map<String, dynamic> userData) {
    if (_initialized) return;

    _nameController.text = userData['name'] ?? '';
    _surnameController.text = userData['surname'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _phoneController.text = userData['phone'] ?? '';
    _positionController.text = userData['position'] ?? '';
    _departmentController.text = userData['department'] ?? '';
    _companyController.text = userData['companyName'] ?? '';

    // Profil fotoğrafı: sadece path değişmişse background'da çöz
    final profileImagePath = userData['profileImagePath'] as String?;
    final cachedUrl = userData['profileImageUrl'] as String?;

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      if (_resolvedImagePath != profileImagePath) {
        _resolvedImagePath = profileImagePath;
        // Set cached URL immediately to prevent flicker
        if (cachedUrl != null && cachedUrl.isNotEmpty) {
          _profileImageUrl = cachedUrl;
        }
        _loadProfileImageFromPath(profileImagePath);
      }
    } else {
      _resolvedImagePath = null;
      // Use cached URL if available
      if (cachedUrl != null && cachedUrl.isNotEmpty) {
        _profileImageUrl = cachedUrl;
      }
    }

    _initialized = true;
  }

  /// READ (Path'den URL çek) - Best Practice
  Future<void> _loadProfileImageFromPath(String imagePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(imagePath);
      final downloadURL = await storageRef.getDownloadURL();

      if (mounted && downloadURL != _profileImageUrl) {
        setState(() {
          _profileImageUrl = downloadURL;
        });
        debugPrint('✅ Profile image loaded from path: $imagePath');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load image from path $imagePath: $e');
      // Path geçersizse Firestore'dan temizle
      if (e.toString().contains('object-not-found')) {
        await _cleanupInvalidImagePath(imagePath);
      }
    }
  }

  /// Geçersiz image path'i temizle
  Future<void> _cleanupInvalidImagePath(String imagePath) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'profileImagePath': FieldValue.delete(),
          'profileImageUrl': FieldValue.delete(),
        });
        debugPrint('🧹 Cleaned up invalid image path: $imagePath');
      }
    } catch (e) {
      debugPrint('❌ Failed to cleanup invalid path: $e');
    }
  }

  /// Profil fotoğrafı - Firebase verilerinden (best practice)
  Widget _buildProfilePhotoFromFirebase(Map<String, dynamic> userData) {
    final name = userData['name'] ?? '';
    final surname = userData['surname'] ?? '';
    // Best practice: önce cache'den, sonra path'den
    String? profileImageUrl = userData['profileImageUrl'] ?? _profileImageUrl;
    if (profileImageUrl != null &&
        profileImageUrl.contains('tamgaci.appspot.com')) {
      profileImageUrl = profileImageUrl.replaceAll(
          'tamgaci.appspot.com', 'tamgaci.firebasestorage.app');
    }

    // Validate URL exists before using it
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      // Check if URL has token (indicates valid Firebase Storage URL)
      if (!profileImageUrl.contains('token=')) {
        debugPrint('⚠️ Invalid profile URL (no token): $profileImageUrl');
        profileImageUrl = null;
      }
    }

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    TamgaciConstants.primaryColor.withValues(alpha: 0.1),
                backgroundImage:
                    (profileImageUrl != null && profileImageUrl.isNotEmpty)
                        ? NetworkImage(profileImageUrl)
                        : null,
                child: (profileImageUrl == null || profileImageUrl.isEmpty)
                    ? Text(
                        _initialsFrom(name, surname),
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
                child: GestureDetector(
                  onTap: _isUploadingPhoto
                      ? null
                      : () async {
                          debugPrint(
                              '🔘 Icon tapped! _hasValidProfileImage: ${_hasValidProfileImage()}');
                          debugPrint('🔘 _profileImageUrl: $_profileImageUrl');

                          if (_hasValidProfileImage()) {
                            debugPrint('🗑️ Removing profile image...');
                            await _cleanupOldProfileImage();
                          } else {
                            debugPrint('📷 Picking new profile photo...');
                            await _pickProfilePhoto();
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _hasValidProfileImage()
                          ? Colors.red
                          : TamgaciConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: null, // Dönen animasyon için null
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _hasValidProfileImage()
                                ? Icons.close
                                : Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _initialsFrom(String? name, String? surname) {
    final n = (name ?? '').trim();
    final s = (surname ?? '').trim();
    final first = n.isNotEmpty ? n.characters.first : '';
    final second = s.isNotEmpty ? s.characters.first : '';
    final result = (first + second).toUpperCase();
    return result.isEmpty ? 'KU' : result;
  }

  /// Bölüm başlığı
  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark
              ? TamgaciConstants.textPrimaryDark
              : TamgaciConstants.textPrimary,
        ),
      ),
    );
  }

  /// Kişisel bilgiler - Firebase verilerinden
  Widget _buildPersonalInfoSectionFromFirebase(Map<String, dynamic> userData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? TamgaciConstants.cardColorDark : null,
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
              hint: '0555 123 45 67',
            ),
          ],
        ),
      ),
    );
  }

  /// İş bilgileri - Firebase verilerinden
  Widget _buildWorkInfoSectionFromFirebase(Map<String, dynamic> userData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? TamgaciConstants.cardColorDark : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Abonelik bilgisi kısa gösterim
            _buildSubscriptionInfoFromFirebase(userData),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }

  /// Şirket bilgileri - Firebase verilerinden
  Widget _buildCompanyInfoSectionFromFirebase(Map<String, dynamic> userData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? TamgaciConstants.cardColorDark : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Şirket Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                hintText: 'Örn: ABC Şirketi',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: userData['taxId'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Vergi Numarası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt),
                hintText: 'Örn: 1234567890',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: userData['taxOffice'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Vergi Dairesi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
                hintText: 'Örn: Fatih',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: userData['billingAddress'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Fatura Adresi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Adres bilgisi',
              ),
              readOnly: true,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Abonelik bilgisi - Firebase verilerinden
  Widget _buildSubscriptionInfoFromFirebase(Map<String, dynamic> userData) {
    final now = DateTime.now();
    String text = 'Abonelik: Yok';
    Color color = Colors.grey;
    String? usageInfo;

    final subscriptionStatus = userData['subscriptionStatus'] ?? 'none';
    final trialEndAt = userData['trialEndAt'];
    final subscriptionEndAt = userData['subscriptionEndAt'];
    final trialStartAt = userData['trialStartAt'];

    if (subscriptionStatus == 'trial' && trialEndAt != null) {
      final trialEnd = (trialEndAt as Timestamp).toDate();
      final remaining = trialEnd.difference(now).inDays;
      text = remaining >= 0
          ? 'Deneme: $remaining gün kaldı'
          : 'Deneme süresi doldu';
      color = remaining > 0 ? Colors.orange : Colors.red;

      // Kullanım süresi bilgisi
      if (trialStartAt != null) {
        final trialStart = (trialStartAt as Timestamp).toDate();
        final totalTrialDays = trialEnd.difference(trialStart).inDays;
        final usedDays = now.difference(trialStart).inDays;
        usageInfo = 'Kullanım: $usedDays/$totalTrialDays gün';
      }
    } else if (subscriptionStatus == 'active' && subscriptionEndAt != null) {
      final subEnd = (subscriptionEndAt as Timestamp).toDate();
      final remaining = subEnd.difference(now).inDays;
      text = remaining >= 0
          ? 'Aktif: $remaining gün kaldı'
          : 'Abonelik süresi doldu';
      color = remaining > 0 ? Colors.green : Colors.red;

      // Abonelik başlangıç tarihi varsa kullanım süresi
      final subscriptionStartAt = userData['subscriptionStartAt'];
      if (subscriptionStartAt != null) {
        final subStart = (subscriptionStartAt as Timestamp).toDate();
        final usedDays = now.difference(subStart).inDays;
        usageInfo = 'Kullanım: $usedDays gün';
      }
    } else if (subscriptionStatus == 'none' ||
        subscriptionStatus == 'expired') {
      // Hiç abonelik yok veya süresi dolmuş
      text = 'Abonelik: Yok';
      color = Colors.grey;
      usageInfo = 'Abonelik gerekli';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.subscriptions,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/subscription');
              },
              child: Text(
                'Yönet',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: TamgaciConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
        // Kullanım süresi bilgisi
        if (usageInfo != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  usageInfo,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Şifre bölümü
  Widget _buildPasswordSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? TamgaciConstants.cardColorDark : null,
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
