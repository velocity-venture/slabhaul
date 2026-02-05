import 'package:flutter/foundation.dart';

/// Lightweight logger for SlabHaul services.
///
/// Uses [debugPrint] which is safe in production (throttled, won't crash).
/// In release mode, logs are stripped by the compiler when using [kDebugMode].
class AppLogger {
  static void error(String service, String operation, Object error,
      [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$service] ERROR in $operation: $error');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString().split('\n').take(5).join('\n'));
      }
    }
  }

  static void warn(String service, String message) {
    if (kDebugMode) {
      debugPrint('[$service] WARN: $message');
    }
  }

  static void info(String service, String message) {
    if (kDebugMode) {
      debugPrint('[$service] $message');
    }
  }
}
