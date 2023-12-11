import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class IVideoControlsModel implements ElementaryModel {}

class VideoControlsModel extends ElementaryModel
    implements IVideoControlsModel {
  VideoControlsModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
