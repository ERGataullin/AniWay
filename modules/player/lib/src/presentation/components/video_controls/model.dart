import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

abstract interface class IVideoControlsModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<bool> get playing;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<Duration> get position;

  ValueListenable<Duration> get duration;

  VideoController get videoController;

  set videoController(VideoController value);

  set aspectRatio(double value);

  void togglePlayPause();
}

class VideoControlsModel extends ElementaryModel
    implements IVideoControlsModel {
  VideoControlsModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  @override
  ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  ValueNotifier<bool> playing = ValueNotifier(false);

  @override
  ValueNotifier<double> maxScale = ValueNotifier(1);

  @override
  ValueNotifier<List<double>> scaleAnchors = ValueNotifier(const [1]);

  @override
  ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  @override
  ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);

  @override
  VideoController get videoController {
    assert(_videoController != null);
    return _videoController!;
  }

  @override
  set videoController(VideoController value) {
    _videoController?.removeListener(_onVideoControllerValueChanged);
    _videoController = value..addListener(_onVideoControllerValueChanged);
    _onVideoControllerValueChanged();
  }

  @override
  set aspectRatio(double value) {
    _aspectRatio = value;
    _updateScaling();
  }

  double _aspectRatio = 1;

  VideoController? _videoController;

  @override
  Future<void> togglePlayPause() async {
    videoController.value.isPlaying
        ? await videoController.pause()
        : await videoController.play();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.removeListener(_onVideoControllerValueChanged);
    loading.dispose();
    playing.dispose();
    maxScale.dispose();
    scaleAnchors.dispose();
    position.dispose();
    duration.dispose();
  }

  void _onVideoControllerValueChanged() {
    final VideoPlayerValue value = videoController.value;

    loading.value = !value.isInitialized || value.isBuffering;
    playing.value = value.isPlaying;
    position.value = value.position;
    duration.value = value.duration;

    _updateScaling();
  }

  void _updateScaling() {
    maxScale.value = _aspectRatio / videoController.value.aspectRatio;
    scaleAnchors.value = List.unmodifiable(<double>[1, maxScale.value]);
  }
}
