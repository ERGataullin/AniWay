import 'dart:core';

import 'package:core/core.dart';

abstract interface class IScalableModel implements ElementaryModel {}

class ScalableModel extends ElementaryModel implements IScalableModel {
  ScalableModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);
}
