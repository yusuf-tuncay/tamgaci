// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tamgaci';

  @override
  String get action_retry => 'Tekrar Dene';

  @override
  String get error_generic => 'Bir Sorun Oluştu';

  @override
  String get copyright => '© 2024 Tamgaci. Tüm hakları saklıdır.';

  @override
  String get splash_loading => 'Tamgacı Yükleniyor...';

  @override
  String get splash_initializing => 'Ayarlar kontrol ediliyor...';

  @override
  String get splash_db => 'Veritabanı hazırlanıyor...';

  @override
  String get splash_auth => 'Oturum bilgileri kontrol ediliyor...';

  @override
  String get splash_ready => 'Tamgacı hazır!';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsDescription =>
      'Para birimi, dil ve diğer tercihlerinizi yönetin';

  @override
  String get language => 'Dil Ayarları';

  @override
  String get languageDescription => 'Uygulama dilini seçin';

  @override
  String get selectLanguage => 'Dil seçin';

  @override
  String get languageChanged => 'Dil değiştirildi';

  @override
  String get theme => 'Tema Ayarları';

  @override
  String get themeDescription => 'Uygulama temasını seçin';

  @override
  String get lightTheme => 'Açık Tema';

  @override
  String get darkTheme => 'Koyu Tema';

  @override
  String get systemTheme => 'Sistem Teması';

  @override
  String get currencySettings => 'Para Birimi Ayarları';

  @override
  String get defaultCurrency => 'Varsayılan Para Birimi';

  @override
  String get defaultCurrencyDescription =>
      'Tüm işlemlerde kullanılacak varsayılan para birimini seçin';

  @override
  String get selectCurrency => 'Para birimi seçin';

  @override
  String get currentRates => 'Güncel Kurlar';

  @override
  String get ratesLoadError => 'Kurlar yüklenemedi';

  @override
  String get otherSettings => 'Diğer Ayarlar';

  @override
  String get autoUpdateRates => 'Otomatik Kur Güncelleme';

  @override
  String get autoUpdateRatesDescription =>
      'Kurlar otomatik olarak güncellensin';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsDescription => 'Önemli işlemler için bildirim al';
}
