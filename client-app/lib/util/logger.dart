import 'package:flutter/foundation.dart';

/// Wrapper class made to log multiple types of data while developement.
/// Predominantly used to get around `flutter_lint`.
///
/// Only prints in debug mode, using `kDebugMode`.
class Logger {
  static void _printWarning(String text) {
    // ignore: avoid_print
    print('\x1B[33m$text\x1B[0m');
  }

  static void _printError(String text) {
    // ignore: avoid_print
    print('\x1B[31m$text\x1B[0m');
  }

  /// Logs info in console, only in debug mode.
  Logger.i(dynamic log) {
    if (kDebugMode) {
      print(log);
    }
    return;
  }

  Logger.w(dynamic log) {
    if (kDebugMode) {
      _printWarning(log);
    }
    return;
  }

  Logger.e(dynamic log) {
    if (kDebugMode) {
      _printError(log);
    }
    return;
  }
}
