import 'dart:core';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:player/player.dart';

abstract interface class IVideoPlayerModel implements ElementaryModel {
  Future<VideoData> getTranslationVideo(Uri embedUri);
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(
    ErrorHandler errorHandler, {
    required PlayerService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final PlayerService _service;

  @override
  Future<VideoData> getTranslationVideo(Uri embedUri) {
    return _service.getTranslationVideo(embedUri);
  }
}
