import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class ISeekGestureDetectorModel implements ElementaryModel {}

class SeekGestureDetectorModel extends ElementaryModel
    implements ISeekGestureDetectorModel {
  SeekGestureDetectorModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
