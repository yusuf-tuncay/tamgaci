// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tamgaci';

  @override
  String get action_retry => 'Retry';

  @override
  String get error_generic => 'An error occurred';

  @override
  String get copyright => '© 2024 Tamgaci. All rights reserved.';

  @override
  String get splash_loading => 'Loading Tamgaci...';

  @override
  String get splash_initializing => 'Checking settings...';

  @override
  String get splash_db => 'Preparing database...';

  @override
  String get splash_auth => 'Checking session...';

  @override
  String get splash_ready => 'Tamgaci is ready!';

  @override
  String get settings => 'Settings';

  @override
  String get settingsDescription =>
      'Manage your currency, language and other preferences';

  @override
  String get language => 'Language Settings';

  @override
  String get languageDescription => 'Select application language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get theme => 'Theme Settings';

  @override
  String get themeDescription => 'Select application theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get currencySettings => 'Currency Settings';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get defaultCurrencyDescription =>
      'Select the default currency to be used in all transactions';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get currentRates => 'Current Rates';

  @override
  String get ratesLoadError => 'Failed to load rates';

  @override
  String get otherSettings => 'Other Settings';

  @override
  String get autoUpdateRates => 'Auto Update Rates';

  @override
  String get autoUpdateRatesDescription =>
      'Rates will be updated automatically';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDescription =>
      'Receive notifications for important transactions';
}
