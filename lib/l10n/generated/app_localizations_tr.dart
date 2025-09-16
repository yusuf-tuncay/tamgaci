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
}
