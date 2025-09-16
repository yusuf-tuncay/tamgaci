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
}
