import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class IScalableModel implements ElementaryModel {}

class ScalableModel extends ElementaryModel implements IScalableModel {
  ScalableModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
