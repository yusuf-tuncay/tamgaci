// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Tamgaci';

  @override
  String get action_retry => 'إعادة المحاولة';

  @override
  String get error_generic => 'حدث خطأ';

  @override
  String get copyright => '© 2024 Tamgaci. جميع الحقوق محفوظة.';

  @override
  String get splash_loading => 'جاري تحميل Tamgaci...';

  @override
  String get splash_initializing => 'جاري فحص الإعدادات...';

  @override
  String get splash_db => 'جاري إعداد قاعدة البيانات...';

  @override
  String get splash_auth => 'جاري فحص الجلسة...';

  @override
  String get splash_ready => 'Tamgaci جاهز!';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsDescription => 'إدارة العملات واللغة والتفضيلات الأخرى';

  @override
  String get language => 'إعدادات اللغة';

  @override
  String get languageDescription => 'اختر لغة التطبيق';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة';

  @override
  String get theme => 'إعدادات المظهر';

  @override
  String get themeDescription => 'اختر مظهر التطبيق';

  @override
  String get lightTheme => 'المظهر الفاتح';

  @override
  String get darkTheme => 'المظهر الداكن';

  @override
  String get systemTheme => 'مظهر النظام';

  @override
  String get currencySettings => 'إعدادات العملة';

  @override
  String get defaultCurrency => 'العملة الافتراضية';

  @override
  String get defaultCurrencyDescription =>
      'اختر العملة الافتراضية لجميع المعاملات';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get currentRates => 'الأسعار الحالية';

  @override
  String get ratesLoadError => 'فشل في تحميل الأسعار';

  @override
  String get otherSettings => 'إعدادات أخرى';

  @override
  String get autoUpdateRates => 'تحديث الأسعار تلقائياً';

  @override
  String get autoUpdateRatesDescription => 'سيتم تحديث الأسعار تلقائياً';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsDescription => 'تلقي إشعارات للمعاملات المهمة';
}
