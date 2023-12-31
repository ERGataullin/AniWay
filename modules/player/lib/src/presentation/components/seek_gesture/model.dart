import 'dart:core';

import 'package:core/core.dart';

abstract interface class ISeekGestureModel implements ElementaryModel {}

class SeekGestureModel extends ElementaryModel implements ISeekGestureModel {
  SeekGestureModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
