import 'package:flutter/foundation.dart';

/// Wrapper class made to log multiple types of data while developement.
/// Predominantly used to get around `flutter_lint`.
///
/// Only prints in debug mode, using `kDebugMode`.
class Logger {
  /// Logs info in console, only in debug mode.
  Logger.i(dynamic log) {
    if (kDebugMode) {
      print(log);
    }
    return;
  }
}
