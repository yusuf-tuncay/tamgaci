// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Tamgaci';

  @override
  String get action_retry => 'Повторить';

  @override
  String get error_generic => 'Произошла ошибка';

  @override
  String get copyright => '© 2024 Tamgaci. Все права защищены.';

  @override
  String get splash_loading => 'Загрузка Tamgaci...';

  @override
  String get splash_initializing => 'Проверка настроек...';

  @override
  String get splash_db => 'Подготовка базы данных...';

  @override
  String get splash_auth => 'Проверка сессии...';

  @override
  String get splash_ready => 'Tamgaci готов!';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsDescription => 'Управляйте валютами, языком и другими предпочтениями';

  @override
  String get language => 'Настройки языка';

  @override
  String get languageDescription => 'Выберите язык приложения';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get languageChanged => 'Язык изменен';

  @override
  String get theme => 'Настройки темы';

  @override
  String get themeDescription => 'Выберите тему приложения';

  @override
  String get lightTheme => 'Светлая тема';

  @override
  String get darkTheme => 'Темная тема';

  @override
  String get systemTheme => 'Системная тема';

  @override
  String get currencySettings => 'Настройки валюты';

  @override
  String get defaultCurrency => 'Валюта по умолчанию';

  @override
  String get defaultCurrencyDescription => 'Выберите валюту по умолчанию для всех транзакций';

  @override
  String get selectCurrency => 'Выберите валюту';

  @override
  String get currentRates => 'Текущие курсы';

  @override
  String get ratesLoadError => 'Не удалось загрузить курсы';

  @override
  String get otherSettings => 'Другие настройки';

  @override
  String get autoUpdateRates => 'Автообновление курсов';

  @override
  String get autoUpdateRatesDescription => 'Курсы будут обновляться автоматически';

  @override
  String get notifications => 'Уведомления';

  @override
  String get notificationsDescription => 'Получать уведомления о важных транзакциях';
}
