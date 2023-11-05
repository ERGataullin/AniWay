import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class DebugPrintErrorHandler implements ErrorHandler {
  const DebugPrintErrorHandler();

  @override
  void handleError(Object error, {StackTrace? stackTrace}) {
    debugPrintStack(
      label: error.toString(),
      stackTrace: stackTrace,
    );
  }
}
