import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tamgaci/core/theme/constants.dart';

// ========== TEMA TİPLERİ ==========

/// Tema türlerini tanımlayan enum
enum ThemeType {
  /// Açık tema
  light,

  /// Koyu tema (gelecek kullanım için)
  dark,
}

/// Tamgaci Ön Muhasebe Uygulaması - Tema Konfigürasyon Sınıfı
/// Tüm Material Design 3 bileşenleri için detaylı tema ayarları
class TamgaciTheme {
  // ========== ANA TEMA OLUŞTURUCU METODLARI ==========

  /// Açık tema konfigürasyonunu döndürür
  static ThemeData getLightTheme() {
    return ThemeData(
      // Material 3 tasarım sistemini etkinleştir
      useMaterial3: true,

      // Temanın parlaklık seviyesi
      brightness: Brightness.light,

      // Ana renk şeması
      colorScheme: _getLightColorScheme(),

      // Font ailesi - Tüm uygulama için Poppins
      fontFamily: GoogleFonts.poppins().fontFamily,

      // Scaffold (Ana iskelet) teması
      scaffoldBackgroundColor: TamgaciConstants.backgroundColor,

      // Sayfa geçişleri için varsayılan animasyon süresi
      pageTransitionsTheme: _getPageTransitionsTheme(),

      // Material renk teması (legacy desteği için)
      primarySwatch: Colors.blue,
      primaryColor: TamgaciConstants.primaryColor,

      // Vurgu rengi
      highlightColor: TamgaciConstants.primaryLight.withValues(alpha: 0.2),

      // Splash rengi (dokunma efekti)
      splashColor: TamgaciConstants.primaryColor.withValues(alpha: 0.1),

      // Hover rengi (masaüstü için)
      hoverColor: TamgaciConstants.primaryColor.withValues(alpha: 0.04),

      // Odak rengi
      focusColor: TamgaciConstants.primaryColor.withValues(alpha: 0.12),

      // Bölücü rengi
      dividerColor: TamgaciConstants.dividerColor,

      // ========== WIDGET TEMALARI ==========

      // AppBar teması
      appBarTheme: _getAppBarTheme(),

      // Buton temaları
      elevatedButtonTheme: _getElevatedButtonTheme(),
      textButtonTheme: _getTextButtonTheme(),
      outlinedButtonTheme: _getOutlinedButtonTheme(),
      filledButtonTheme: _getFilledButtonTheme(),

      // FloatingActionButton teması
      floatingActionButtonTheme: _getFloatingActionButtonTheme(),

      // Input (Metin Giriş) alanları teması
      inputDecorationTheme: _getInputDecorationTheme(),

      // Kart teması
      cardTheme: _getCardThemeData(),

      // Liste elemanları teması
      listTileTheme: _getListTileTheme(),

      // Dialog temaları
      dialogTheme: _getDialogTheme(),
      bottomSheetTheme: _getBottomSheetTheme(),

      // Navigasyon temaları
      bottomNavigationBarTheme: _getBottomNavigationBarTheme(),
      navigationBarTheme: _getNavigationBarTheme(),
      navigationDrawerTheme: _getNavigationDrawerTheme(),

      // Tab teması
      tabBarTheme: _getTabBarTheme(),

      // Checkbox, Radio, Switch temaları
      checkboxTheme: _getCheckboxTheme(),
      radioTheme: _getRadioTheme(),
      switchTheme: _getSwitchTheme(),

      // Slider teması
      sliderTheme: _getSliderTheme(),

      // Progress indicator temaları
      progressIndicatorTheme: _getProgressIndicatorTheme(),

      // Snackbar teması
      snackBarTheme: _getSnackBarTheme(),

      // Tooltip teması
      tooltipTheme: _getTooltipTheme(),

      // Divider teması
      dividerTheme: _getDividerTheme(),

      // Chip teması
      chipTheme: _getChipTheme(),

      // DataTable teması
      dataTableTheme: _getDataTableTheme(),

      // ExpansionTile teması
      expansionTileTheme: _getExpansionTileTheme(),

      // MenuBar teması
      menuBarTheme: _getMenuBarTheme(),
      menuButtonTheme: _getMenuButtonTheme(),

      // SearchBar teması
      searchBarTheme: _getSearchBarTheme(),

      // Icon teması
      iconTheme: _getIconTheme(),
      primaryIconTheme: _getPrimaryIconTheme(),

      // Text teması
      textTheme: _getTextTheme(),
      primaryTextTheme: _getPrimaryTextTheme(),
    );
  }

  /// Koyu tema konfigürasyonunu döndürür
  static ThemeData getDarkTheme() {
    return ThemeData(
      // Material 3 tasarım sistemini etkinleştir
      useMaterial3: true,

      // Temanın parlaklık seviyesi
      brightness: Brightness.dark,

      // Ana renk şeması
      colorScheme: _getDarkColorScheme(),

      // Font ailesi - Tüm uygulama için Poppins
      fontFamily: GoogleFonts.poppins().fontFamily,

      // Scaffold (Ana iskelet) teması
      scaffoldBackgroundColor: TamgaciConstants.backgroundColorDark,

      // Sayfa geçişleri için varsayılan animasyon süresi
      pageTransitionsTheme: _getPageTransitionsTheme(),

      // Material renk teması (legacy desteği için)
      primarySwatch: Colors.blue,
      primaryColor: TamgaciConstants.primaryColorDark,

      // Vurgu rengi
      highlightColor: TamgaciConstants.primaryLightDark.withValues(alpha: 0.2),

      // Splash rengi (dokunma efekti)
      splashColor: TamgaciConstants.primaryColorDark.withValues(alpha: 0.1),

      // Hover rengi (masaüstü için)
      hoverColor: TamgaciConstants.primaryColorDark.withValues(alpha: 0.04),

      // Odak rengi
      focusColor: TamgaciConstants.primaryColorDark.withValues(alpha: 0.12),

      // Bölücü rengi
      dividerColor: TamgaciConstants.dividerColorDark,

      // ========== WIDGET TEMALARI ==========

      // AppBar teması
      appBarTheme: _getDarkAppBarTheme(),

      // Buton temaları
      elevatedButtonTheme: _getDarkElevatedButtonTheme(),
      textButtonTheme: _getDarkTextButtonTheme(),
      outlinedButtonTheme: _getDarkOutlinedButtonTheme(),
      filledButtonTheme: _getDarkFilledButtonTheme(),

      // Input field teması
      inputDecorationTheme: _getDarkInputDecorationTheme(),

      // Kart teması
      cardTheme: _getDarkCardThemeData(),

      // Liste elemanı teması
      listTileTheme: _getDarkListTileTheme(),

      // Chip teması
      chipTheme: _getDarkChipTheme(),

      // Dialog teması
      dialogTheme: _getDarkDialogThemeData(),

      // Bottom sheet teması
      bottomSheetTheme: _getDarkBottomSheetTheme(),

      // Drawer teması
      drawerTheme: _getDarkDrawerTheme(),

      // Menu button teması
      menuButtonTheme: _getDarkMenuButtonTheme(),

      // SearchBar teması
      searchBarTheme: _getDarkSearchBarTheme(),

      // Icon teması
      iconTheme: _getDarkIconTheme(),
      primaryIconTheme: _getDarkPrimaryIconTheme(),

      // Text teması
      textTheme: _getDarkTextTheme(),
      primaryTextTheme: _getDarkPrimaryTextTheme(),
    );
  }

  // ========== RENK ŞEMALARI ==========

  /// Açık tema renk şeması
  static ColorScheme _getLightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: TamgaciConstants.primaryColor,
      brightness: Brightness.light,
      primary: TamgaciConstants.primaryColor,
      primaryContainer: TamgaciConstants.primaryLight,
      secondary: TamgaciConstants.secondaryColor,
      secondaryContainer: TamgaciConstants.secondaryLight,
      surface: TamgaciConstants.surfaceColor,
      error: TamgaciConstants.errorColor,
      onPrimary: TamgaciConstants.textOnPrimary,
      onSecondary: TamgaciConstants.textOnPrimary,
      onSurface: TamgaciConstants.textPrimary,
      onError: TamgaciConstants.textOnPrimary,
    );
  }

  /// Koyu tema renk şeması
  static ColorScheme _getDarkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: TamgaciConstants.primaryColorDark,
      brightness: Brightness.dark,
      primary: TamgaciConstants.primaryColorDark,
      primaryContainer: TamgaciConstants.primaryLightDark,
      secondary: TamgaciConstants.secondaryColorDark,
      secondaryContainer: TamgaciConstants.secondaryLightDark,
      surface: TamgaciConstants.surfaceColorDark,
      error: TamgaciConstants.errorColor,
      onPrimary: TamgaciConstants.textOnPrimaryDark,
      onSecondary: TamgaciConstants.textOnPrimaryDark,
      onSurface: TamgaciConstants.textPrimaryDark,
      onError: TamgaciConstants.textOnPrimaryDark,
    );
  }

  // ========== SAYFA GEÇİŞ ANİMASYONLARI ==========

  /// Sayfa geçiş animasyonları teması
  static PageTransitionsTheme _getPageTransitionsTheme() {
    return const PageTransitionsTheme(
      builders: {
        // Android için yumuşak geçiş
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        // iOS için doğal geçiş
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        // Masaüstü platformlar için fade geçiş
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );
  }

  // ========== APPBAR TEMASI ==========

  /// AppBar bileşeni için tema ayarları
  static AppBarTheme _getAppBarTheme() {
    return AppBarTheme(
      // AppBar arka plan rengi
      backgroundColor: TamgaciConstants.appBarColor,

      // AppBar üzerindeki yazı ve ikon rengi
      foregroundColor: TamgaciConstants.textPrimary,

      // AppBar yükseklik efekti (Material 3'te 0 önerilir)
      elevation: 0,

      // AppBar altındaki gölge rengi
      shadowColor: TamgaciConstants.shadowColor,

      // AppBar yüzey renk tonu
      surfaceTintColor: Colors.transparent,

      // Başlığın ortada olup olmayacağı
      centerTitle: true,

      // Başlık metin stili
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.15,
      ),

      // Toolbar metinleri stili
      toolbarTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
      ),

      // AppBar yüksekliği
      toolbarHeight: 64.0,

      // İkon temaları
      iconTheme: const IconThemeData(
        color: TamgaciConstants.textPrimary,
        size: 24,
      ),

      // Actions (sağdaki) iconları teması
      actionsIconTheme: const IconThemeData(
        color: TamgaciConstants.textPrimary,
        size: 24,
      ),

      // Sistem UI overlay stili (durum çubuğu)
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  // ========== BUTON TEMALARI ==========

  /// ElevatedButton (Yükseltilmiş buton) teması
  static ElevatedButtonThemeData _getElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Buton arka plan rengi
        backgroundColor: TamgaciConstants.primaryColor,

        // Buton üzerindeki yazı rengi
        foregroundColor: TamgaciConstants.textOnPrimary,

        // Hover durumu rengi
        overlayColor: TamgaciConstants.textOnPrimary.withValues(alpha: 0.08),

        // Buton yükseklik efekti
        elevation: 2,

        // Gölge rengi
        shadowColor: TamgaciConstants.shadowColor,

        // Buton şekli ve border radius
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),

        // Buton minimum boyutu
        minimumSize: const Size(88, 48),

        // Buton padding değerleri
        padding: const EdgeInsets.symmetric(
          horizontal: TamgaciConstants.spaceLG,
          vertical: TamgaciConstants.spaceSM,
        ),

        // Buton metni stili
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),

        // Animasyon süresi
        animationDuration: TamgaciConstants.animationNormal,
      ),
    );
  }

  /// TextButton (Metin buton) teması
  static TextButtonThemeData _getTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        // Buton metin rengi
        foregroundColor: TamgaciConstants.primaryColor,

        // Hover/basma efekti rengi
        overlayColor: TamgaciConstants.primaryColor.withValues(alpha: 0.08),

        // Buton şekli
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),

        // Buton padding değerleri
        padding: const EdgeInsets.symmetric(
          horizontal: TamgaciConstants.spaceMD,
          vertical: TamgaciConstants.spaceSM,
        ),

        // Buton minimum boyutu
        minimumSize: const Size(64, 40),

        // Buton metni stili
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// OutlinedButton (Çerçeveli buton) teması
  static OutlinedButtonThemeData _getOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        // Buton metin rengi
        foregroundColor: TamgaciConstants.primaryColor,

        // Hover/basma efekti rengi
        overlayColor: TamgaciConstants.primaryColor.withValues(alpha: 0.08),

        // Buton kenarlık stili
        side: const BorderSide(color: TamgaciConstants.primaryColor, width: 1),

        // Buton şekli
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),

        // Buton padding değerleri
        padding: const EdgeInsets.symmetric(
          horizontal: TamgaciConstants.spaceLG,
          vertical: TamgaciConstants.spaceSM,
        ),

        // Buton minimum boyutu
        minimumSize: const Size(88, 48),

        // Buton metni stili
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  /// FilledButton (Dolu buton) teması
  static FilledButtonThemeData _getFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // Buton arka plan rengi
        backgroundColor: TamgaciConstants.secondaryColor,

        // Buton metin rengi
        foregroundColor: TamgaciConstants.textOnPrimary,

        // Hover/basma efekti rengi
        overlayColor: TamgaciConstants.textOnPrimary.withValues(alpha: 0.08),

        // Buton şekli
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),

        // Buton minimum boyutu
        minimumSize: const Size(88, 48),

        // Buton padding değerleri
        padding: const EdgeInsets.symmetric(
          horizontal: TamgaciConstants.spaceLG,
          vertical: TamgaciConstants.spaceSM,
        ),

        // Buton metni stili
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // ========== FLOATING ACTION BUTTON TEMASI ==========

  /// FloatingActionButton teması
  static FloatingActionButtonThemeData _getFloatingActionButtonTheme() {
    return FloatingActionButtonThemeData(
      // FAB arka plan rengi
      backgroundColor: TamgaciConstants.primaryColor,

      // FAB ikon rengi
      foregroundColor: TamgaciConstants.textOnPrimary,

      // FAB yükseklik efekti
      elevation: 6,

      // Hover durumunda yükseklik
      hoverElevation: 8,

      // Focus durumunda yükseklik
      focusElevation: 8,

      // Highlight durumunda yükseklik
      highlightElevation: 12,

      // Devre dışı durumda yükseklik
      disabledElevation: 0,

      // FAB şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusXL),
      ),

      // FAB boyutu
      sizeConstraints: const BoxConstraints(minWidth: 56, minHeight: 56),
    );
  }

  // ========== INPUT DECORATION TEMASI ==========

  /// Metin giriş alanları için tema
  static InputDecorationTheme _getInputDecorationTheme() {
    return InputDecorationTheme(
      // Input alanı dolu olup olmayacağı
      filled: true,

      // Input alanı arka plan rengi
      fillColor: TamgaciConstants.surfaceColor,

      // İçerik padding değerleri
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceMD,
        vertical: TamgaciConstants.spaceSM,
      ),

      // Normal durum kenarlığı
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.borderColor,
          width: 1,
        ),
      ),

      // Aktif olmayan durum kenarlığı
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.borderColor,
          width: 1,
        ),
      ),

      // Odaklanma durumu kenarlığı
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.primaryColor,
          width: 2,
        ),
      ),

      // Hata durumu kenarlığı
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.errorColor,
          width: 1,
        ),
      ),

      // Hata + odaklanma durumu kenarlığı
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.errorColor,
          width: 2,
        ),
      ),

      // Devre dışı durum kenarlığı
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: BorderSide(
          color: TamgaciConstants.borderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),

      // Label metni stili
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondary,
      ),

      // Floating label stili
      floatingLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.primaryColor,
      ),

      // Helper text stili
      helperStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondary,
      ),

      // Hata metni stili
      errorStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.errorColor,
      ),

      // Hint text stili
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textDisabled,
      ),

      // Prefix ikon rengi
      prefixIconColor: TamgaciConstants.textSecondary,

      // Suffix ikon rengi
      suffixIconColor: TamgaciConstants.textSecondary,
    );
  }

  // ========== KART TEMASI ==========

  /// Kart bileşeni teması
  static CardThemeData _getCardThemeData() {
    return CardThemeData(
      // Kart arka plan rengi
      color: TamgaciConstants.cardColor,

      // Kart yükseklik efekti
      elevation: 2,

      // Kart gölge rengi
      shadowColor: TamgaciConstants.shadowColor,

      // Kart yüzey renk tonu
      surfaceTintColor: Colors.transparent,

      // Kart şekli ve border radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),

      // Kart kenarlık stili
      margin: const EdgeInsets.all(TamgaciConstants.spaceXS),

      // Kliplanabilir davranış
      clipBehavior: Clip.hardEdge,
    );
  }

  // ========== LISTE ELEMANLARI TEMASI ==========

  /// ListTile bileşeni teması
  static ListTileThemeData _getListTileTheme() {
    return ListTileThemeData(
      // Liste elemanı arka plan rengi
      tileColor: Colors.transparent,

      // Seçili liste elemanı arka plan rengi
      selectedTileColor: TamgaciConstants.primaryLight.withValues(alpha: 0.1),

      // Liste elemanı şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),

      // İçerik padding değerleri
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceMD,
        vertical: TamgaciConstants.spaceXS,
      ),

      // Başlık metin stili
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimary,
      ),

      // Alt başlık metin stili
      subtitleTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondary,
      ),

      // Leading ikon rengi
      iconColor: TamgaciConstants.textSecondary,

      // Seçili liste elemanı metin rengi
      selectedColor: TamgaciConstants.primaryColor,

      // Dense liste elemanı olup olmayacağı
      dense: false,

      // Görsel yoğunluk
      visualDensity: VisualDensity.standard,

      // Minimum leading genişliği
      minLeadingWidth: 40,

      // Minimum dikey padding
      minVerticalPadding: 4,
    );
  }

  // ========== DIALOG TEMALARI ==========

  /// Dialog bileşeni teması
  static DialogThemeData _getDialogTheme() {
    return DialogThemeData(
      // Dialog arka plan rengi
      backgroundColor: TamgaciConstants.backgroundColor,

      // Dialog yükseklik efekti
      elevation: 24,

      // Dialog gölge rengi
      shadowColor: TamgaciConstants.shadowColor,

      // Dialog yüzey renk tonu
      surfaceTintColor: Colors.transparent,

      // Dialog şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),

      // Dialog başlık metni stili
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimary,
      ),

      // Dialog içerik metni stili
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        height: 1.5,
      ),

      // Dialog iç padding değerleri
      insetPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceLG,
        vertical: TamgaciConstants.spaceXL,
      ),
    );
  }

  /// BottomSheet bileşeni teması
  static BottomSheetThemeData _getBottomSheetTheme() {
    return const BottomSheetThemeData(
      // BottomSheet arka plan rengi
      backgroundColor: TamgaciConstants.backgroundColor,

      // BottomSheet modal arka plan rengi
      modalBackgroundColor: TamgaciConstants.backgroundColor,

      // BottomSheet yükseklik efekti
      elevation: 16,

      // BottomSheet gölge rengi
      shadowColor: TamgaciConstants.shadowColor,

      // BottomSheet şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TamgaciConstants.radiusLG),
        ),
      ),

      // Kliplanabilir davranış
      clipBehavior: Clip.hardEdge,

      // Sürüklenebilir gösterge stili
      dragHandleColor: TamgaciConstants.dividerColor,

      // Sürüklenebilir gösterge boyutu
      dragHandleSize: Size(32, 4),
    );
  }

  // ========== NAVİGASYON TEMALARI ==========

  /// BottomNavigationBar teması
  static BottomNavigationBarThemeData _getBottomNavigationBarTheme() {
    return BottomNavigationBarThemeData(
      // NavigationBar arka plan rengi
      backgroundColor: TamgaciConstants.backgroundColor,

      // Seçili item rengi
      selectedItemColor: TamgaciConstants.primaryColor,

      // Seçilmemiş item rengi
      unselectedItemColor: TamgaciConstants.textSecondary,

      // Seçili label metin stili
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),

      // Seçilmemiş label metin stili
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),

      // NavigationBar türü
      type: BottomNavigationBarType.fixed,

      // Yükseklik efekti
      elevation: 8,

      // Label gösterilsin mi
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }

  /// NavigationBar teması (Material 3)
  static NavigationBarThemeData _getNavigationBarTheme() {
    return NavigationBarThemeData(
      // NavigationBar arka plan rengi
      backgroundColor: TamgaciConstants.backgroundColor,

      // Gösterge rengi
      indicatorColor: TamgaciConstants.primaryLight,

      // Gösterge şekli
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),

      // NavigationBar yüksekliği
      height: 80,

      // Label davranışı
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      // Label metni stili
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.primaryColor,
          );
        }
        return GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textSecondary,
        );
      }),

      // İkon teması
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: TamgaciConstants.primaryColor,
            size: 24,
          );
        }
        return const IconThemeData(
          color: TamgaciConstants.textSecondary,
          size: 24,
        );
      }),
    );
  }

  /// NavigationDrawer teması
  static NavigationDrawerThemeData _getNavigationDrawerTheme() {
    return NavigationDrawerThemeData(
      // Drawer arka plan rengi
      backgroundColor: TamgaciConstants.backgroundColor,

      // Drawer yükseklik efekti
      elevation: 16,

      // Drawer gölge rengi
      shadowColor: TamgaciConstants.shadowColor,

      // Gösterge rengi
      indicatorColor: TamgaciConstants.primaryLight,

      // Gösterge şekli
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),

      // Drawer genişliği
      tileHeight: 56,

      // Label metni stili
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TamgaciConstants.primaryColor,
          );
        }
        return GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textPrimary,
        );
      }),

      // İkon teması
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: TamgaciConstants.primaryColor,
            size: 24,
          );
        }
        return const IconThemeData(
          color: TamgaciConstants.textSecondary,
          size: 24,
        );
      }),
    );
  }

  // ========== TAB TEMASI ==========

  /// TabBar bileşeni teması
  static TabBarThemeData _getTabBarTheme() {
    return TabBarThemeData(
      // Tab gösterge rengi
      indicatorColor: TamgaciConstants.primaryColor,

      // Tab gösterge boyutu
      indicatorSize: TabBarIndicatorSize.label,

      // Seçili tab label rengi
      labelColor: TamgaciConstants.primaryColor,

      // Seçilmemiş tab label rengi
      unselectedLabelColor: TamgaciConstants.textSecondary,

      // Seçili tab label stili
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      // Seçilmemiş tab label stili
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),

      // Tab padding değerleri
      labelPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceMD,
      ),

      // Overlay rengi
      overlayColor: WidgetStateProperty.all(
        TamgaciConstants.primaryColor.withValues(alpha: 0.1),
      ),
    );
  }

  // ========== FORM KONTROLLERİ ==========

  /// Checkbox teması
  static CheckboxThemeData _getCheckboxTheme() {
    return CheckboxThemeData(
      // Checkbox rengi
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TamgaciConstants.primaryColor;
        }
        return TamgaciConstants.borderColor;
      }),

      // Checkbox işaret rengi
      checkColor: WidgetStateProperty.all(TamgaciConstants.textOnPrimary),

      // Checkbox overlay rengi
      overlayColor: WidgetStateProperty.all(
        TamgaciConstants.primaryColor.withValues(alpha: 0.1),
      ),

      // Checkbox şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusXS),
      ),
    );
  }

  /// Radio teması
  static RadioThemeData _getRadioTheme() {
    return RadioThemeData(
      // Radio buton rengi
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TamgaciConstants.primaryColor;
        }
        return TamgaciConstants.borderColor;
      }),

      // Radio buton overlay rengi
      overlayColor: WidgetStateProperty.all(
        TamgaciConstants.primaryColor.withValues(alpha: 0.1),
      ),
    );
  }

  /// Switch teması
  static SwitchThemeData _getSwitchTheme() {
    return SwitchThemeData(
      // Switch thumb rengi
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TamgaciConstants.primaryColor;
        }
        return TamgaciConstants.textDisabled;
      }),

      // Switch track rengi
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TamgaciConstants.primaryLight;
        }
        return TamgaciConstants.borderColor;
      }),

      // Switch overlay rengi
      overlayColor: WidgetStateProperty.all(
        TamgaciConstants.primaryColor.withValues(alpha: 0.1),
      ),
    );
  }

  // ========== SLIDER TEMASI ==========

  /// Slider bileşeni teması
  static SliderThemeData _getSliderTheme() {
    return SliderThemeData(
      // Aktif track rengi
      activeTrackColor: TamgaciConstants.primaryColor,

      // İnaktif track rengi
      inactiveTrackColor: TamgaciConstants.borderColor,

      // Thumb rengi
      thumbColor: TamgaciConstants.primaryColor,

      // Overlay rengi
      overlayColor: TamgaciConstants.primaryColor.withValues(alpha: 0.1),

      // Value indicator rengi
      valueIndicatorColor: TamgaciConstants.primaryColor,

      // Value indicator metni stili
      valueIndicatorTextStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimary,
      ),

      // Track yüksekliği
      trackHeight: 4,

      // Thumb yarıçapı
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    );
  }

  // ========== PROGRESS INDICATOR TEMASI ==========

  /// ProgressIndicator teması
  static ProgressIndicatorThemeData _getProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(
      // Doğrusal progress indicator rengi
      linearTrackColor: TamgaciConstants.borderColor,

      // Dairesel progress indicator rengi
      circularTrackColor: TamgaciConstants.borderColor,

      // Progress rengi
      color: TamgaciConstants.primaryColor,

      // Yenileme göstergesi arka plan rengi
      refreshBackgroundColor: TamgaciConstants.backgroundColor,
    );
  }

  // ========== SNACKBAR TEMASI ==========

  /// SnackBar bileşeni teması
  static SnackBarThemeData _getSnackBarTheme() {
    return SnackBarThemeData(
      // SnackBar arka plan rengi
      backgroundColor: TamgaciConstants.textPrimary,

      // SnackBar içerik rengi
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimary,
      ),

      // SnackBar action rengi
      actionTextColor: TamgaciConstants.primaryLight,

      // SnackBar yükseklik efekti
      elevation: 6,

      // SnackBar şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),

      // SnackBar davranışı
      behavior: SnackBarBehavior.floating,

      // SnackBar margin değerleri
      insetPadding: const EdgeInsets.all(TamgaciConstants.spaceMD),
    );
  }

  // ========== TOOLTIP TEMASI ==========

  /// Tooltip bileşeni teması
  static TooltipThemeData _getTooltipTheme() {
    return TooltipThemeData(
      // Tooltip arka plan rengi
      decoration: BoxDecoration(
        color: TamgaciConstants.textPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),

      // Tooltip metni stili
      textStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimary,
      ),

      // Tooltip padding değerleri
      padding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceSM,
        vertical: TamgaciConstants.spaceXS,
      ),

      // Tooltip margin değerleri
      margin: const EdgeInsets.all(TamgaciConstants.spaceXS),

      // Tooltip gösterim süresi
      waitDuration: const Duration(milliseconds: 500),

      // Tooltip gizlenme süresi
      showDuration: const Duration(milliseconds: 1500),
    );
  }

  // ========== DİĞER BİLEŞEN TEMALARI ==========

  /// Divider teması
  static DividerThemeData _getDividerTheme() {
    return const DividerThemeData(
      // Divider rengi
      color: TamgaciConstants.dividerColor,

      // Divider kalınlığı
      thickness: 1,

      // Divider boşluğu
      space: 16,

      // Divider başlangıç indentleri
      indent: 0,
      endIndent: 0,
    );
  }

  /// Chip teması
  static ChipThemeData _getChipTheme() {
    return ChipThemeData(
      // Chip arka plan rengi
      backgroundColor: TamgaciConstants.surfaceColor,

      // Seçili chip arka plan rengi
      selectedColor: TamgaciConstants.primaryLight,

      // Chip kenarlık rengi
      side: const BorderSide(color: TamgaciConstants.borderColor),

      // Chip label metni stili
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
      ),

      // Chip padding değerleri
      labelPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceSM,
      ),

      // Chip şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),
    );
  }

  /// DataTable teması
  static DataTableThemeData _getDataTableTheme() {
    return DataTableThemeData(
      // Tablo arka plan rengi
      decoration: const BoxDecoration(color: TamgaciConstants.backgroundColor),

      // Başlık satırı arka plan rengi
      headingRowColor: WidgetStateProperty.all(TamgaciConstants.surfaceColor),

      // Veri satırı arka plan rengi
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return TamgaciConstants.primaryLight.withValues(alpha: 0.05);
        }
        return TamgaciConstants.backgroundColor;
      }),

      // Başlık metni stili
      headingTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimary,
      ),

      // Veri metni stili
      dataTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
      ),

      // Tablo yüksekliği
      headingRowHeight: 56,
      dataRowMinHeight: 48,
      dataRowMaxHeight: 72,

      // Checkbox teması
      checkboxHorizontalMargin: 12,
    );
  }

  /// ExpansionTile teması
  static ExpansionTileThemeData _getExpansionTileTheme() {
    return ExpansionTileThemeData(
      // ExpansionTile arka plan rengi
      backgroundColor: TamgaciConstants.surfaceColor,

      // Daraltılmış durum arka plan rengi
      collapsedBackgroundColor: TamgaciConstants.backgroundColor,

      // Başlık rengi
      textColor: TamgaciConstants.textPrimary,

      // Daraltılmış başlık rengi
      collapsedTextColor: TamgaciConstants.textPrimary,

      // İkon rengi
      iconColor: TamgaciConstants.textSecondary,

      // Daraltılmış ikon rengi
      collapsedIconColor: TamgaciConstants.textSecondary,

      // ExpansionTile şekli
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),

      // Daraltılmış durum şekli
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),
    );
  }

  /// MenuBar teması
  static MenuBarThemeData _getMenuBarTheme() {
    return MenuBarThemeData(
      style: MenuStyle(
        // Menu arka plan rengi
        backgroundColor: WidgetStateProperty.all(
          TamgaciConstants.backgroundColor,
        ),

        // Menu yükseklik efekti
        elevation: WidgetStateProperty.all(2),

        // Menu şekli
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
          ),
        ),
      ),
    );
  }

  /// MenuButton teması
  static MenuButtonThemeData _getMenuButtonTheme() {
    return MenuButtonThemeData(
      style: ButtonStyle(
        // Buton arka plan rengi
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return TamgaciConstants.primaryColor.withValues(alpha: 0.08);
          }
          return Colors.transparent;
        }),

        // Buton metni rengi
        foregroundColor: WidgetStateProperty.all(TamgaciConstants.textPrimary),

        // Buton metni stili
        textStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        ),

        // Buton şekli
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
          ),
        ),
      ),
    );
  }

  /// SearchBar teması
  static SearchBarThemeData _getSearchBarTheme() {
    return SearchBarThemeData(
      // SearchBar arka plan rengi
      backgroundColor: WidgetStateProperty.all(TamgaciConstants.surfaceColor),

      // SearchBar yükseklik efekti
      elevation: WidgetStateProperty.all(0),

      // SearchBar şekli
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
          side: const BorderSide(color: TamgaciConstants.borderColor),
        ),
      ),

      // SearchBar metni stili
      textStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textPrimary,
        ),
      ),

      // SearchBar hint metni stili
      hintStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textDisabled,
        ),
      ),
    );
  }

  // ========== İKON TEMALARI ==========

  /// Ana ikon teması
  static IconThemeData _getIconTheme() {
    return const IconThemeData(color: TamgaciConstants.textSecondary, size: 24);
  }

  /// Primary ikon teması
  static IconThemeData _getPrimaryIconTheme() {
    return const IconThemeData(color: TamgaciConstants.textOnPrimary, size: 24);
  }

  // ========== METİN TEMALARI ==========

  /// Ana metin teması
  static TextTheme _getTextTheme() {
    return TextTheme(
      // Display metinleri - En büyük başlıklar
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),

      // Headline metinleri - Büyük başlıklar
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),

      // Title metinleri - Orta başlıklar
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.1,
      ),

      // Body metinleri - Gövde metinleri
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondary,
        letterSpacing: 0.4,
      ),

      // Label metinleri - Etiket metinleri
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimary,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Primary metin teması (Primary renk üzerindeki metinler için)
  static TextTheme _getPrimaryTextTheme() {
    return _getTextTheme().apply(
      bodyColor: TamgaciConstants.textOnPrimary,
      displayColor: TamgaciConstants.textOnPrimary,
    );
  }

  // ========== TEMA HELPER METODLARI ==========

  /// Mevcut temayı kontrol eden metod
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Tema tipini döndüren metod
  static ThemeType getThemeType(BuildContext context) {
    return isDarkMode(context) ? ThemeType.dark : ThemeType.light;
  }

  /// Tema değiştirme metodu için callback
  static void toggleTheme(BuildContext context, VoidCallback onThemeChanged) {
    // Bu metod tema değiştirme logic'i için kullanılabilir
    // Provider veya Bloc ile tema state'i yönetilirken kullanılır
    onThemeChanged();
  }

  // ========== DARK THEME METHODS ==========

  /// Koyu tema AppBar teması
  static AppBarTheme _getDarkAppBarTheme() {
    return AppBarTheme(
      backgroundColor: TamgaciConstants.surfaceColorDark,
      foregroundColor: TamgaciConstants.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
      ),
      iconTheme: const IconThemeData(
        color: TamgaciConstants.textPrimaryDark,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: TamgaciConstants.textPrimaryDark,
        size: 24,
      ),
    );
  }

  /// Koyu tema Elevated Button teması
  static ElevatedButtonThemeData _getDarkElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TamgaciConstants.primaryColorDark,
        foregroundColor: TamgaciConstants.textOnPrimaryDark,
        elevation: 2,
        shadowColor: TamgaciConstants.shadowColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Koyu tema Text Button teması
  static TextButtonThemeData _getDarkTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TamgaciConstants.primaryColorDark,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Koyu tema Outlined Button teması
  static OutlinedButtonThemeData _getDarkOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TamgaciConstants.primaryColorDark,
        side: const BorderSide(
          color: TamgaciConstants.primaryColorDark,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Koyu tema Filled Button teması
  static FilledButtonThemeData _getDarkFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: TamgaciConstants.primaryColorDark,
        foregroundColor: TamgaciConstants.textOnPrimaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Koyu tema Input Decoration teması
  static InputDecorationTheme _getDarkInputDecorationTheme() {
    return InputDecorationTheme(
      // Input field arka plan rengi
      fillColor: TamgaciConstants.cardColorDark,
      filled: true,

      // Normal durum kenarlığı
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.borderColorDark,
          width: 1,
        ),
      ),

      // Odaklanma durumu kenarlığı
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.primaryColorDark,
          width: 2,
        ),
      ),

      // Hata durumu kenarlığı
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.errorColor,
          width: 1,
        ),
      ),

      // Hata + odaklanma durumu kenarlığı
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: const BorderSide(
          color: TamgaciConstants.errorColor,
          width: 2,
        ),
      ),

      // Devre dışı durum kenarlığı
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        borderSide: BorderSide(
          color: TamgaciConstants.borderColorDark.withValues(alpha: 0.5),
          width: 1,
        ),
      ),

      // Label metni stili
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
      ),

      // Floating label stili
      floatingLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.primaryColorDark,
      ),

      // Helper text stili
      helperStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
      ),

      // Hata metni stili
      errorStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.errorColor,
      ),

      // Hint text stili
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textDisabledDark,
      ),

      // Prefix ikon rengi
      prefixIconColor: TamgaciConstants.textSecondaryDark,

      // Suffix ikon rengi
      suffixIconColor: TamgaciConstants.textSecondaryDark,
    );
  }

  /// Koyu tema Kart teması
  static CardThemeData _getDarkCardThemeData() {
    return CardThemeData(
      color: TamgaciConstants.cardColorDark,
      elevation: 2,
      shadowColor: TamgaciConstants.shadowColorDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusMD),
      ),
      margin: const EdgeInsets.all(TamgaciConstants.spaceXS),
      clipBehavior: Clip.hardEdge,
    );
  }

  /// Koyu tema ListTile teması
  static ListTileThemeData _getDarkListTileTheme() {
    return ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor:
          TamgaciConstants.primaryLightDark.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TamgaciConstants.spaceMD,
        vertical: TamgaciConstants.spaceXS,
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimaryDark,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
      ),
      leadingAndTrailingTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textSecondaryDark,
      ),
    );
  }

  /// Koyu tema Chip teması
  static ChipThemeData _getDarkChipTheme() {
    return ChipThemeData(
      backgroundColor: TamgaciConstants.surfaceColorDark,
      selectedColor: TamgaciConstants.primaryColorDark,
      disabledColor: TamgaciConstants.textDisabledDark,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimaryDark,
      ),
      secondaryLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
      ),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
      ),
    );
  }

  /// Koyu tema Dialog teması
  static DialogThemeData _getDarkDialogThemeData() {
    return DialogThemeData(
      backgroundColor: TamgaciConstants.cardColorDark,
      elevation: 8,
      shadowColor: TamgaciConstants.shadowColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TamgaciConstants.radiusLG),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
      ),
    );
  }

  /// Koyu tema Bottom Sheet teması
  static BottomSheetThemeData _getDarkBottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: TamgaciConstants.cardColorDark,
      elevation: 8,
      shadowColor: TamgaciConstants.shadowColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TamgaciConstants.radiusLG),
        ),
      ),
    );
  }

  /// Koyu tema Drawer teması
  static DrawerThemeData _getDarkDrawerTheme() {
    return const DrawerThemeData(
      backgroundColor: TamgaciConstants.surfaceColorDark,
      elevation: 8,
      shadowColor: TamgaciConstants.shadowColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(TamgaciConstants.radiusLG),
        ),
      ),
    );
  }

  /// Koyu tema Menu Button teması
  static MenuButtonThemeData _getDarkMenuButtonTheme() {
    return MenuButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all(TamgaciConstants.cardColorDark),
        foregroundColor:
            WidgetStateProperty.all(TamgaciConstants.textPrimaryDark),
        elevation: WidgetStateProperty.all(2.0),
        shadowColor: WidgetStateProperty.all(TamgaciConstants.shadowColorDark),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
          ),
        ),
      ),
    );
  }

  /// Koyu tema SearchBar teması
  static SearchBarThemeData _getDarkSearchBarTheme() {
    return SearchBarThemeData(
      backgroundColor: WidgetStateProperty.all(TamgaciConstants.cardColorDark),
      elevation: WidgetStateProperty.all(2),
      shadowColor: WidgetStateProperty.all(TamgaciConstants.shadowColorDark),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TamgaciConstants.radiusSM),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textPrimaryDark,
        ),
      ),
      hintStyle: WidgetStateProperty.all(
        GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: TamgaciConstants.textDisabledDark,
        ),
      ),
    );
  }

  /// Koyu tema Icon teması
  static IconThemeData _getDarkIconTheme() {
    return const IconThemeData(
      color: TamgaciConstants.textSecondaryDark,
      size: 24,
    );
  }

  /// Koyu tema Primary Icon teması
  static IconThemeData _getDarkPrimaryIconTheme() {
    return const IconThemeData(
      color: TamgaciConstants.textOnPrimaryDark,
      size: 24,
    );
  }

  /// Koyu tema Text teması
  static TextTheme _getDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textSecondaryDark,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textPrimaryDark,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textSecondaryDark,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textDisabledDark,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Koyu tema Primary Text teması
  static TextTheme _getDarkPrimaryTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: TamgaciConstants.textOnPrimaryDark,
        letterSpacing: 0.5,
      ),
    );
  }
}
