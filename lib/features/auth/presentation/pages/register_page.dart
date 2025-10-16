// ========== REGISTER PAGE ==========
// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/auth_providers.dart';
import '../../../../shared/widgets/privacy_policy_dialog.dart';
// Silinen modül: user_profile
import '../../domain/entities/user.dart';

/// Kayıt olma sayfası
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _addressController = TextEditingController();
  // Address detail controllers
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingNoController = TextEditingController();
  final _apartmentNoController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Profile image
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _avatarBytes;
  File? _profileImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final bool _isPasswordVisible = false;
  final bool _isConfirmPasswordVisible = false;
  final bool _acceptTerms = false;
  final bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isRegistering = false;

  // Banner state
  bool _showBanner = true;

  // Phone area code (country calling code) state
  String _selectedDialCode = '+90';
  String _selectedCountry = 'TR';

  // country_picker paketini kullanarak tüm ülkeler ve alan kodları gösterilecek
  // Address/location data
  List<String> _cities = [];
  Map<String, List<String>> _districtsByCity = {};
  Map<String, List<String>> _taxOfficesByDistrict = {};
  List<String> _allTaxOffices = [];
  String? _selectedCity;
  String? _selectedDistrict;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-detect by locale; try to refine by geolocation asynchronously
    final locale = Localizations.localeOf(context);
    final countryCode = (locale.countryCode ?? 'TR').toUpperCase();
    try {
      final country = Country.parse(countryCode);
      _selectedCountry = country.countryCode;
      _selectedDialCode = '+${country.phoneCode}';
    } catch (_) {
      _selectedCountry = 'TR';
      _selectedDialCode = '+90';
    }
    _detectCountryCode();
    _loadLocationAndTaxData();
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;

    // Check for different character types
    bool hasUppercase = password.contains(RegExp(r'[A-ZÇĞİÖŞÜ]'));
    bool hasLowercase = password.contains(RegExp(r'[a-zçğıöşü]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#\$%^&*()_+\-={}\[\]\\|:;,.<>/?~`]'));

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  Future<void> _loadLocationAndTaxData() async {
    try {
      // Cities and districts from Firestore
      final citiesSnap = await FirebaseFirestore.instance
          .collection('geo_cities')
          .orderBy('name')
          .get();

      final List<String> cities = [];
      final Map<String, List<String>> districtsByCity = {};

      for (final doc in citiesSnap.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString();
        final districts = (data['districts'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList()
          ..sort();
        if (name.isNotEmpty) {
          cities.add(name);
          districtsByCity[name] = districts;
        }
      }

      // Tax offices from Firestore
      final taxDoc = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('tax_offices')
          .get();
      final allOffices = (taxDoc.data()?['names'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      allOffices.sort();

      // Build district->offices mapping by simple contains heuristic
      final Map<String, List<String>> taxByDistrict = {};
      for (final city in cities) {
        final districts = districtsByCity[city] ?? [];
        for (final d in districts) {
          final matches = allOffices
              .where((o) =>
                  o.toUpperCase().contains(d.toUpperCase()) ||
                  o.toUpperCase().contains(city.toUpperCase()))
              .toList()
            ..sort();
          if (matches.isNotEmpty) {
            taxByDistrict[d] = matches;
          }
        }
      }

      if (mounted) {
        setState(() {
          _cities = cities;
          _districtsByCity = districtsByCity;
          _taxOfficesByDistrict = taxByDistrict;
          _allTaxOffices = allOffices;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load geo metadata from Firestore: $e');
    }
  }

  /// Get password strength score (0-4)
  int _getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-ZÇĞİÖŞÜ]'))) score++;
    if (password.contains(RegExp(r'[a-zçğıöşü]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-={}\[\]\\|:;,.<>/?~`]'))) {
      score++;
    }
    return score > 4 ? 4 : score;
  }

  /// Get password strength text and color
  Map<String, dynamic> _getPasswordStrengthInfo(String password) {
    final strength = _getPasswordStrength(password);
    switch (strength) {
      case 0:
      case 1:
        return {'text': 'Çok Zayıf', 'color': Colors.red};
      case 2:
        return {'text': 'Zayıf', 'color': Colors.orange};
      case 3:
        return {'text': 'Orta', 'color': Colors.amber};
      case 4:
        return {'text': 'Güçlü', 'color': Colors.green};
      default:
        return {'text': 'Güçlü', 'color': Colors.green};
    }
  }

  /// Build password strength indicator widget
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    final strengthInfo = _getPasswordStrengthInfo(password);
    final strength = _getPasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Builder(builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                return LinearProgressIndicator(
                  value: strength / 4,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(strengthInfo['color']),
                  minHeight: 4,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              strengthInfo['text'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: strengthInfo['color'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            _buildPasswordCriteria('8+ karakter', password.length >= 8),
            _buildPasswordCriteria(
                'Büyük harf', password.contains(RegExp(r'[A-ZÇĞİÖŞÜ]'))),
            _buildPasswordCriteria(
                'Küçük harf', password.contains(RegExp(r'[a-zçğıöşü]'))),
            _buildPasswordCriteria(
                'Rakam', password.contains(RegExp(r'[0-9]'))),
            _buildPasswordCriteria(
                'Sembol',
                password
                    .contains(RegExp(r'[!@#\$%^&*()_+\-={}[\]\\|:;,.<>/?~`]'))),
          ],
        ),
      ],
    );
  }

  /// Build individual password criteria indicator
  Widget _buildPasswordCriteria(String text, bool isMet) {
    return Builder(builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      final ok = isMet ? Colors.green : scheme.outline;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 12,
            color: ok,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: ok,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _detectCountryCode() async {
    try {
      // Lightweight geolocation-based detection (best-effort)
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final iso = (placemarks.first.isoCountryCode ?? 'TR').toUpperCase();
        final parsed = Country.parse(iso);
        if (mounted) {
          setState(() {
            _selectedCountry = parsed.countryCode;
            _selectedDialCode = '+${parsed.phoneCode}';
          });
        }
      }
    } catch (_) {
      // ignore failures and keep locale-based default
    }
  }

  String _countryFlagEmoji(String countryCode) {
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌐';
    final int first = 0x1F1E6 + (code.codeUnitAt(0) - 65);
    final int second = 0x1F1E6 + (code.codeUnitAt(1) - 65);
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _taxOfficeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _buildingNoController.dispose();
    _apartmentNoController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      // Show picker options
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Text('Fotoğraf işleniyor...'),
                ],
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Compress and process image
        final compressedBytes = await _compressImage(picked);

        if (mounted && compressedBytes != null) {
          setState(() {
            _avatarBytes = compressedBytes;
          });

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final scheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Fotoğraf hazır!',
                  style: TextStyle(color: scheme.onPrimary)),
              backgroundColor: scheme.primary,
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Avatar pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showErrorSnackBar('Fotoğraf seçilirken hata oluştu');
      }
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğraf Seç'),
        content:
            const Text('Profil fotoğrafınızı nereden seçmek istiyorsunuz?'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Kamera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galeri'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  /// Compress image for optimal storage and performance
  Future<Uint8List?> _compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Check file size - if already small, don't compress
      if (bytes.length <= 500 * 1024) {
        // 500KB
        return bytes;
      }

      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minHeight: 512,
        minWidth: 512,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      debugPrint(
          '🗜️ Image compressed: ${bytes.length} → ${compressedBytes.length} bytes');
      return compressedBytes;
    } catch (e) {
      debugPrint('❌ Image compression failed: $e');
      // Return original bytes if compression fails
      return await imageFile.readAsBytes();
    }
  }

  /// Kayıt işlemi
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorSnackBar('Kullanım şartlarını kabul etmelisiniz');
      return;
    }

    // Prevent multiple simultaneous registration attempts
    if (_isRegistering) {
      debugPrint(
          '⚠️ Registration already in progress, ignoring duplicate request');
      return;
    }

    // Input validation
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorSnackBar(validationError);
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _firstNameController.text.trim();
      final surname = _lastNameController.text.trim();
      final localDigits = _phoneController.text.trim();
      final phoneE164 =
          localDigits.isEmpty ? null : '$_selectedDialCode$localDigits';

      // 1. Register user with Firebase Auth (with existing user handling)
      debugPrint('🔄 Starting user registration...');
      User? current;

      try {
        await ref.read(authProvider.notifier).registerWithEmailAndPassword(
              email: email,
              password: password,
              name: name,
              surname: surname,
            );
        debugPrint('✅ Basic registration completed');

        // Get the newly created user
        current = await ref.read(getCurrentUserUseCaseProvider).call();
        if (current == null) {
          throw Exception('Kullanıcı kayıt işlemi tamamlanamadı');
        }
        debugPrint('👤 Got current user: ${current.email}');
      } catch (e) {
        debugPrint(
            '⚠️ Registration failed, checking if user already exists: $e');

        // Check if this is an "email already in use" error
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('email-already-in-use') ||
            errorMessage.contains('email adresi zaten kullanılıyor')) {
          debugPrint('🔍 Attempting to sign in with existing user...');

          // Try to sign in with existing user
          try {
            await ref.read(authProvider.notifier).signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

            current = await ref.read(getCurrentUserUseCaseProvider).call();
            if (current != null) {
              debugPrint('✅ Signed in with existing user: ${current.email}');

              // Check if profile is already completed
              final settings = current.settings ?? <String, dynamic>{};
              final isRegistrationCompleted =
                  settings['registrationCompleted'] == true;

              if (isRegistrationCompleted) {
                debugPrint('⚠️ User registration already completed');
                if (mounted) {
                  _showErrorSnackBar(
                      'Bu hesap zaten mevcut ve tamamlanmış. Giriş sayfasından giriş yapınız.');
                  Navigator.of(context)
                      .pushReplacementNamed(TamgaciRoutes.login);
                }
                return;
              }

              debugPrint('🔄 Continuing registration for existing user...');
            }
          } catch (signInError) {
            debugPrint('❌ Failed to sign in with existing user: $signInError');
            rethrow; // Re-throw the original registration error
          }
        } else {
          rethrow; // Re-throw non-duplicate email errors
        }
      }

      if (current == null) {
        throw Exception('Kullanıcı kayıt işlemi tamamlanamadı');
      }

      // 3. Upload profile image if selected (with retry mechanism)
      String? profileUrl;
      String? profilePath;
      if (_avatarBytes != null) {
        final nonNullCurrent = current; // non-null as ensured above
        debugPrint('📤 Uploading profile image...');
        try {
          try {
            await _testFirebaseStorageSetup();
          } catch (_) {}

          // Try one awaited upload so Firestore has URL before first navigation
          final result = await _uploadProfileImageWithRetry(
              nonNullCurrent.id, _avatarBytes!,
              maxRetries: 2);
          profileUrl = result['url'];
          profilePath = result['path'];
          debugPrint('✅ Profile image uploaded successfully');
          debugPrint('🔗 URL: $profileUrl');
          debugPrint('📁 Path: $profilePath');

          // Persist image data immediately
          final imageUpdate = nonNullCurrent.copyWith(
            profileImageUrl: profileUrl,
            profileImagePath: profilePath,
            settings: {
              ...(nonNullCurrent.settings ?? <String, dynamic>{}),
              'profileImageUrl': profileUrl,
              'profileImagePath': profilePath,
            },
            updatedAt: DateTime.now(),
          );
          await ref.read(authProvider.notifier).updateUserProfile(imageUpdate);
        } catch (e) {
          debugPrint(
              '❌ Immediate upload failed, will continue in background: $e');
          // Fallback: continue in background so we don't block registration
          () async {
            try {
              final result = await _uploadProfileImageWithRetry(
                  nonNullCurrent.id, _avatarBytes!);
              final bgUrl = result['url'];
              final bgPath = result['path'];
              final imageUpdate = nonNullCurrent.copyWith(
                profileImageUrl: bgUrl,
                profileImagePath: bgPath,
                settings: {
                  ...(nonNullCurrent.settings ?? <String, dynamic>{}),
                  'profileImageUrl': bgUrl,
                  'profileImagePath': bgPath,
                },
                updatedAt: DateTime.now(),
              );
              await ref
                  .read(authProvider.notifier)
                  .updateUserProfile(imageUpdate);
              debugPrint('✅ Background upload completed.');
            } catch (err) {
              debugPrint('❌ Background upload failed: $err');
            }
          }();
        }
      }

      // 4. Update user profile with all data
      debugPrint('💾 Updating user profile with complete data...');
      final companyName = _companyNameController.text.trim();
      final taxId = _taxIdController.text.trim();
      final taxOffice = _taxOfficeController.text.trim();
      final billingAddress =
          _addressController.text.trim(); // kept in settings.billingAddress
      final city = _selectedCity ??
          _cityController.text.trim(); // stored under settings.address.city
      final district = _selectedDistrict ??
          _districtController.text
              .trim(); // stored under settings.address.district
      final neighborhood = _neighborhoodController.text.trim();
      final street = _streetController.text.trim();
      final buildingNo = _buildingNoController.text.trim();
      final apartmentNo = _apartmentNoController.text.trim();
      final postalCode = _postalCodeController.text.trim();

      debugPrint('💼 Company data: $companyName');
      debugPrint('🔗 Profile URL: $profileUrl');
      debugPrint('📁 Profile Path: $profilePath');

      final updated = current.copyWith(
        phone: localDigits.isEmpty ? null : localDigits,
        phoneE164: phoneE164,
        phoneCountry: _selectedCountry,
        phoneDialCode: _selectedDialCode,
        profileImageUrl: profileUrl,
        profileImagePath: profilePath,
        taxId: taxId.isEmpty ? null : taxId,
        taxOffice: taxOffice.isEmpty ? null : taxOffice,
        billingAddress: billingAddress.isEmpty ? null : billingAddress,
        settings: {
          ...(current.settings ?? <String, dynamic>{}),
          'companyName': companyName,
          'businessName': companyName, // Alternative field name
          'taxId': taxId,
          'taxOffice': taxOffice,
          'billingAddress': billingAddress,
          'address': {
            'countryCode': _selectedCountry,
            'dialCode': _selectedDialCode,
            'city': city,
            'district': district,
            'neighborhood': neighborhood,
            'street': street,
            'buildingNo': buildingNo,
            'apartmentNo': apartmentNo,
            'postalCode': postalCode,
            'description': billingAddress,
          },
          'registrationCompleted': true,
          'profileImageUrl': profileUrl,
          'profileImagePath': profilePath,
          'registrationDate': DateTime.now().toIso8601String(),
        },
        updatedAt: DateTime.now(),
      );

      await ref.read(authProvider.notifier).updateUserProfile(updated);
      debugPrint('✅ User profile updated successfully');

      // Silinen modül: user_profile - profile refresh kaldırıldı
      debugPrint('⚠️ UserProfile refresh kaldırıldı');

      // 6. Show success message and navigate immediately
      if (mounted) {
        _showSuccessSnackBar('Kayıt başarılı! Giriş yapabilirsiniz.');
        debugPrint('🚀 Navigating to login page...');
        Navigator.of(context).pushReplacementNamed(TamgaciRoutes.login);
        debugPrint('✅ Navigation completed');
      }
    } catch (e) {
      debugPrint('❌ Registration failed: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');

      if (mounted) {
        _showErrorSnackBar(_getDetailedErrorMessage(e));
      }
    } finally {
      // Always reset registration state
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  /// Input validation helper
  String? _validateInputs() {
    final name = _firstNameController.text.trim();
    final surname = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final companyName = _companyNameController.text.trim();
    final taxId = _taxIdController.text.trim();
    final taxOffice = _taxOfficeController.text.trim();
    // Derived address fields handled during submit; no-op vars removed
    final neighborhood = _neighborhoodController.text.trim();
    final street = _streetController.text.trim();
    final buildingNo = _buildingNoController.text.trim();
    final apartmentNo = _apartmentNoController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    if (name.length < 2) return 'Ad en az 2 karakter olmalıdır';
    if (surname.length < 2) return 'Soyad en az 2 karakter olmalıdır';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    if (!_isStrongPassword(password)) {
      return 'Şifre: En az 8 karakter, 1 büyük harf, 1 küçük harf, 1 rakam ve 1 özel karakter içermelidir';
    }
    if (password != confirmPassword) {
      return 'Şifreler eşleşmiyor';
    }
    if (companyName.isEmpty) return 'Şirket adı zorunludur';
    if (companyName.length < 2) return 'Şirket adı en az 2 karakter olmalıdır';
    if (taxId.isEmpty) return 'Vergi kimlik numarası zorunludur';
    if (taxId.length < 10) {
      return 'Vergi kimlik numarası en az 10 haneli olmalıdır';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(taxId)) {
      return 'Vergi kimlik numarası sadece rakam içermelidir';
    }
    if (_selectedCountry == 'TR') {
      if (_selectedCity == null || (_selectedCity?.isEmpty ?? true)) {
        return 'İl seçimi zorunludur';
      }
      if (_selectedDistrict == null || (_selectedDistrict?.isEmpty ?? true)) {
        return 'İlçe seçimi zorunludur';
      }
      if (taxOffice.isEmpty) return 'Vergi dairesi zorunludur';
      if (neighborhood.isEmpty) return 'Mahalle zorunludur';
      if (street.isEmpty) return 'Sokak/Cadde zorunludur';
      if (buildingNo.isEmpty) return 'Bina no zorunludur';
      if (apartmentNo.isEmpty) return 'Daire no zorunludur';
      if (postalCode.isEmpty) return 'Posta kodu zorunludur';
    }

    // Phone validation if provided
    final localDigits = _phoneController.text.trim();
    if (localDigits.isNotEmpty) {
      if (localDigits.length < 7) return 'Telefon numarası çok kısa';
      if (!RegExp(r'^[0-9]+$').hasMatch(localDigits)) {
        return 'Telefon numarası sadece rakam içermelidir';
      }
    }

    return null;
  }

  /// Upload profile image with retry mechanism
  Future<Map<String, String?>> _uploadProfileImageWithRetry(
      String userId, Uint8List imageBytes,
      {int maxRetries = 3}) async {
    Exception? lastException;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        debugPrint('📤 Profile image upload attempt $attempt/$maxRetries');
        debugPrint('📊 Image size: ${imageBytes.length} bytes');

        final storage = FirebaseStorage.instance;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'profile_${userId}_$timestamp.jpg';
        final storagePath = 'users/$userId/profile/$fileName';
        final storageRef = storage.ref().child(storagePath);

        debugPrint('📁 Storage path: $storagePath');

        // Auto-detect content type based on image header
        String contentType = 'image/jpeg'; // Default
        if (imageBytes.length > 8) {
          // Check PNG signature (89 50 4E 47)
          if (imageBytes[0] == 0x89 &&
              imageBytes[1] == 0x50 &&
              imageBytes[2] == 0x4E &&
              imageBytes[3] == 0x47) {
            contentType = 'image/png';
            debugPrint('🖼️ Detected PNG image');
          }
          // Check JPEG signature (FF D8)
          else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
            contentType = 'image/jpeg';
            debugPrint('🖼️ Detected JPEG image');
          }
          // Check WebP signature (52 49 46 46)
          else if (imageBytes[0] == 0x52 &&
              imageBytes[1] == 0x49 &&
              imageBytes[2] == 0x46 &&
              imageBytes[3] == 0x46) {
            contentType = 'image/webp';
            debugPrint('🖼️ Detected WebP image');
          }
        }
        debugPrint('📷 Content type: $contentType');

        // Test basic Firebase connectivity
        debugPrint('🌐 Testing Firebase connectivity...');
        try {
          // Simple connectivity test with minimal timeout
          final testRef = storage.ref().child('test');
          await testRef.getMetadata().timeout(
                const Duration(seconds: 5),
                onTimeout: () => throw Exception(
                    'Firebase Storage connectivity test failed'),
              );
          debugPrint('✅ Firebase Storage connectivity: OK');
        } catch (e) {
          debugPrint('❌ Firebase Storage connectivity failed: $e');
          // Continue anyway, might be a permission issue rather than connectivity
        }

        // Check Firebase Storage configuration
        try {
          final bucketInfo = storage.ref().bucket;
          debugPrint('🪣 Storage bucket: $bucketInfo');
        } catch (e) {
          debugPrint('❌ Storage bucket error: $e');
        }

        // Test authentication
        final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
        debugPrint('🔐 Auth user: ${currentUser?.uid}');
        debugPrint('🔐 Auth token available: ${currentUser != null}');

        if (currentUser == null) {
          throw Exception('User not authenticated for upload');
        }

        // Test user permissions for the specific path
        debugPrint('🔐 Testing upload permissions...');
        try {
          // Try to get metadata of the parent directory to test permissions
          final parentRef = storage.ref().child('users/$userId/');
          await parentRef.listAll().timeout(
                const Duration(seconds: 3),
                onTimeout: () => throw Exception('Permission test timeout'),
              );
          debugPrint('✅ Upload permissions: OK');
        } catch (e) {
          debugPrint('⚠️ Permission test result: $e');
          // This might fail if directory doesn't exist yet, which is normal
        }

        // Auto-detect content type based on image header
        String detectedContentType = 'image/jpeg'; // Default
        if (imageBytes.length > 8) {
          // Check PNG signature (89 50 4E 47)
          if (imageBytes[0] == 0x89 &&
              imageBytes[1] == 0x50 &&
              imageBytes[2] == 0x4E &&
              imageBytes[3] == 0x47) {
            detectedContentType = 'image/png';
            debugPrint('🖼️ Detected PNG image');
          }
          // Check JPEG signature (FF D8)
          else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
            detectedContentType = 'image/jpeg';
            debugPrint('🖼️ Detected JPEG image');
          }
          // Check WebP signature (52 49 46 46)
          else if (imageBytes[0] == 0x52 &&
              imageBytes[1] == 0x49 &&
              imageBytes[2] == 0x46 &&
              imageBytes[3] == 0x46) {
            detectedContentType = 'image/webp';
            debugPrint('🖼️ Detected WebP image');
          }
        }
        debugPrint('📷 Content type: $detectedContentType');

        // Upload with metadata and progress tracking
        final uploadTask = storageRef.putData(
          imageBytes,
          SettableMetadata(
            contentType: detectedContentType,
            customMetadata: {
              'uploadedAt': DateTime.now().toIso8601String(),
              'userId': userId,
              'source': 'registration',
              'originalSize': imageBytes.length.toString(),
              'detectedType': contentType,
            },
          ),
        );

        // Track upload progress with detailed error handling
        late StreamSubscription progressSubscription;
        bool progressReceived = false;

        progressSubscription = uploadTask.snapshotEvents.listen((taskSnapshot) {
          progressReceived = true;
          final progress =
              (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes) * 100;
          debugPrint('📈 Upload progress: ${progress.toStringAsFixed(1)}%');
          debugPrint(
              '📊 Bytes transferred: ${taskSnapshot.bytesTransferred}/${taskSnapshot.totalBytes}');
          debugPrint('📊 Upload state: ${taskSnapshot.state}');
        }, onError: (e) {
          debugPrint('❌ Upload stream error: $e');
          debugPrint('❌ Error type: ${e.runtimeType}');
        }, onDone: () {
          debugPrint('✅ Upload stream completed');
        });

        // Wait for upload completion with timeout and progress check
        try {
          final snapshot = await uploadTask.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('⏰ Upload timeout after 30 seconds');
              debugPrint('❌ Progress received: $progressReceived');
              progressSubscription.cancel();
              throw Exception(
                  'Upload timeout after 30 seconds - no progress received: $progressReceived');
            },
          );

          progressSubscription.cancel();

          debugPrint('✅ Upload completed, getting download URL...');

          // Get download URL with retry
          String? downloadUrl;
          for (int urlAttempt = 1; urlAttempt <= 3; urlAttempt++) {
            try {
              downloadUrl = await snapshot.ref.getDownloadURL();
              break;
            } catch (e) {
              debugPrint('❌ URL fetch attempt $urlAttempt failed: $e');
              if (urlAttempt < 3) {
                await Future.delayed(Duration(seconds: urlAttempt));
              }
            }
          }

          if (downloadUrl == null) {
            throw Exception('Failed to get download URL after 3 attempts');
          }

          debugPrint('🔗 Download URL obtained: $downloadUrl');

          return {
            'url': downloadUrl,
            'path': storagePath,
          };
        } catch (e) {
          progressSubscription.cancel();
          rethrow;
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('❌ Upload attempt $attempt failed: $e');
        debugPrint('❌ Error type: ${e.runtimeType}');
        debugPrint('❌ Error details: ${e.toString()}');

        if (attempt < maxRetries) {
          final delay = Duration(seconds: attempt * 2);
          debugPrint('⏳ Waiting ${delay.inSeconds}s before retry...');
          await Future.delayed(delay);
        }
      }
    }

    throw lastException ??
        Exception('Profile image upload failed after $maxRetries attempts');
  }

  /// Test Firebase Storage rules and connectivity
  Future<void> _testFirebaseStorageSetup() async {
    try {
      debugPrint('🧪 Testing Firebase Storage setup...');

      final storage = FirebaseStorage.instance;
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('❌ No authenticated user for storage test');
        return;
      }

      // Test 1: Basic connectivity
      debugPrint('🧪 Test 1: Basic connectivity');
      try {
        final bucket = storage.ref().bucket;
        debugPrint('✅ Storage bucket: $bucket');
        debugPrint('✅ Firebase Storage instance is ready');
      } catch (e) {
        debugPrint('❌ Firebase Storage connectivity issue: $e');
      }

      // Test 2: User-specific path permissions
      debugPrint('🧪 Test 2: User path permissions');
      try {
        final testPath = 'users/${currentUser.uid}/test.txt';
        final testRef = storage.ref().child(testPath);

        // Try to create a small test file
        await testRef.putString('test').timeout(const Duration(seconds: 10));
        debugPrint('✅ Upload permission test passed');

        // Clean up test file
        await testRef.delete();
        debugPrint('✅ Delete permission test passed');
      } catch (e) {
        debugPrint('❌ Permission test failed: $e');
        debugPrint('💡 Check Firebase Storage Rules:');
        debugPrint('   rules_version = "2";');
        debugPrint('   service firebase.storage {');
        debugPrint('     match /b/{bucket}/o {');
        debugPrint('       match /users/{userId}/{allPaths=**} {');
        debugPrint(
            '         allow read, write: if request.auth != null && request.auth.uid == userId;');
        debugPrint('       }');
        debugPrint('     }');
        debugPrint('   }');
      }
    } catch (e) {
      debugPrint('❌ Storage setup test failed: $e');
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onError),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message, style: TextStyle(color: scheme.onError))),
          ],
        ),
        backgroundColor: scheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.primary;
    final fg = scheme.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: fg),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: TextStyle(color: fg))),
          ],
        ),
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get detailed error message based on exception type and content
  String _getDetailedErrorMessage(Object e) {
    final text = e.toString().toLowerCase();

    // Firebase Auth specific errors
    if (text.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kayıtlı. Farklı bir e-posta adresi deneyin veya giriş yapın.';
    }
    if (text.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 8 karakter, büyük/küçük harf, rakam ve özel karakter kullanın.';
    }
    if (text.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi formatı. Lütfen doğru formatta giriniz.';
    }
    if (text.contains('operation-not-allowed')) {
      return 'E-posta/şifre ile kayıt işlemi şu anda devre dışı. Lütfen daha sonra tekrar deneyin.';
    }

    // Network and connectivity errors
    if (text.contains('network') ||
        text.contains('timeout') ||
        text.contains('connection')) {
      return 'İnternet bağlantısı sorunu. Bağlantınızı kontrol edip tekrar deneyin.';
    }

    // Permission and authentication errors
    if (text.contains('permission-denied')) {
      return 'Kayıt işlemi tamamlandı ancak profil verilerinde sorun oluştu. Giriş yapıp profilinizi güncelleyebilirsiniz.';
    }
    if (text.contains('requires-recent-login')) {
      return 'Güvenlik nedeniyle işlem gerçekleştirilemedi. Lütfen tekrar giriş yapın.';
    }

    // Storage and upload errors
    if (text.contains('storage') || text.contains('upload')) {
      return 'Profil fotoğrafı yüklenemedi. Kayıt işlemi tamamlandı, fotoğrafı daha sonra ekleyebilirsiniz.';
    }

    // Firestore errors
    if (text.contains('firestore') || text.contains('document')) {
      return 'Profil bilgileri kaydedilemedi. Kayıt tamamlandı, bilgilerinizi profilden güncelleyebilirsiniz.';
    }

    // Validation errors
    if (text.contains('validation') || text.contains('invalid')) {
      return 'Girilen bilgilerde hata var. Lütfen tüm alanları doğru şekilde doldurun.';
    }

    // Generic errors
    if (text.contains('too-many-requests')) {
      return 'Çok fazla istek gönderdiniz. Lütfen birkaç dakika bekleyip tekrar deneyin.';
    }

    // Default friendly message
    return 'Kayıt işlemi sırasında bir hata oluştu. Lütfen bilgilerinizi kontrol edip tekrar deneyin.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Masaüstü için responsive layout
            if (TamgaciConstants.isDesktop(context) ||
                TamgaciConstants.isWideDesktop(context)) {
              return _buildDesktopLayout(isDark);
            }

            // Mobil ve tablet için normal layout
            return _buildMobileLayout(isDark);
          },
        ),
      ),
    );
  }

  /// Masaüstü layout'u - Beyaz arkaplan, sol görsel
  Widget _buildDesktopLayout(bool isDark) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white, // Beyaz arkaplan
          child: Row(children: [
            // Sol taraf - Register görseli
            Expanded(
              flex: 1,
              child: Center(
                child: _buildRegisterImage(),
              ),
            ),

            // Sağ taraf - Register formu
            Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    padding: const EdgeInsets.all(32),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                                height: 120), // Banner için ekstra alan

                            // Premium Logo
                            Column(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF2563EB),
                                        Color(0xFF0EA5E9)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2563EB)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        'assets/images/logos/140x140logo.png',
                                        fit: BoxFit.contain,
                                        color: Colors.white,
                                        colorBlendMode: BlendMode.srcIn,
                                      ),
                                      // Premium parıltı efekti
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white
                                                    .withValues(alpha: 0.4),
                                                Colors.white
                                                    .withValues(alpha: 0.1),
                                                Colors.white
                                                    .withValues(alpha: 0.0),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF1D4ED8)
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Hesap Oluştur',
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Builder(builder: (context) {
                                  final scheme = Theme.of(context).colorScheme;
                                  final hintColor =
                                      scheme.onSurface.withValues(alpha: 0.7);
                                  return Text(
                                    "Tamgaci'ye hoş geldiniz!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: hintColor,
                                    ),
                                  );
                                }),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Profil fotoğrafı ve Ad/Soyad
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey.shade300
                                            : Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                    backgroundImage: _avatarBytes != null
                                        ? MemoryImage(_avatarBytes!)
                                        : null,
                                    child: _avatarBytes == null
                                        ? Icon(
                                            Icons.camera_alt_outlined,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black87
                                                    : Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _firstNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Ad *',
                                          hintText: 'Adınız',
                                          prefixIcon:
                                              Icon(Icons.person_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Ad gereklidir';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'Ad en az 2 karakter olmalı';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: _lastNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Soyad *',
                                          hintText: 'Soyadınız',
                                          prefixIcon:
                                              Icon(Icons.person_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Soyad gereklidir';
                                          }
                                          if (value.trim().length < 2) {
                                            return 'Soyad en az 2 karakter olmalı';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // E-posta
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'E-posta *',
                                hintText: 'ornek@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'E-posta gereklidir';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Şirket Adı
                            TextFormField(
                              controller: _companyNameController,
                              decoration: const InputDecoration(
                                labelText: 'Şirket Adı',
                                hintText: 'Örnek Teknoloji A.Ş.',
                                prefixIcon: Icon(Icons.business_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Telefon (alan kodu + numara)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Telefon',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: TamgaciConstants.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    showCountryPicker(
                                      context: context,
                                      showPhoneCode: true,
                                      onSelect: (Country country) {
                                        setState(() {
                                          _selectedCountry =
                                              country.countryCode;
                                          _selectedDialCode =
                                              '+${country.phoneCode}';
                                        });
                                      },
                                    );
                                  },
                                  child: Builder(builder: (context) {
                                    final scheme =
                                        Theme.of(context).colorScheme;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: scheme.outlineVariant),
                                        borderRadius: BorderRadius.circular(8),
                                        color: scheme.surface,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Row(
                                        children: [
                                          Text(
                                            _countryFlagEmoji(_selectedCountry),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedDialCode,
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(Icons.arrow_drop_down),
                                          const SizedBox(width: 12),
                                          const VerticalDivider(width: 1),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _phoneController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    15),
                                              ],
                                              decoration: const InputDecoration(
                                                hintText: '5551234567',
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Şifre
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onChanged: (value) => setState(() {}),
                                  decoration: InputDecoration(
                                    labelText: 'Şifre *',
                                    hintText:
                                        'En az 8 karakter, büyük/küçük harf, rakam ve sembol',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifre gereklidir';
                                    }
                                    if (!_isStrongPassword(value)) {
                                      return 'Şifre güvenlik gereksinimlerini karşılamıyor';
                                    }
                                    return null;
                                  },
                                ),
                                if (_passwordController.text.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildPasswordStrengthIndicator(),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Şifre Tekrar
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Şifre Tekrar *',
                                hintText: 'Şifrenizi tekrar girin',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Şifre tekrarı gereklidir';
                                }
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                if (!_isStrongPassword(
                                    _passwordController.text)) {
                                  return 'Şifre gereksinimlerini karşılamıyor';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Vergi Kimlik Numarası
                            TextFormField(
                              controller: _taxIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Vergi Kimlik Numarası',
                                hintText: 'TCKN/VKN',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Vergi Dairesi: TR ise arama/seçim, diğer ülkelerde serbest metin
                            if (_selectedCountry == 'TR')
                              RawAutocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  final q = textEditingValue.text
                                      .trim()
                                      .toLowerCase();
                                  if (q.isEmpty) {
                                    return _allTaxOffices.take(100);
                                  }
                                  return _allTaxOffices.where(
                                      (o) => o.toLowerCase().contains(q));
                                },
                                initialValue: TextEditingValue(
                                    text: _taxOfficeController.text),
                                onSelected: (String selection) {
                                  _taxOfficeController.text = selection;
                                },
                                fieldViewBuilder: (context, controller,
                                    focusNode, onFieldSubmitted) {
                                  if (controller.text !=
                                      _taxOfficeController.text) {
                                    controller.text = _taxOfficeController.text;
                                    controller.selection =
                                        TextSelection.fromPosition(
                                      TextPosition(
                                          offset: controller.text.length),
                                    );
                                  }
                                  controller.addListener(() {
                                    _taxOfficeController.text = controller.text;
                                  });
                                  focusNode.addListener(() {
                                    if (focusNode.hasFocus &&
                                        controller.text.isEmpty) {
                                      controller.text = '';
                                    }
                                  });
                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                      labelText: 'Vergi Dairesi',
                                      hintText:
                                          'Yazarak arayın veya listeden seçin',
                                      prefixIcon:
                                          Icon(Icons.apartment_outlined),
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                },
                                optionsViewBuilder:
                                    (context, onSelected, options) {
                                  final scheme = Theme.of(context).colorScheme;
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4,
                                      color: scheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxHeight: 300, minWidth: 280),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (context, index) {
                                            final opt =
                                                options.elementAt(index);
                                            return ListTile(
                                              dense: true,
                                              title: Text(opt,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: scheme.onSurface)),
                                              onTap: () => onSelected(opt),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              TextFormField(
                                controller: _taxOfficeController,
                                decoration: const InputDecoration(
                                  labelText: 'Vergi Dairesi',
                                  hintText: 'Vergi dairesini yazın',
                                  prefixIcon: Icon(Icons.apartment_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Ülke/İl/İlçe ve adres detayları
                            Column(
                              children: [
                                // Ülke sabit country picker ile
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text('Ülke: $_selectedCountry',
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: TamgaciConstants
                                                  .textSecondary)),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        showCountryPicker(
                                          context: context,
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            setState(() {
                                              _selectedCountry =
                                                  country.countryCode;
                                              _selectedDialCode =
                                                  '+${country.phoneCode}';
                                            });
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.public),
                                      label: const Text('Ülke Seç'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Türkiye seçili değilse adres alanlarını serbest bırak
                                if (_selectedCountry == 'TR')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          initialValue: _selectedCity,
                                          items: _cities
                                              .map((c) => DropdownMenuItem(
                                                    value: c,
                                                    child: Text(c,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        softWrap: false),
                                                  ))
                                              .toList(),
                                          selectedItemBuilder: (context) =>
                                              _cities
                                                  .map((c) => Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(c,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            softWrap: false),
                                                      ))
                                                  .toList(),
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedCity = v;
                                              _selectedDistrict = null;
                                              _cityController.text = v ?? '';
                                              _districtController.clear();
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'İl',
                                            prefixIcon:
                                                Icon(Icons.location_city),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _selectedDistrict,
                                          items: (_selectedCity != null)
                                              ? (_districtsByCity[
                                                          _selectedCity!] ??
                                                      [])
                                                  .map((d) => DropdownMenuItem(
                                                      value: d, child: Text(d)))
                                                  .toList()
                                              : const [],
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedDistrict = v;
                                              _districtController.text =
                                                  v ?? '';
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'İlçe',
                                            prefixIcon:
                                                Icon(Icons.map_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_selectedCountry == 'TR')
                                  const SizedBox(height: 12),
                                if (_selectedCountry == 'TR')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _neighborhoodController,
                                          decoration: const InputDecoration(
                                            labelText: 'Mahalle',
                                            prefixIcon:
                                                Icon(Icons.home_work_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _streetController,
                                          decoration: const InputDecoration(
                                            labelText: 'Sokak/Cadde',
                                            prefixIcon:
                                                Icon(Icons.alt_route_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_selectedCountry == 'TR')
                                  const SizedBox(height: 12),
                                if (_selectedCountry == 'TR')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _buildingNoController,
                                          decoration: const InputDecoration(
                                            labelText: 'Bina No',
                                            prefixIcon: Icon(Icons.apartment),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _apartmentNoController,
                                          decoration: const InputDecoration(
                                            labelText: 'Daire No',
                                            prefixIcon: Icon(
                                                Icons.meeting_room_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _postalCodeController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(10)
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Posta Kodu',
                                            prefixIcon: Icon(Icons
                                                .local_post_office_outlined),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _addressController,
                                  maxLines: _selectedCountry == 'TR' ? 2 : 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Adres (Açıklama)',
                                    hintText: 'Opsiyonel ek açıklama',
                                    prefixIcon:
                                        Icon(Icons.sticky_note_2_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Kullanım şartları
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: TamgaciConstants.textSecondary,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text: 'Kullanım şartlarını ve '),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              showPrivacyPolicyDialog(context);
                                            },
                                            child: Text(
                                              "Gizlilik Politikası'nı",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: TamgaciConstants
                                                    .primaryColor,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const TextSpan(text: ' kabul ediyorum'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Kayıt ol butonu
                            Consumer(
                              builder: (context, ref, child) {
                                final authLoading =
                                    ref.watch(authLoadingProvider);
                                final isLoading = authLoading || _isRegistering;

                                return ElevatedButton(
                                  onPressed: isLoading ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: isLoading ? 0 : 2,
                                  ),
                                  child: isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _isRegistering
                                                  ? (_avatarBytes != null
                                                      ? 'Fotoğraf yükleniyor...'
                                                      : 'Kayıt oluşturuluyor...')
                                                  : 'Kayıt Ol',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Kayıt Ol',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Giriş yap linki
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Zaten hesabınız var mı? ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: TamgaciConstants.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pushReplacementNamed(TamgaciRoutes.login);
                                  },
                                  child: Text(
                                    'Giriş Yap',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: TamgaciConstants.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
          ]),
        ),

        // Banner - sadece desktop'ta göster
        if (_showBanner) _buildBanner(),
      ],
    );
  }

  /// Mobil ve tablet layout'u - Desktop formu ile aynı
  Widget _buildMobileLayout(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Premium Logo
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/logos/140x140logo.png',
                        fit: BoxFit.contain,
                        color: Colors.white,
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      // Premium parıltı efekti
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ).createShader(bounds),
                  child: Text(
                    'Hesap Oluştur',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final scheme = Theme.of(context).colorScheme;
                  final hintColor = scheme.onSurface.withValues(alpha: 0.7);
                  return Text(
                    "Tamgaci'ye hoş geldiniz!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hintColor,
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 40),

            // Profil fotoğrafı ve Ad/Soyad
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).brightness ==
                            Brightness.light
                        ? Colors.grey.shade300
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    backgroundImage: _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : null,
                    child: _avatarBytes == null
                        ? Icon(
                            Icons.camera_alt_outlined,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black87
                                    : Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Ad *',
                          hintText: 'Adınız',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ad gereklidir';
                          }
                          if (value.trim().length < 2) {
                            return 'Ad en az 2 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Soyad *',
                          hintText: 'Soyadınız',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Soyad gereklidir';
                          }
                          if (value.trim().length < 2) {
                            return 'Soyad en az 2 karakter olmalı';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // E-posta
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta *',
                hintText: 'ornek@email.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'E-posta gereklidir';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Geçerli bir e-posta adresi girin';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Şirket Adı
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Şirket Adı',
                hintText: 'Örnek Teknoloji A.Ş.',
                prefixIcon: Icon(Icons.business_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Telefon (alan kodu + numara)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telefon',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country.countryCode;
                          _selectedDialCode = '+${country.phoneCode}';
                        });
                      },
                    );
                  },
                  child: Builder(builder: (context) {
                    final scheme = Theme.of(context).colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: scheme.outlineVariant),
                        borderRadius: BorderRadius.circular(8),
                        color: scheme.surface,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Text(
                            _countryFlagEmoji(_selectedCountry),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDialCode,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.arrow_drop_down),
                          const SizedBox(width: 12),
                          const VerticalDivider(width: 1),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(15),
                              ],
                              decoration: const InputDecoration(
                                hintText: '5551234567',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Vergi Kimlik Numarası
            TextFormField(
              controller: _taxIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              decoration: const InputDecoration(
                labelText: 'Vergi Kimlik Numarası',
                hintText: 'TCKN/VKN',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Vergi Dairesi: TR ise arama/seçim, diğer ülkelerde serbest metin
            if (_selectedCountry == 'TR')
              RawAutocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final q = textEditingValue.text.trim().toLowerCase();
                  if (q.isEmpty) {
                    // Yazmadan da önde gelenleri göster (ilk 100)
                    return _allTaxOffices.take(100);
                  }
                  return _allTaxOffices
                      .where((o) => o.toLowerCase().contains(q));
                },
                initialValue: TextEditingValue(text: _taxOfficeController.text),
                onSelected: (String selection) {
                  _taxOfficeController.text = selection;
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  if (controller.text != _taxOfficeController.text) {
                    controller.text = _taxOfficeController.text;
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  }
                  controller.addListener(() {
                    _taxOfficeController.text = controller.text;
                  });
                  focusNode.addListener(() {
                    if (focusNode.hasFocus && controller.text.isEmpty) {
                      controller.text = '';
                    }
                  });
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Vergi Dairesi',
                      hintText: 'Yazarak arayın veya listeden seçin',
                      prefixIcon: Icon(Icons.apartment_outlined),
                      border: OutlineInputBorder(),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  final scheme = Theme.of(context).colorScheme;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 300, minWidth: 280),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final opt = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              title: Text(opt,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: scheme.onSurface)),
                              onTap: () => onSelected(opt),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              TextFormField(
                controller: _taxOfficeController,
                decoration: const InputDecoration(
                  labelText: 'Vergi Dairesi',
                  hintText: 'Vergi dairesini yazın',
                  prefixIcon: Icon(Icons.apartment_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 16),

            // Ülke/İl/İlçe ve adres detayları
            Column(
              children: [
                // Ülke sabit country picker ile
                Row(
                  children: [
                    Expanded(
                      child: Text('Ülke: $_selectedCountry',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: TamgaciConstants.textSecondary)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country.countryCode;
                              _selectedDialCode = '+${country.phoneCode}';
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.public),
                      label: const Text('Ülke Seç'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Türkiye seçili değilse adres alanlarını serbest bırak
                if (_selectedCountry == 'TR')
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedCity,
                          items: _cities
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => _cities
                              .map((c) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(c,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedCity = v;
                              _selectedDistrict = null;
                              _cityController.text = v ?? '';
                              _districtController.clear();
                              // Vergi dairesini koru; kullanıcı tekrar seçmek zorunda kalmasın
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'İl',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedDistrict,
                          items: (_selectedCity != null)
                              ? (_districtsByCity[_selectedCity!] ?? [])
                                  .map((d) => DropdownMenuItem(
                                      value: d, child: Text(d)))
                                  .toList()
                              : const [],
                          onChanged: (v) {
                            setState(() {
                              _selectedDistrict = v;
                              _districtController.text = v ?? '';
                              // Vergi dairesini koru; kullanıcı tekrar seçmek zorunda kalmasın
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'İlçe',
                            prefixIcon: Icon(Icons.map_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_selectedCountry == 'TR') const SizedBox(height: 12),
                if (_selectedCountry == 'TR')
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _neighborhoodController,
                          decoration: const InputDecoration(
                            labelText: 'Mahalle',
                            prefixIcon: Icon(Icons.home_work_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _streetController,
                          decoration: const InputDecoration(
                            labelText: 'Sokak/Cadde',
                            prefixIcon: Icon(Icons.alt_route_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_selectedCountry == 'TR') const SizedBox(height: 12),
                if (_selectedCountry == 'TR')
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _buildingNoController,
                          decoration: const InputDecoration(
                            labelText: 'Bina No',
                            prefixIcon: Icon(Icons.apartment),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _apartmentNoController,
                          decoration: const InputDecoration(
                            labelText: 'Daire No',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10)
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Posta Kodu',
                            prefixIcon: Icon(Icons.local_post_office_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  maxLines: _selectedCountry == 'TR' ? 2 : 3,
                  decoration: const InputDecoration(
                    labelText: 'Adres (Açıklama)',
                    hintText: 'Opsiyonel ek açıklama',
                    prefixIcon: Icon(Icons.sticky_note_2_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Şifre
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Şifre *',
                    hintText:
                        'En az 8 karakter, büyük/küçük harf, rakam ve sembol',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre gereklidir';
                    }
                    if (!_isStrongPassword(value)) {
                      return 'Şifre güvenlik gereksinimlerini karşılamıyor';
                    }
                    return null;
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildPasswordStrengthIndicator(),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Şifre Tekrar
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Şifre Tekrar *',
                hintText: 'Şifrenizi tekrar girin',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre tekrarı gereklidir';
                }
                if (value != _passwordController.text) {
                  return 'Şifreler eşleşmiyor';
                }
                if (!_isStrongPassword(_passwordController.text)) {
                  return 'Şifre gereksinimlerini karşılamıyor';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Kullanım şartları
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TamgaciConstants.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Kullanım şartlarını ve '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              showPrivacyPolicyDialog(context);
                            },
                            child: Text(
                              "Gizlilik Politikası'nı",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: TamgaciConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' kabul ediyorum'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Kayıt ol butonu
            Consumer(
              builder: (context, ref, child) {
                final authLoading = ref.watch(authLoadingProvider);
                final isLoading = authLoading || _isRegistering;

                return ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: isLoading ? 0 : 2,
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isRegistering
                                  ? (_avatarBytes != null
                                      ? 'Fotoğraf yükleniyor...'
                                      : 'Kayıt oluşturuluyor...')
                                  : 'Kayıt Ol',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Kayıt Ol',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Giriş yap linki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zaten hesabınız var mı? ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TamgaciConstants.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(TamgaciRoutes.login);
                  },
                  child: Text(
                    'Giriş Yap',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TamgaciConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Register görseli
  Widget _buildRegisterImage() {
    return Container(
      width: 550,
      height: 650,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/ads/registerImage.png',
          width: 500,
          height: 600,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
      ),
    );
  }

  /// Price box builder
  Widget _buildPriceBox(String price, String period, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            period,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner - sadece desktop'ta göster
  Widget _buildBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: _showBanner ? 100 : 0,
        curve: Curves.easeInOut,
        child: _showBanner
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Close button
                    GestureDetector(
                      onTap: () => setState(() => _showBanner = false),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Banner content
                    Expanded(
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Özel Fiyatlar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '30 Gün Ücretsiz Deneme',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Price boxes - sağ tarafta
                          Row(
                            children: [
                              _buildPriceBox('₺119', 'Aylık', Colors.white),
                              const SizedBox(width: 8),
                              _buildPriceBox('₺599', '6 Aylık', Colors.white),
                              const SizedBox(width: 8),
                              _buildPriceBox('₺949', 'Yıllık', Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
