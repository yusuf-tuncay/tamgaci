import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/core/theme/constants.dart';
// import 'package:tamgaci/core/database/tamgaci_database.dart'; // Removed - using Firebase only
// import 'package:tamgaci/core/database/test_data_helper.dart'; // Removed - using Firebase only
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tamgaci/core/cache/data_cache.dart';
// import 'package:tamgaci/l10n/generated/app_localizations.dart';

// ========== SPLASH STATE YÖNETİMİ ==========

/// Splash ekranının durumlarını tanımlayan enum
enum SplashState {
  /// Yükleme başlangıcı
  loading,

  /// İlk kurulum kontrolleri
  initializing,

  /// Kullanıcı oturum kontrolü
  checkingAuth,

  /// Uygulama hazır
  ready,

  /// Hata durumu
  error,
}

/// Splash ekranı verilerini tutan model sınıfı
class SplashData {
  /// Mevcut durum
  final SplashState state;

  /// Yükleme yüzdesi (0-100)
  final int progress;

  /// Durum mesajı
  final String message;

  /// Hata mesajı (varsa)
  final String? errorMessage;

  /// Splash ekranının gösterilme süresi (milisaniye)
  final int duration;

  const SplashData({
    required this.state,
    required this.progress,
    required this.message,
    this.errorMessage,
    this.duration = 3000,
  });

  /// SplashData kopyalama metodu
  SplashData copyWith({
    SplashState? state,
    int? progress,
    String? message,
    String? errorMessage,
    int? duration,
  }) {
    return SplashData(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() {
    return 'SplashData(state: $state, progress: $progress, message: $message)';
  }
}

// ========== SPLASH NOTIFIER ==========

/// Splash ekranı durumunu yöneten StateNotifier
class SplashNotifier extends StateNotifier<SplashData> {
  /// SplashNotifier constructor'ı
  SplashNotifier()
      : super(
          const SplashData(
            state: SplashState.loading,
            progress: 0,
            message: 'Tamgacı Yükleniyor...',
          ),
        );

  /// Splash sürecini başlatan metod
  Future<void> initializeApp() async {
    try {
      // 1. Adım: İlk yükleme
      await _updateState(
        SplashState.loading,
        20,
        'Uygulama başlatılıyor...',
      );

      // 2. Adım: İlk kurulum kontrolleri (hızlı)
      await _updateState(
        SplashState.initializing,
        40,
        'Ayarlar kontrol ediliyor...',
      );
      await _performInitialSetup();

      // 3. Adım: Veritabanı bağlantısı kontrolü (hızlı)
      await _updateState(
        SplashState.initializing,
        60,
        'Veritabanı hazırlanıyor...',
      );
      await _initializeDatabase();

      // 4. Adım: Kullanıcı oturum kontrolü (hızlı)
      await _updateState(
        SplashState.checkingAuth,
        80,
        'Oturum bilgileri kontrol ediliyor...',
      );
      await _checkUserAuthentication();

      // 5. Adım: Tema ve dil ayarları (hızlı)
      await _updateState(
        SplashState.initializing,
        90,
        'Tema ayarları yükleniyor...',
      );
      await _loadAppSettings();

      // 6. Adım: Son kontroller ve hazırlık
      await _updateState(
        SplashState.ready,
        100,
        'Tamgacı hazır!',
      );
      // Delay'i kaldırdık - hemen geçiş yap
    } catch (error) {
      // Hata durumunda state'i güncelle
      state = state.copyWith(
        state: SplashState.error,
        progress: 0,
        message: 'Bir hata oluştu',
        errorMessage: error.toString(),
      );
    }
  }

  /// State'i güncelleyen helper metod
  Future<void> _updateState(
    SplashState newState,
    int progress,
    String message,
  ) async {
    state = state.copyWith(
      state: newState,
      progress: progress,
      message: message,
    );

    // UI güncellemesi için kısa bir bekleme
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// İlk kurulum ayarlarını yapan metod
  Future<void> _performInitialSetup() async {
    // Shared Preferences ilk kurulumu
    // Uygulama versiyon kontrolü
    // Gerekli dizinlerin oluşturulması
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Veritabanını başlatan metod
  Future<void> _initializeDatabase() async {
    try {
      // Web platformunda database başlatma işlemini atla
      if (kIsWeb) {
        // ignore: avoid_print
        AppLogger.info('Skipping database initialization on web platform');
        await Future.delayed(const Duration(milliseconds: 500));
        return;
      }

      // Database'i başlat - Removed - using Firebase only
      // await DatabaseHelper.getDatabase();

      // Test verilerini yükle
      // await TestDataHelper().loadTestData(); // Removed - using Firebase only

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // ignore: avoid_print
      AppLogger.error('Database initialization failed', e);
      // Web platformunda hata fırlatma
      if (!kIsWeb) {
        rethrow;
      }
    }
  }

  /// Kullanıcı oturum durumunu kontrol eden metod
  Future<void> _checkUserAuthentication() async {
    // SharedPreferences'tan remember_me ayarını oku
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me');
      if (rememberMe == false) {
        // Kullanıcı unutulmak istendi; mevcut oturumu kapat
        try {
          await FirebaseAuth.instance.signOut();
          AppLogger.info('User session cleared due to remember_me = false');
        } catch (_) {}
        // Temizlik: güvenli saklanan bilgileri ve cache'i temizle
        try {
          const storage = FlutterSecureStorage();
          await storage.delete(key: 'cred_email');
          await storage.delete(key: 'cred_password');
        } catch (_) {}
        try {
          await DataCache().clearAllDataCache();
        } catch (_) {}
      }
    } catch (_) {}

    // Firebase Auth durumunu kontrol et
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AppLogger.info('Auto-login: User is already signed in (${user.email})');
      } else {
        AppLogger.info(
            'Auto-login: No user session found, will redirect to login');
      }
    } catch (e) {
      AppLogger.error('Auto-login check failed', e);
    }

    // Kısa bir bekleme ile UI'ı güncel tut
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Uygulama ayarlarını yükleyen metod
  Future<void> _loadAppSettings() async {
    // Tema ayarlarını yükle (açık/koyu)
    // Dil ayarlarını yükle
    // Para birimi ayarlarını yükle
    // Notification ayarlarını yükle
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Splash ekranını yeniden başlatma metodu
  void restart() {
    state = const SplashData(
      state: SplashState.loading,
      progress: 0,
      message: 'Tamgacı Yükleniyor...',
    );
    initializeApp();
  }
}

// ========== PROVIDERS ==========

/// Splash state provider'ı
final splashProvider = StateNotifierProvider<SplashNotifier, SplashData>(
  (ref) => SplashNotifier(),
);

/// Splash tamamlanma durumunu kontrol eden provider
final isSplashCompleteProvider = Provider<bool>((ref) {
  final splashData = ref.watch(splashProvider);
  return splashData.state == SplashState.ready && splashData.progress == 100;
});

/// Splash hata durumunu kontrol eden provider
final splashErrorProvider = Provider<String?>((ref) {
  final splashData = ref.watch(splashProvider);
  return splashData.state == SplashState.error ? splashData.errorMessage : null;
});

// ========== SPLASH SCREEN WIDGET ==========

/// Tamgaci uygulaması splash ekranı
class SplashScreen extends ConsumerStatefulWidget {
  /// Ana sayfa route'u
  final String homeRoute;

  /// Login sayfa route'u
  final String? loginRoute;

  /// Splash ekranı constructor'ı
  const SplashScreen({
    super.key,
    required this.homeRoute,
    this.loginRoute,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ========== ANİMASYON KONTROLLERİ ==========

  /// Logo fade animasyon controller'ı
  late AnimationController _fadeController;

  /// Logo scale animasyon controller'ı
  late AnimationController _scaleController;

  /// Progress bar animasyon controller'ı
  late AnimationController _progressController;

  /// Logo fade animasyonu
  late Animation<double> _fadeAnimation;

  /// Logo scale animasyonu
  late Animation<double> _scaleAnimation;

  /// Progress bar animasyonu
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  /// Animasyonları başlatan metod
  void _initializeAnimations() {
    // Fade animasyon controller'ı
    _fadeController = AnimationController(
      duration: TamgaciConstants.animationSlow,
      vsync: this,
    );

    // Scale animasyon controller'ı
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Progress animasyon controller'ı
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Fade animasyonu
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Scale animasyonu
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Progress animasyonu
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  /// Splash sekanısını başlatan metod
  void _startSplashSequence() {
    // Animasyonları başlat
    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _progressController.forward();
    });

    // Splash sürecini başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashProvider.notifier).initializeApp();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Precache the logo once we have a BuildContext to avoid initial flicker
    // on first frame when the SVG is decoded.
    precacheImage(
        const AssetImage('assets/images/logos/180x180logo.png'), context);
    // Splash verilerini dinle
    ref.listen<SplashData>(splashProvider, (previous, current) {
      // Splash tamamlandığında yönlendirme yap
      if (current.state == SplashState.ready && current.progress == 100) {
        _navigateToHome();
      }
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TamgaciConstants.backgroundColorDark
          : TamgaciConstants.backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildBackgroundDecoration(isDark),
          child: _buildSplashContent(),
        ),
      ),
    );
  }

  /// Arka plan dekorasyonunu oluşturan metod
  BoxDecoration _buildBackgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                TamgaciConstants.backgroundColorDark,
                TamgaciConstants.surfaceColorDark,
              ]
            : [
                TamgaciConstants.backgroundColor,
                TamgaciConstants.surfaceColor,
              ],
        stops: const [0.0, 1.0],
      ),
    );
  }

  /// Ana splash içeriğini oluşturan metod
  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Üst boşluk
        const Spacer(flex: 2),

        // Logo ve başlık bölümü
        _buildLogoSection(),

        const Spacer(flex: 1),

        // İlerleme bölümü
        _buildProgressSection(),

        // Alt boşluk
        const Spacer(flex: 2),

        // Alt bilgi bölümü
        _buildFooterSection(),
      ],
    );
  }

  /// Logo bölümünü oluşturan metod
  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Uygulama logosu
                _buildAppLogo(),

                const SizedBox(height: TamgaciConstants.spaceLG),

                // Uygulama başlığı
                _buildAppTitle(),

                const SizedBox(height: TamgaciConstants.spaceSM),

                // Uygulama açıklaması
                _buildAppDescription(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Uygulama logosunu oluşturan metod
  Widget _buildAppLogo() {
    final double size = TamgaciConstants.getResponsiveValue(
      context,
      mobile: 120.0,
      tablet: 140.0,
      desktop: 160.0,
      wideDesktop: 180.0,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: TamgaciConstants.radiusXL,
            tablet: TamgaciConstants.radiusXL,
            desktop: 28.0,
            wideDesktop: 32.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: TamgaciConstants.radiusXL,
            tablet: TamgaciConstants.radiusXL,
            desktop: 28.0,
            wideDesktop: 32.0,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Logo (asset), yoksa ikon fallback
            _buildLogoSvg(),
            // Premium parıltı efekti
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
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
            // Alt sağ köşe vurgusu
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logo widget'ını oluşturur (PNG logo kullanır)
  Widget _buildLogoSvg() {
    final double size = TamgaciConstants.getResponsiveValue(
      context,
      mobile: 120.0,
      tablet: 140.0,
      desktop: 160.0,
      wideDesktop: 180.0,
    );

    // Responsive logo boyutuna göre uygun PNG dosyasını seç
    String logoPath;
    if (size <= 120) {
      logoPath = 'assets/images/logos/140x140logo.png'; // 120 için en yakın
    } else if (size <= 140) {
      logoPath = 'assets/images/logos/140x140logo.png';
    } else if (size <= 160) {
      logoPath = 'assets/images/logos/160x160logo.png';
    } else {
      logoPath = 'assets/images/logos/180x180logo.png';
    }

    return Image.asset(
      logoPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: Colors.white,
      colorBlendMode: BlendMode.srcIn,
    );
  }

  /// Uygulama başlığını oluşturan metod
  Widget _buildAppTitle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
            : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
      ).createShader(bounds),
      child: Text(
        TamgaciConstants.appName,
        style: GoogleFonts.poppins(
          fontSize: TamgaciConstants.getResponsiveValue(
            context,
            mobile: 34.0,
            tablet: 38.0,
            desktop: 42.0,
            wideDesktop: 46.0,
          ),
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.5,
          height: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Uygulama açıklamasını oluşturan metod
  Widget _buildAppDescription() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      TamgaciConstants.appDescription,
      style: GoogleFonts.poppins(
        fontSize: TamgaciConstants.getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
          wideDesktop: 22.0,
        ),
        fontWeight: FontWeight.w400,
        color: isDark
            ? TamgaciConstants.textSecondaryDark
            : TamgaciConstants.textSecondary,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// İlerleme bölümünü oluşturan metod
  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _progressAnimation.value,
          child: Consumer(
            builder: (context, ref, child) {
              final splashData = ref.watch(splashProvider);

              return Container(
                padding: TamgaciConstants.paddingMedium(context),
                child: Column(
                  children: [
                    // İlerleme çubuğu
                    _buildProgressBar(splashData.progress),

                    const SizedBox(height: TamgaciConstants.spaceMD),

                    // Durum mesajı
                    _buildStatusMessage(splashData.message),

                    // Hata mesajı (varsa)
                    if (splashData.errorMessage != null)
                      _buildErrorMessage(splashData.errorMessage!),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// İlerleme çubuğunu oluşturan metod
  Widget _buildProgressBar(int progress) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 300.0,
        tablet: 340.0,
        desktop: 380.0,
        wideDesktop: 420.0,
      ),
      height: 8.0,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Stack(
          children: [
            // Arka plan
            Container(
              width: double.infinity,
              height: double.infinity,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            // İlerleme çubuğu
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: isDark
                        ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                        : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Parlama efekti
            if (progress > 0)
              Positioned(
                left: (progress / 100.0) *
                        TamgaciConstants.getResponsiveValue(
                          context,
                          mobile: 300.0,
                          tablet: 340.0,
                          desktop: 380.0,
                          wideDesktop: 420.0,
                        ) -
                    20,
                child: Container(
                  width: 20,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Durum mesajını oluşturan metod
  Widget _buildStatusMessage(String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      message,
      style: GoogleFonts.poppins(
        fontSize: TamgaciConstants.getResponsiveValue(
          context,
          mobile: 14.0,
          tablet: 15.0,
          desktop: 16.0,
          wideDesktop: 17.0,
        ),
        fontWeight: FontWeight.w500,
        color: isDark
            ? TamgaciConstants.textSecondaryDark
            : TamgaciConstants.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Hata mesajını oluşturan metod
  Widget _buildErrorMessage(String errorMessage) {
    return Column(
      children: [
        const SizedBox(height: TamgaciConstants.spaceMD),
        Container(
          padding: const EdgeInsets.all(TamgaciConstants.spaceMD),
          decoration: BoxDecoration(
            color: TamgaciConstants.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
            border: Border.all(
              color: TamgaciConstants.errorColor.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Hata ikonu
              const Icon(
                Icons.error_outline,
                color: TamgaciConstants.errorColor,
                size: 32,
              ),

              const SizedBox(height: TamgaciConstants.spaceSM),

              // Hata mesajı
              Text(
                errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: TamgaciConstants.errorColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: TamgaciConstants.spaceMD),

              // Tekrar dene butonu
              TextButton(
                onPressed: () {
                  ref.read(splashProvider.notifier).restart();
                },
                child: Text(
                  'Tekrar Dene',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: TamgaciConstants.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Alt bilgi bölümünü oluşturan metod
  Widget _buildFooterSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Versiyon bilgisi
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 6.0,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: Text(
            'v${TamgaciConstants.appVersion}',
            style: GoogleFonts.poppins(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: TamgaciConstants.spaceSM),

        // Copyright
        Text(
          '© 2024 Tamgaci. Tüm hakları saklıdır.',
          style: GoogleFonts.poppins(
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Ana sayfaya yönlendirme metodu
  void _navigateToHome() {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Delay'i kaldırdık - hemen yönlendir
    if (!mounted) return;

    // Firebase Auth durumunu kontrol et
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı giriş yapmış - dashboard'a yönlendir
      AppLogger.info('User is signed in, navigating to dashboard');
      Navigator.of(context).pushReplacementNamed(widget.homeRoute);
    } else {
      // Kullanıcı giriş yapmamış - login sayfasına yönlendir
      AppLogger.info('User is not signed in, navigating to login');
      Navigator.of(context).pushReplacementNamed(widget.loginRoute ?? '/login');
    }
  }
}

// ========== HELPER WIDGET'LAR ==========

/// Splash ekranı yükleme indikatörü widget'ı
class SplashLoadingIndicator extends StatelessWidget {
  /// İlerleme yüzdesi
  final double progress;

  /// İndikatör rengi
  final Color? color;

  /// İndikatör boyutu
  final double size;

  const SplashLoadingIndicator({
    super.key,
    required this.progress,
    this.color,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progress / 100,
        backgroundColor: TamgaciConstants.borderColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? TamgaciConstants.primaryColor,
        ),
        strokeWidth: 3.0,
      ),
    );
  }
}

/// Splash ekranı için özel error widget'ı
class SplashErrorWidget extends StatelessWidget {
  /// Hata mesajı
  final String message;

  /// Tekrar dene callback'i
  final VoidCallback? onRetry;

  const SplashErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(TamgaciConstants.spaceLG),
      padding: const EdgeInsets.all(TamgaciConstants.spaceLG),
      decoration: BoxDecoration(
        color: TamgaciConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
        border: Border.all(
          color: TamgaciConstants.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 48,
            color: TamgaciConstants.errorColor,
          ),
          const SizedBox(height: TamgaciConstants.spaceMD),
          Text(
            'Bir Sorun Oluştu',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TamgaciConstants.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TamgaciConstants.spaceSM),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: TamgaciConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: TamgaciConstants.spaceLG),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ],
      ),
    );
  }
}
