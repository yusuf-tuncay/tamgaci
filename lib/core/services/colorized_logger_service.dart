import 'package:flutter/foundation.dart';
import 'logger_output_formatter.dart';

/// Renkli konsol çıktısı için logger service
class ColorizedLoggerService {
  // ANSI renk kodları
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  // Renk kodları
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _gray = '\x1B[90m';

  // Arka plan renkleri
  static const String _bgRed = '\x1B[41m';
  static const String _bgGreen = '\x1B[42m';
  static const String _bgYellow = '\x1B[43m';
  static const String _bgBlue = '\x1B[44m';
  static const String _bgMagenta = '\x1B[45m';
  static const String _bgCyan = '\x1B[46m';

  /// Log seviyesine göre renkli çıktı
  static void log(String level, String message,
      {String? category, String? context}) {
    if (!kDebugMode) return;

    // Logger output formatter kullan
    final formattedLog = LoggerOutputFormatter.formatSimpleLog(
      level: level,
      message: message,
      category: category,
      context: context,
    );

    final coloredLog = LoggerOutputFormatter.colorizeLog(formattedLog, level);

    debugPrint(coloredLog);
  }

  /// Error log
  static void error(String message, {String? category, String? context}) {
    log('ERROR', message, category: category, context: context);
  }

  /// Warning log
  static void warning(String message, {String? category, String? context}) {
    log('WARNING', message, category: category, context: context);
  }

  /// Info log
  static void info(String message, {String? category, String? context}) {
    log('INFO', message, category: category, context: context);
  }

  /// Debug log
  static void debug(String message, {String? category, String? context}) {
    log('DEBUG', message, category: category, context: context);
  }

  /// Suppressed log
  static void suppressed(String message, {String? category, String? context}) {
    log('SUPPRESSED', message, category: category, context: context);
  }

  /// Remote log
  static void remote(String message, {String? category, String? context}) {
    log('REMOTE', message, category: category, context: context);
  }

  /// Performance log
  static void performance(String message, {String? category, String? context}) {
    log('PERFORMANCE', message, category: category, context: context);
  }

  /// Separator line
  static void separator({String? title}) {
    if (!kDebugMode) return;

    final line = '=' * 80;
    if (title != null) {
      debugPrint('$_bold$_cyan$line$_reset');
      debugPrint('$_bold$_cyan$title$_reset');
      debugPrint('$_bold$_cyan$line$_reset');
    } else {
      debugPrint('$_bold$_gray$line$_reset');
    }
  }

  /// Success message
  static void success(String message, {String? category, String? context}) {
    log('SUCCESS', message, category: category, context: context);
  }

  /// Test renkli çıktı
  static void testColors() {
    if (!kDebugMode) return;

    separator(title: 'COLORIZED LOGGER TEST');

    error('This is an ERROR message', category: 'Test', context: 'ColorTest');
    warning('This is a WARNING message',
        category: 'Test', context: 'ColorTest');
    info('This is an INFO message', category: 'Test', context: 'ColorTest');
    debug('This is a DEBUG message', category: 'Test', context: 'ColorTest');
    suppressed('This is a SUPPRESSED message',
        category: 'Test', context: 'ColorTest');
    remote('This is a REMOTE message', category: 'Test', context: 'ColorTest');
    performance('This is a PERFORMANCE message',
        category: 'Test', context: 'ColorTest');
    success('This is a SUCCESS message',
        category: 'Test', context: 'ColorTest');

    separator();
  }
}
