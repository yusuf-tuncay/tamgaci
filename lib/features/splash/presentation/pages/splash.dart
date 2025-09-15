import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/core/theme/constants.dart';
// import 'package:tamgaci/core/database/tamgaci_database.dart'; // Removed - using Firebase only
// import 'package:tamgaci/core/database/test_data_helper.dart'; // Removed - using Firebase only
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tamgaci/core/utils/logger.dart';

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
        10,
        'Uygulama başlatılıyor...',
      );
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Adım: İlk kurulum kontrolleri
      await _updateState(
        SplashState.initializing,
        30,
        'Ayarlar kontrol ediliyor...',
      );
      await _performInitialSetup();

      // 3. Adım: Veritabanı bağlantısı kontrolü
      await _updateState(
        SplashState.initializing,
        50,
        'Veritabanı hazırlanıyor...',
      );
      await _initializeDatabase();

      // 4. Adım: Kullanıcı oturum kontrolü
      await _updateState(
        SplashState.checkingAuth,
        70,
        'Oturum bilgileri kontrol ediliyor...',
      );
      await _checkUserAuthentication();

      // 5. Adım: Tema ve dil ayarları
      await _updateState(
        SplashState.initializing,
        85,
        'Tema ayarları yükleniyor...',
      );
      await _loadAppSettings();

      // 6. Adım: Son kontroller ve hazırlık
      await _updateState(
        SplashState.ready,
        100,
        'Tamgacı hazır!',
      );
      await Future.delayed(const Duration(milliseconds: 800));
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
    // Kullanıcının daha önce oturum açıp açmadığını kontrol et
    // Token geçerliliğini kontrol et
    // Biometric authentication durumunu kontrol et
    await Future.delayed(const Duration(milliseconds: 600));
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
    return Container(
      width: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 100.0,
        tablet: 120.0,
        desktop: 140.0,
        wideDesktop: 160.0,
      ),
      height: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 100.0,
        tablet: 120.0,
        desktop: 140.0,
        wideDesktop: 160.0,
      ),
      decoration: BoxDecoration(
        color: TamgaciConstants.primaryColor,
        borderRadius: BorderRadius.circular(
          TamgaciConstants.getResponsiveValue(
            context,
            mobile: TamgaciConstants.radiusLG,
            tablet: TamgaciConstants.radiusXL,
            desktop: TamgaciConstants.radiusXL,
            wideDesktop: 28.0,
          ),
        ),
        boxShadow: TamgaciConstants.shadowMedium,
      ),
      child: Center(
        child: Icon(
          Icons.account_balance,
          size: TamgaciConstants.getResponsiveValue(
            context,
            mobile: 50.0,
            tablet: 60.0,
            desktop: 70.0,
            wideDesktop: 80.0,
          ),
          color: TamgaciConstants.textOnPrimary,
        ),
      ),
    );
  }

  /// Uygulama başlığını oluşturan metod
  Widget _buildAppTitle() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      TamgaciConstants.appName,
      style: GoogleFonts.poppins(
        fontSize: TamgaciConstants.getResponsiveValue(
          context,
          mobile: 32.0,
          tablet: 36.0,
          desktop: 40.0,
          wideDesktop: 44.0,
        ),
        fontWeight: FontWeight.w700,
        color: isDark
            ? TamgaciConstants.primaryColorDark
            : TamgaciConstants.primaryColor,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
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
    return Container(
      width: TamgaciConstants.getResponsiveValue(
        context,
        mobile: 280.0,
        tablet: 320.0,
        desktop: 360.0,
        wideDesktop: 400.0,
      ),
      height: 6.0,
      decoration: BoxDecoration(
        color: TamgaciConstants.borderColor,
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusXS),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress / 100.0,
        child: Container(
          decoration: BoxDecoration(
            color: TamgaciConstants.primaryColor,
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusXS),
          ),
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
        Text(
          'v${TamgaciConstants.appVersion}',
          style: GoogleFonts.poppins(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: isDark
                ? TamgaciConstants.textDisabledDark
                : TamgaciConstants.textDisabled,
          ),
        ),

        const SizedBox(height: TamgaciConstants.spaceXS),

        // Copyright
        Text(
          '© 2024 Tamgaci. Tüm hakları saklıdır.',
          style: GoogleFonts.poppins(
            fontSize: 11.0,
            fontWeight: FontWeight.w300,
            color: isDark
                ? TamgaciConstants.textDisabledDark
                : TamgaciConstants.textDisabled,
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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(widget.homeRoute);
      }
    });
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
