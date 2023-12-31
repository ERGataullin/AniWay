import 'dart:core';

import 'package:core/core.dart';

abstract interface class IVideoControlsModel implements ElementaryModel {}

class VideoControlsModel extends ElementaryModel
    implements IVideoControlsModel {
  VideoControlsModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
