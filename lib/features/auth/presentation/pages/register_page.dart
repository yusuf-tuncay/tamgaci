// ========== REGISTER PAGE ==========
// lib/features/auth/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/auth_providers.dart';

/// Kayıt olma sayfası
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // Phone area code (country calling code) state
  String _selectedDialCode = '+90';
  String _selectedCountry = 'TR';

  // country_picker paketini kullanarak tüm ülkeler ve alan kodları gösterilecek

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
  }

  bool _isStrongPassword(String password) {
    // En az 8 karakter, 1 büyük, 1 küçük, 1 rakam, 1 özel karakter (Türkçe dahil)
    // Raw string tek tırnak içerirken derleyici uyarısı çıkarabilir; karakter kümesini sadeleştiriyoruz.
    final regex = RegExp(
      r'^(?=.*[A-ZÇĞİÖŞÜ])(?=.*[a-zçğıöşü])(?=.*\d)(?=.*[!@#\$%^&*()_+\-={}\[\]\\|:;,.<>/?~`]).{8,}$',
    );
    return regex.hasMatch(password);
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _phoneController.dispose();
    _taxIdController.dispose();
    _taxOfficeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Kayıt işlemi
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanım şartlarını kabul etmelisiniz')),
      );
      return;
    }

    try {
      final full = _nameController.text.trim();
      final parts = full.split(' ');
      final name = parts.isNotEmpty ? parts.first : full;
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final localDigits = _phoneController.text.trim();
      final phoneE164 =
          localDigits.isEmpty ? null : '$_selectedDialCode$localDigits';

      if (name.length < 2 || surname.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad ve soyad en az 2 karakter olmalı')),
        );
        return;
      }

      if (!_isStrongPassword(_passwordController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen güçlü bir şifre girin')),
        );
        return;
      }

      await ref.read(authProvider.notifier).registerWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: name,
            surname: surname,
          );

      // Fetch latest user after sign up and update profile (non-blocking)
      try {
        final current = await ref.read(getCurrentUserUseCaseProvider).call();
        if (current != null) {
          final updated = current.copyWith(
            phone: localDigits.isEmpty ? null : localDigits,
            phoneE164: phoneE164,
            phoneCountry: _selectedCountry,
            phoneDialCode: _selectedDialCode,
            settings: {
              ...?current.settings,
              'companyName': _companyNameController.text.trim(),
              'taxId': _taxIdController.text.trim(),
              'taxOffice': _taxOfficeController.text.trim(),
              'billingAddress': _addressController.text.trim(),
            },
          );
          await ref.read(authProvider.notifier).updateUserProfile(updated);
        }
      } catch (_) {
        // profile update failure should not block navigation
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(TamgaciRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyAuthMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _friendlyAuthMessage(Object e) {
    final text = e.toString().toLowerCase();
    if (text.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (text.contains('weak-password')) {
      return 'Şifreniz yeterince güçlü değil. Daha güçlü bir şifre deneyin.';
    }
    if (text.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    }
    if (text.contains('permission-denied')) {
      return 'İşlem tamamlandı, ancak profil oluşturulamadı. Daha sonra otomatik tamamlanacaktır.';
    }
    if (text.contains('network') || text.contains('timeout')) {
      return 'Ağ bağlantı sorunu. İnternetinizi kontrol edin ve tekrar deneyin.';
    }
    return 'Kayıt tamamlanamadı. Lütfen bilgilerinizi kontrol edin ve tekrar deneyin.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo ve başlık
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: TamgaciConstants.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/logos/fullsizebluelogo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 40,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hesap Oluştur',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TamgaciConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tamgaci'ye hoş geldiniz!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: TamgaciConstants.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Ad Soyad
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad *',
                    hintText: 'İsim Soyisim',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ad soyad gereklidir';
                    }
                    final parts = value.trim().split(' ');
                    if (parts.length < 2) {
                      return 'Lütfen ad ve soyad girin';
                    }
                    final given = parts.first.trim();
                    final family = parts.sublist(1).join(' ').trim();
                    if (given.length < 2) return 'Ad en az 2 karakter olmalı';
                    if (family.length < 2)
                      return 'Soyad en az 2 karakter olmalı';
                    return null;
                  },
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
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
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
                      ),
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

                // Vergi Dairesi
                TextFormField(
                  controller: _taxOfficeController,
                  decoration: const InputDecoration(
                    labelText: 'Vergi Dairesi',
                    hintText: 'Örn. Kadıköy VD',
                    prefixIcon: Icon(Icons.apartment_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Adres
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Adres',
                    hintText: 'Fatura/iş adresi',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre *',
                    hintText:
                        'En az 8 karakter, 1 büyük/1 küçük/1 rakam/1 sembol',
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
                      return 'Şifre: 1 büyük, 1 küçük, 1 rakam, 1 sembol içermeli';
                    }
                    return null;
                  },
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
                          children: const [
                            TextSpan(text: 'Kullanım şartlarını ve '),
                            TextSpan(
                              text: "Gizlilik Politikası'nı",
                              style: TextStyle(
                                color: TamgaciConstants.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(text: ' kabul ediyorum'),
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
                    final isLoading = ref.watch(authLoadingProvider);

                    return ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TamgaciConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
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
    );
  }
}
