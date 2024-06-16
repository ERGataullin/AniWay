import 'package:core/core.dart';
import 'package:elementary/elementary.dart' as elementary;

abstract interface class ErrorHandler
    implements elementary.ErrorHandler, Initable {
  const ErrorHandler();
}
