import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/constants.dart';
import '../../../../core/routes/routes.dart';
import '../providers/auth_providers.dart';

/// Giriş sayfası
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _rememberMe = prefs.getBool('remember_me') ?? true;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: TamgaciConstants.pagePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: TamgaciConstants.spaceXL),

                // Logo ve başlık
                _buildHeader(isDark),

                const SizedBox(height: TamgaciConstants.spaceXXL),

                // Giriş formu
                _buildLoginForm(isDark),

                const SizedBox(height: TamgaciConstants.spaceLG),

                // Giriş butonu
                _buildLoginButton(),

                const SizedBox(height: TamgaciConstants.spaceMD),

                // Şifremi unuttum
                _buildForgotPassword(isDark),

                const SizedBox(height: TamgaciConstants.spaceXL),

                // Kayıt ol linki
                _buildRegisterLink(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isDark
                ? TamgaciConstants.primaryColorDark
                : TamgaciConstants.primaryColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
            boxShadow: TamgaciConstants.shadowMedium,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logos/fullsizebluelogo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.account_balance,
                size: 50,
                color: TamgaciConstants.textOnPrimary,
              );
            },
          ),
        ),

        const SizedBox(height: TamgaciConstants.spaceLG),

        // Başlık
        Text(
          TamgaciConstants.appName,
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark
                ? TamgaciConstants.primaryColorDark
                : TamgaciConstants.primaryColor,
          ),
        ),

        const SizedBox(height: TamgaciConstants.spaceSM),

        // Alt başlık
        Text(
          'Hesabınıza giriş yapın',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isDark) {
    return Column(
      children: [
        // E-posta alanı
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: isDark
                ? TamgaciConstants.textPrimaryDark
                : TamgaciConstants.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'E-posta',
            hintText: 'ornek@email.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            ),
            filled: true,
            fillColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
            labelStyle: TextStyle(
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
            hintStyle: TextStyle(
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'E-posta adresi gerekli';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ),

        const SizedBox(height: TamgaciConstants.spaceLG),

        // Şifre alanı
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(
            color: isDark
                ? TamgaciConstants.textPrimaryDark
                : TamgaciConstants.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Şifre',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
            ),
            filled: true,
            fillColor: isDark ? TamgaciConstants.cardColorDark : Colors.white,
            labelStyle: TextStyle(
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
            hintStyle: TextStyle(
              color: isDark
                  ? TamgaciConstants.textSecondaryDark
                  : TamgaciConstants.textSecondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Şifre gerekli';
            }
            if (value.length < 6) {
              return 'Şifre en az 6 karakter olmalı';
            }
            return null;
          },
        ),

        const SizedBox(height: 12),

        // Beni hatırla
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) async {
                final value = v ?? true;
                setState(() => _rememberMe = value);
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('remember_me', value);
                } catch (_) {}
              },
            ),
            Text(
              'Beni hatırla',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark
                    ? TamgaciConstants.textSecondaryDark
                    : TamgaciConstants.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final isLoading = ref.watch(authLoadingProvider);

    return SizedBox(
      height: TamgaciConstants.buttonHeight(context),
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  TamgaciConstants.textOnPrimary,
                ),
              )
            : Text(
                'Giriş Yap',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPassword(bool isDark) {
    return TextButton(
      onPressed: () {
        TamgaciRoutes.pushNamed(context, TamgaciRoutes.forgotPassword);
      },
      child: Text(
        'Şifremi Unuttum',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark
              ? TamgaciConstants.primaryColorDark
              : TamgaciConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu? ',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDark
                ? TamgaciConstants.textSecondaryDark
                : TamgaciConstants.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            TamgaciRoutes.pushNamed(context, TamgaciRoutes.register);
          },
          child: Text(
            'Kayıt Ol',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TamgaciConstants.primaryColorDark
                  : TamgaciConstants.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Web'de kalıcılığı ayarla
      if (kIsWeb) {
        final persistence = _rememberMe
            ? firebase_auth.Persistence.LOCAL
            : firebase_auth.Persistence.SESSION;
        await firebase_auth.FirebaseAuth.instance.setPersistence(persistence);
      }

      await ref.read(authProvider.notifier).signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        // Başarılı giriş sonrası dashboard'a yönlendir
        TamgaciRoutes.pushNamedAndClearAll(
          context,
          TamgaciRoutes.dashboard,
        );
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
    if (text.contains('user-not-found')) {
      return 'Kullanıcı bulunamadı. E-posta adresinizi kontrol edin.';
    }
    if (text.contains('wrong-password')) {
      return 'Şifre hatalı. Lütfen tekrar deneyin.';
    }
    if (text.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    }
    if (text.contains('too-many-requests')) {
      return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
    }
    if (text.contains('permission-denied')) {
      return 'İzin hatası. Lütfen daha sonra tekrar deneyin.';
    }
    if (text.contains('network') || text.contains('timeout')) {
      return 'Ağ bağlantı sorunu. İnternetinizi kontrol edin ve tekrar deneyin.';
    }
    return 'Giriş yapılamadı. Lütfen bilgilerinizi kontrol edin ve tekrar deneyin.';
  }
}
