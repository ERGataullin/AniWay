import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;

abstract interface class IVideoPlayerModel implements ElementaryModel {}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);
}
