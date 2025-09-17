// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Tamgaci';

  @override
  String get action_retry => 'Повтори';

  @override
  String get error_generic => 'Възникна грешка';

  @override
  String get copyright => '© 2024 Tamgaci. Всички права запазени.';

  @override
  String get splash_loading => 'Зареждане на Tamgaci...';

  @override
  String get splash_initializing => 'Проверка на настройките...';

  @override
  String get splash_db => 'Подготовка на базата данни...';

  @override
  String get splash_auth => 'Проверка на сесията...';

  @override
  String get splash_ready => 'Tamgaci е готов!';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsDescription =>
      'Управлявайте валути, език и други предпочитания';

  @override
  String get language => 'Настройки на езика';

  @override
  String get languageDescription => 'Изберете език на приложението';

  @override
  String get selectLanguage => 'Изберете език';

  @override
  String get languageChanged => 'Езикът е променен';

  @override
  String get theme => 'Настройки на темата';

  @override
  String get themeDescription => 'Изберете тема на приложението';

  @override
  String get lightTheme => 'Светла тема';

  @override
  String get darkTheme => 'Тъмна тема';

  @override
  String get systemTheme => 'Системна тема';

  @override
  String get currencySettings => 'Настройки на валутата';

  @override
  String get defaultCurrency => 'Валута по подразбиране';

  @override
  String get defaultCurrencyDescription =>
      'Изберете валута по подразбиране за всички транзакции';

  @override
  String get selectCurrency => 'Изберете валута';

  @override
  String get currentRates => 'Текущи курсове';

  @override
  String get ratesLoadError => 'Неуспешно зареждане на курсове';

  @override
  String get otherSettings => 'Други настройки';

  @override
  String get autoUpdateRates => 'Автоматично обновяване на курсове';

  @override
  String get autoUpdateRatesDescription =>
      'Курсовете ще се обновяват автоматично';

  @override
  String get notifications => 'Известия';

  @override
  String get notificationsDescription =>
      'Получавайте известия за важни транзакции';
}
