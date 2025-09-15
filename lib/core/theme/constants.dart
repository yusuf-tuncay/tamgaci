import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama renkleri
class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color accent = Color(0xFFFF4081);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

/// Tamgaci Ön Muhasebe Uygulaması - Ana Sabitler Sınıfı
/// Tüm UI bileşenleri, renkler, boyutlar ve responsive ayarlar burada tanımlanır
class TamgaciConstants {
  // ========== UYGULAMA BİLGİLERİ ==========

  /// Uygulamanın adı
  static const String appName = 'TAMGACI';

  /// Uygulamanın versiyonu
  static const String appVersion = '1.0.0';

  /// Uygulamanın açıklaması
  static const String appDescription = 'Ön Muhasebe Uygulaması';

  // ========== RESPONSIVE BREAKPOINTS ==========

  /// Mobil cihazlar için maksimum genişlik (0-599px)
  static const double mobileBreakpoint = 600.0;

  /// Tablet cihazlar için maksimum genişlik (600-899px)
  static const double tabletBreakpoint = 900.0;

  /// Masaüstü cihazlar için minimum genişlik (900px+)
  static const double desktopBreakpoint = 1200.0;

  /// Geniş masaüstü cihazlar için minimum genişlik (1200px+)
  static const double wideDesktopBreakpoint = 1200.0;

  // ========== MEDIA QUERY HELPER METODLARI ==========

  /// Mevcut ekranın mobil olup olmadığını kontrol eder
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Mevcut ekranın tablet olup olmadığını kontrol eder
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Mevcut ekranın masaüstü olup olmadığını kontrol eder
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Mevcut ekranın geniş masaüstü olup olmadığını kontrol eder
  static bool isWideDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= wideDesktopBreakpoint;
  }

  /// Ekran genişliğine göre responsive değer döndürür
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wideDesktop,
  }) {
    if (isWideDesktop(context) && wideDesktop != null) return wideDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // ========== RENK PALETİ - AÇIK TEMA ==========

  // Ana Renkler
  /// Uygulamanın ana rengi - Mavi tonu
  static const Color primaryColor = Color(0xFF2196F3);

  /// Ana rengin açık tonu
  static const Color primaryLight = Color(0xFFBBDEFB);

  /// Ana rengin koyu tonu
  static const Color primaryDark = Color(0xFF1976D2);

  /// İkincil renk - Yeşil tonu (Muhasebe için uygun)
  static const Color secondaryColor = Color(0xFF4CAF50);

  /// İkincil rengin açık tonu
  static const Color secondaryLight = Color(0xFFC8E6C9);

  /// İkincil rengin koyu tonu
  static const Color secondaryDark = Color(0xFF388E3C);

  // Arka Plan Renkleri
  /// Ana arka plan rengi - Beyaz
  static const Color backgroundColor = Color(0xFFFFFFFF);

  /// İkincil arka plan rengi - Çok açık gri
  static const Color surfaceColor = Color(0xFFFAFAFA);

  /// Kart ve yükseltilmiş elemanlar için arka plan
  static const Color cardColor = Color(0xFFFFFFFF);

  // ========== RENK PALETİ - KOYU TEMA ==========

  // Koyu Tema Ana Renkler
  /// Koyu tema ana rengi - Açık mavi
  static const Color primaryColorDark = Color(0xFF64B5F6);

  /// Koyu tema ana rengin açık tonu
  static const Color primaryLightDark = Color(0xFFE3F2FD);

  /// Koyu tema ana rengin koyu tonu
  static const Color primaryDarkDark = Color(0xFF42A5F5);

  /// Koyu tema ikincil renk - Açık yeşil
  static const Color secondaryColorDark = Color(0xFF81C784);

  /// Koyu tema ikincil rengin açık tonu
  static const Color secondaryLightDark = Color(0xFFE8F5E8);

  /// Koyu tema ikincil rengin koyu tonu
  static const Color secondaryDarkDark = Color(0xFF66BB6A);

  // Koyu Tema Arka Plan Renkleri
  /// Koyu tema ana arka plan rengi - Orta koyu gri (daha açık)
  static const Color backgroundColorDark = Color(0xFF2C2C2C);

  /// Koyu tema ikincil arka plan rengi - Açık koyu gri
  static const Color surfaceColorDark = Color(0xFF3A3A3A);

  /// Koyu tema kart arka plan rengi - Orta gri
  static const Color cardColorDark = Color(0xFF424242);

  /// App bar arka plan rengi
  static const Color appBarColor = Color(0xFFFFFFFF);

  // Metin Renkleri - Açık Tema
  /// Birincil metin rengi - Koyu gri
  static const Color textPrimary = Color(0xFF212121);

  /// İkincil metin rengi - Orta gri
  static const Color textSecondary = Color(0xFF757575);

  /// Devre dışı metin rengi - Açık gri
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Beyaz metin rengi (koyu arka planlar için)
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Metin Renkleri - Koyu Tema
  /// Koyu tema birincil metin rengi - Beyaz
  static const Color textPrimaryDark = Color(0xFFE0E0E0);

  /// Koyu tema ikincil metin rengi - Açık gri
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Koyu tema devre dışı metin rengi - Orta gri
  static const Color textDisabledDark = Color(0xFF666666);

  /// Koyu tema beyaz metin rengi
  static const Color textOnPrimaryDark = Color(0xFF000000);

  // Durum Renkleri
  /// Başarı durumu rengi - Yeşil
  static const Color successColor = Color(0xFF4CAF50);

  /// Uyarı durumu rengi - Turuncu
  static const Color warningColor = Color(0xFFFF9800);

  /// Hata durumu rengi - Kırmızı
  static const Color errorColor = Color(0xFFF44336);

  /// Bilgi durumu rengi - Mavi
  static const Color infoColor = Color(0xFF2196F3);

  // Çizgi ve Kenarlık Renkleri
  /// Ana kenarlık rengi
  static const Color borderColor = Color(0xFFE0E0E0);

  /// Bölücü çizgi rengi
  static const Color dividerColor = Color(0xFFBDBDBD);

  /// Gölge rengi
  static const Color shadowColor = Color(0x1F000000);

  // ========== TEMA HELPER METODLARI ==========

  /// Mevcut temaya göre ana rengi döndürür
  static Color getPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? primaryColorDark : primaryColor;
  }

  /// Mevcut temaya göre arka plan rengini döndürür
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? backgroundColorDark
        : backgroundColor;
  }

  /// Mevcut temaya göre yüzey rengini döndürür
  static Color getSurfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? surfaceColorDark : surfaceColor;
  }

  /// Mevcut temaya göre kart rengini döndürür
  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? cardColorDark : cardColor;
  }

  /// Mevcut temaya göre birincil metin rengini döndürür
  static Color getTextPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? textPrimaryDark : textPrimary;
  }

  /// Mevcut temaya göre ikincil metin rengini döndürür
  static Color getTextSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? textSecondaryDark : textSecondary;
  }

  /// Mevcut temaya göre devre dışı metin rengini döndürür
  static Color getTextDisabledColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? textDisabledDark : textDisabled;
  }

  // ========== TİPOGRAFİ - GOOGLE FONTS POPPINS ==========

  /// Başlık fontları için temel stil
  static TextStyle get _baseHeadingStyle =>
      GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600);

  /// Metin fontları için temel stil
  static TextStyle get _baseBodyStyle =>
      GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w400);

  // Responsive Font Boyutları
  /// H1 başlık stili - Responsive
  static TextStyle h1(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 24.0,
          tablet: 28.0,
          desktop: 32.0,
          wideDesktop: 36.0,
        ),
        fontWeight: FontWeight.w700,
      );

  /// H2 başlık stili - Responsive
  static TextStyle h2(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 22.0,
          tablet: 24.0,
          desktop: 28.0,
          wideDesktop: 30.0,
        ),
        fontWeight: FontWeight.w600,
      );

  /// H3 başlık stili - Responsive
  static TextStyle h3(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 20.0,
          tablet: 22.0,
          desktop: 24.0,
          wideDesktop: 26.0,
        ),
        fontWeight: FontWeight.w600,
      );

  /// H4 başlık stili - Responsive
  static TextStyle h4(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 18.0,
          tablet: 20.0,
          desktop: 22.0,
          wideDesktop: 24.0,
        ),
        fontWeight: FontWeight.w500,
      );

  /// H5 başlık stili - Responsive
  static TextStyle h5(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
          wideDesktop: 22.0,
        ),
        fontWeight: FontWeight.w500,
      );

  /// H6 başlık stili - Responsive
  static TextStyle h6(BuildContext context) => _baseHeadingStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 14.0,
          tablet: 16.0,
          desktop: 18.0,
          wideDesktop: 20.0,
        ),
        fontWeight: FontWeight.w500,
      );

  // Gövde Metinleri
  /// Büyük gövde metni - Responsive
  static TextStyle bodyLarge(BuildContext context) => _baseBodyStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 16.0,
          tablet: 17.0,
          desktop: 18.0,
          wideDesktop: 19.0,
        ),
      );

  /// Orta gövde metni - Responsive
  static TextStyle bodyMedium(BuildContext context) => _baseBodyStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 14.0,
          tablet: 15.0,
          desktop: 16.0,
          wideDesktop: 17.0,
        ),
      );

  /// Küçük gövde metni - Responsive
  static TextStyle bodySmall(BuildContext context) => _baseBodyStyle.copyWith(
        fontSize: getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 13.0,
          desktop: 14.0,
          wideDesktop: 15.0,
        ),
        color: textSecondary,
      );

  // Özel Metin Stilleri
  /// Buton metni stili
  static TextStyle buttonText(BuildContext context) => GoogleFonts.poppins(
        fontSize: getResponsiveValue(
          context,
          mobile: 14.0,
          tablet: 15.0,
          desktop: 16.0,
          wideDesktop: 17.0,
        ),
        fontWeight: FontWeight.w500,
        color: textOnPrimary,
      );

  /// Etiket metni stili
  static TextStyle labelText(BuildContext context) => GoogleFonts.poppins(
        fontSize: getResponsiveValue(
          context,
          mobile: 12.0,
          tablet: 13.0,
          desktop: 14.0,
          wideDesktop: 15.0,
        ),
        fontWeight: FontWeight.w400,
        color: textSecondary,
      );

  /// Vurgu metni stili (kalın)
  static TextStyle emphasizedText(BuildContext context) =>
      bodyMedium(context).copyWith(fontWeight: FontWeight.w600);

  // ========== BOŞLUK SİSTEMİ (SPACING) ==========

  // Sabit Boşluklar
  /// Çok küçük boşluk - 4px
  static const double spaceXS = 4.0;

  /// Küçük boşluk - 8px
  static const double spaceSM = 8.0;

  /// Orta boşluk - 16px
  static const double spaceMD = 16.0;

  /// Büyük boşluk - 24px
  static const double spaceLG = 24.0;

  /// Çok büyük boşluk - 32px
  static const double spaceXL = 32.0;

  /// Mega boşluk - 48px
  static const double spaceXXL = 48.0;

  // Responsive Padding Değerleri
  /// Küçük padding - Responsive
  static EdgeInsets paddingSmall(BuildContext context) => EdgeInsets.all(
        getResponsiveValue(
          context,
          mobile: spaceSM,
          tablet: spaceSM * 1.2,
          desktop: spaceMD,
          wideDesktop: spaceMD * 1.2,
        ),
      );

  /// Orta padding - Responsive
  static EdgeInsets paddingMedium(BuildContext context) => EdgeInsets.all(
        getResponsiveValue(
          context,
          mobile: spaceMD,
          tablet: spaceMD * 1.2,
          desktop: spaceLG,
          wideDesktop: spaceLG * 1.2,
        ),
      );

  /// Büyük padding - Responsive
  static EdgeInsets paddingLarge(BuildContext context) => EdgeInsets.all(
        getResponsiveValue(
          context,
          mobile: spaceLG,
          tablet: spaceLG * 1.2,
          desktop: spaceXL,
          wideDesktop: spaceXL * 1.2,
        ),
      );

  // Özel Padding'ler
  /// Sayfa padding'i (yatay) - Responsive
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: getResponsiveValue(
          context,
          mobile: spaceMD,
          tablet: spaceLG,
          desktop: spaceXL,
          wideDesktop: spaceXXL,
        ),
      );

  /// Kart iç padding'i - Responsive
  static EdgeInsets cardPadding(BuildContext context) => EdgeInsets.all(
        getResponsiveValue(
          context,
          mobile: spaceMD,
          tablet: spaceMD * 1.2,
          desktop: spaceLG,
          wideDesktop: spaceLG * 1.2,
        ),
      );

  /// Liste elemanı padding'i - Responsive
  static EdgeInsets listItemPadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: getResponsiveValue(
          context,
          mobile: spaceMD,
          tablet: spaceMD * 1.2,
          desktop: spaceLG,
          wideDesktop: spaceLG * 1.2,
        ),
        vertical: getResponsiveValue(
          context,
          mobile: spaceSM,
          tablet: spaceSM * 1.2,
          desktop: spaceMD,
          wideDesktop: spaceMD * 1.2,
        ),
      );

  // ========== BORDER RADIUS DEĞERLERİ ==========

  /// Küçük border radius - 4px
  static const double radiusXS = 4.0;

  /// Orta border radius - 8px
  static const double radiusSM = 8.0;

  /// Standart border radius - 12px
  static const double radiusMD = 12.0;

  /// Büyük border radius - 16px
  static const double radiusLG = 16.0;

  /// Çok büyük border radius - 24px
  static const double radiusXL = 24.0;

  /// Tam yuvarlak border radius - 50px
  static const double radiusCircular = 50.0;

  // Responsive Border Radius'lar
  /// Kart border radius'u - Responsive
  static double cardRadius(BuildContext context) => getResponsiveValue(
        context,
        mobile: radiusSM,
        tablet: radiusMD,
        desktop: radiusLG,
        wideDesktop: radiusXL,
      );

  /// Buton border radius'u - Responsive
  static double buttonRadius(BuildContext context) => getResponsiveValue(
        context,
        mobile: radiusSM,
        tablet: radiusMD,
        desktop: radiusMD,
        wideDesktop: radiusLG,
      );

  /// Input field border radius'u - Responsive
  static double inputRadius(BuildContext context) => getResponsiveValue(
        context,
        mobile: radiusSM,
        tablet: radiusSM,
        desktop: radiusMD,
        wideDesktop: radiusMD,
      );

  // ========== BOYUT SİSTEMİ ==========

  // Responsive Yükseklik Değerleri
  /// App bar yüksekliği - Responsive
  static double appBarHeight(BuildContext context) => getResponsiveValue(
        context,
        mobile: 56.0,
        tablet: 64.0,
        desktop: 70.0,
        wideDesktop: 76.0,
      );

  /// Buton yüksekliği - Responsive
  static double buttonHeight(BuildContext context) => getResponsiveValue(
        context,
        mobile: 48.0,
        tablet: 52.0,
        desktop: 56.0,
        wideDesktop: 60.0,
      );

  /// Input field yüksekliği - Responsive
  static double inputHeight(BuildContext context) => getResponsiveValue(
        context,
        mobile: 48.0,
        tablet: 52.0,
        desktop: 56.0,
        wideDesktop: 60.0,
      );

  /// Liste elemanı minimum yüksekliği - Responsive
  static double listItemHeight(BuildContext context) => getResponsiveValue(
        context,
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
        wideDesktop: 80.0,
      );

  // Responsive Genişlik Değerleri
  /// Maksimum içerik genişliği - Responsive
  static double maxContentWidth(BuildContext context) => getResponsiveValue(
        context,
        mobile: double.infinity,
        tablet: 800.0,
        desktop: 1200.0,
        wideDesktop: 1400.0,
      );

  /// Sidebar genişliği - Responsive
  static double sidebarWidth(BuildContext context) => getResponsiveValue(
        context,
        mobile: 280.0,
        tablet: 320.0,
        desktop: 350.0,
        wideDesktop: 380.0,
      );

  // ========== GÖLGE VE ELEVATION ==========

  /// Hafif gölge - Kart elemanları için
  static List<BoxShadow> get shadowLight => [
        const BoxShadow(
          color: shadowColor,
          offset: Offset(0, 1),
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ];

  /// Orta gölge - Modal ve popup'lar için
  static List<BoxShadow> get shadowMedium => [
        const BoxShadow(
          color: shadowColor,
          offset: Offset(0, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Güçlü gölge - Floating action button vb. için
  static List<BoxShadow> get shadowStrong => [
        const BoxShadow(
          color: shadowColor,
          offset: Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  // ========== ANİMASYON SÜRELERİ ==========

  /// Hızlı animasyon süresi - 150ms
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal animasyon süresi - 300ms
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Yavaş animasyon süresi - 500ms
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ========== MUHASEBE UYGULAMASI ÖZEL SABİTLERİ ==========

  /// Para birimi sembolü
  static const String currencySymbol = '₺';

  /// Ondalık basamak sayısı
  static const int decimalPlaces = 2;

  /// Fatura numarası prefix'i
  static const String invoicePrefix = 'FAT';

  /// Fiş numarası prefix'i
  static const String receiptPrefix = 'FIS';

  // Muhasebe Renkleri
  /// Gelir rengi - Yeşil
  static const Color incomeColor = Color(0xFF4CAF50);

  /// Gider rengi - Kırmızı
  static const Color expenseColor = Color(0xFFF44336);

  /// Bekleyen işlem rengi - Turuncu
  static const Color pendingColor = Color(0xFFFF9800);

  /// Tamamlanan işlem rengi - Mavi
  static const Color completedColor = Color(0xFF2196F3);

  // ========== TEMA OLUŞTURUCU METODİ ==========

  /// Uygulamanın açık temasını oluşturur
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Ana renk şeması
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: textOnPrimary,
        onSecondary: textOnPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
      ),

      // Scaffold teması
      scaffoldBackgroundColor: backgroundColor,

      // AppBar teması
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Kart teması
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),

      // Buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSM),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),

      // Input field teması
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSM),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMD,
          vertical: spaceSM,
        ),
        labelStyle: GoogleFonts.poppins(color: textSecondary),
      ),
    );
  }
}

// ========== EXTENSION METODLARI ==========

/// BuildContext için extension metodları
extension ContextExtension on BuildContext {
  /// Responsive padding almak için kısayol metod
  EdgeInsets get smallPadding => TamgaciConstants.paddingSmall(this);
  EdgeInsets get mediumPadding => TamgaciConstants.paddingMedium(this);
  EdgeInsets get largePadding => TamgaciConstants.paddingLarge(this);

  /// Responsive text stilleri için kısayol metodlar
  TextStyle get h1 => TamgaciConstants.h1(this);
  TextStyle get h2 => TamgaciConstants.h2(this);
  TextStyle get h3 => TamgaciConstants.h3(this);
  TextStyle get h4 => TamgaciConstants.h4(this);
  TextStyle get h5 => TamgaciConstants.h5(this);
  TextStyle get h6 => TamgaciConstants.h6(this);
  TextStyle get bodyLarge => TamgaciConstants.bodyLarge(this);
  TextStyle get bodyMedium => TamgaciConstants.bodyMedium(this);
  TextStyle get bodySmall => TamgaciConstants.bodySmall(this);

  /// Cihaz türü kontrolleri için kısayol metodlar
  bool get isMobile => TamgaciConstants.isMobile(this);
  bool get isTablet => TamgaciConstants.isTablet(this);
  bool get isDesktop => TamgaciConstants.isDesktop(this);
  bool get isWideDesktop => TamgaciConstants.isWideDesktop(this);

  /// Responsive boyutlar için kısayol metodlar
  double get appBarHeight => TamgaciConstants.appBarHeight(this);
  double get buttonHeight => TamgaciConstants.buttonHeight(this);
  double get inputHeight => TamgaciConstants.inputHeight(this);
  double get cardRadius => TamgaciConstants.cardRadius(this);
  double get buttonRadius => TamgaciConstants.buttonRadius(this);
}
