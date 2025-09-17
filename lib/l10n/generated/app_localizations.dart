import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bg'),
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tamgaci'**
  String get appTitle;

  /// No description provided for @action_retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get action_retry;

  /// No description provided for @error_generic.
  ///
  /// In tr, this message translates to:
  /// **'Bir Sorun Oluştu'**
  String get error_generic;

  /// No description provided for @copyright.
  ///
  /// In tr, this message translates to:
  /// **'© 2024 Tamgaci. Tüm hakları saklıdır.'**
  String get copyright;

  /// No description provided for @splash_loading.
  ///
  /// In tr, this message translates to:
  /// **'Tamgacı Yükleniyor...'**
  String get splash_loading;

  /// No description provided for @splash_initializing.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar kontrol ediliyor...'**
  String get splash_initializing;

  /// No description provided for @splash_db.
  ///
  /// In tr, this message translates to:
  /// **'Veritabanı hazırlanıyor...'**
  String get splash_db;

  /// No description provided for @splash_auth.
  ///
  /// In tr, this message translates to:
  /// **'Oturum bilgileri kontrol ediliyor...'**
  String get splash_auth;

  /// No description provided for @splash_ready.
  ///
  /// In tr, this message translates to:
  /// **'Tamgacı hazır!'**
  String get splash_ready;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @settingsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Para birimi, dil ve diğer tercihlerinizi yönetin'**
  String get settingsDescription;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil Ayarları'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama dilini seçin'**
  String get languageDescription;

  /// No description provided for @selectLanguage.
  ///
  /// In tr, this message translates to:
  /// **'Dil seçin'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In tr, this message translates to:
  /// **'Dil değiştirildi'**
  String get languageChanged;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema Ayarları'**
  String get theme;

  /// No description provided for @themeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama temasını seçin'**
  String get themeDescription;

  /// No description provided for @lightTheme.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Teması'**
  String get systemTheme;

  /// No description provided for @currencySettings.
  ///
  /// In tr, this message translates to:
  /// **'Para Birimi Ayarları'**
  String get currencySettings;

  /// No description provided for @defaultCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Varsayılan Para Birimi'**
  String get defaultCurrency;

  /// No description provided for @defaultCurrencyDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tüm işlemlerde kullanılacak varsayılan para birimini seçin'**
  String get defaultCurrencyDescription;

  /// No description provided for @selectCurrency.
  ///
  /// In tr, this message translates to:
  /// **'Para birimi seçin'**
  String get selectCurrency;

  /// No description provided for @currentRates.
  ///
  /// In tr, this message translates to:
  /// **'Güncel Kurlar'**
  String get currentRates;

  /// No description provided for @ratesLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Kurlar yüklenemedi'**
  String get ratesLoadError;

  /// No description provided for @otherSettings.
  ///
  /// In tr, this message translates to:
  /// **'Diğer Ayarlar'**
  String get otherSettings;

  /// No description provided for @autoUpdateRates.
  ///
  /// In tr, this message translates to:
  /// **'Otomatik Kur Güncelleme'**
  String get autoUpdateRates;

  /// No description provided for @autoUpdateRatesDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kurlar otomatik olarak güncellensin'**
  String get autoUpdateRatesDescription;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @notificationsDescription.
  ///
  /// In tr, this message translates to:
  /// **'Önemli işlemler için bildirim al'**
  String get notificationsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'bg', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
