import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/utils/video_controller.dart';

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<double> get videoAspectRatio;

  VideoController get videoController;

  set videoController(VideoController value);
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  @override
  final ValueNotifier<double> videoAspectRatio = ValueNotifier(1);

  @override
  VideoController get videoController {
    assert(_videoController != null);
    return _videoController!;
  }

  @override
  set videoController(VideoController value) {
    if (_videoController == value) {
      return;
    }

    _videoController?.removeListener(_onVideoControllerValueChanged);
    _videoController = value..addListener(_onVideoControllerValueChanged);
    _onVideoControllerValueChanged();
  }

  VideoController? _videoController;

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoControllerValueChanged);
    videoAspectRatio.dispose();
  }

  void _onVideoControllerValueChanged() {
    videoAspectRatio.value = videoController.value.aspectRatio;
  }
}
