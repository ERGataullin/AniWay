import 'package:flutter/foundation.dart';

import '/app/domain/services/error_handle/service.dart';

class DebugPrintErrorHandleService implements ErrorHandleService {
  @override
  void handleError(Object error, {StackTrace? stackTrace}) {
    debugPrintStack(
      label: error.toString(),
      stackTrace: stackTrace,
    );
  }
}
