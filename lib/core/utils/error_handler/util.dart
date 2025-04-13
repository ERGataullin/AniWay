import 'package:app/core/core.dart';
import 'package:elementary/elementary.dart' as elementary;

abstract interface class ErrorHandler
    with Initable
    implements elementary.ErrorHandler {
  const ErrorHandler();
}
