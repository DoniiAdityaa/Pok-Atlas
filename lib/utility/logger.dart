import 'package:logger/logger.dart';

/// Logger terpusat untuk PokéAtlas.
///
/// Pakai ini sebagai ganti [print] di mana pun di codebase.
/// Output hanya muncul di debug mode (DevelopmentFilter).
///
/// ```dart
/// LoggerHelper.d('Pokemon loaded: $name');
/// LoggerHelper.e('Fetch failed', error, stackTrace);
/// ```
class LoggerHelper {
  LoggerHelper._();

  static final Logger _logger = Logger(
    output: ConsoleOutput(),
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(
      errorMethodCount: 8,
      colors: true,
      printEmojis: true,
      levelColors: {
        Level.debug: const AnsiColor.fg(4),
        Level.info: const AnsiColor.fg(2),
        Level.warning: const AnsiColor.fg(3),
        Level.error: const AnsiColor.fg(1),
        Level.all: const AnsiColor.fg(7),
        Level.trace: const AnsiColor.fg(6),
        Level.fatal: const AnsiColor.fg(1),
        Level.off: const AnsiColor.fg(0),
      },
      lineLength: 110,
      levelEmojis: {
        Level.trace: '📝',
        Level.debug: '🐛',
        Level.info: 'ℹ️',
        Level.warning: '⚠️',
        Level.error: '🚨',
        Level.fatal: '🤷',
        Level.all: '🙌',
        Level.off: '🔇',
      },
    ),
  );

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void t(dynamic message) => _logger.t(message);
  static void f(dynamic message) => _logger.f(message);

  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
