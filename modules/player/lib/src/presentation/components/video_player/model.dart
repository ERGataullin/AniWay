import 'dart:core';

import 'package:core/core.dart';

abstract interface class IVideoPlayerModel implements ElementaryModel {}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
