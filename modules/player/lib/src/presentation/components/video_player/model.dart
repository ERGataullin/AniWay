import 'dart:core';
import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

abstract interface class IVideoPlayerModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<bool> get playing;

  ValueListenable<Object> get textureId;

  ValueListenable<double> get aspectRatio;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<Duration> get position;

  ValueListenable<Duration> get duration;

  VideoController get videoController;

  set videoController(VideoController value);

  set surfaceAspectRatio(double value);

  void togglePlayPause();
}

class VideoPlayerModel extends ElementaryModel implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  @override
  ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  ValueNotifier<bool> playing = ValueNotifier(false);

  @override
  final ValueNotifier<Object> textureId = ValueNotifier(
    VideoController.kUninitializedTextureId,
  );

  @override
  final ValueNotifier<double> aspectRatio = ValueNotifier(1);

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
    _videoController?.removeListener(_onVideoPlayerChanged);
    _videoController = value..addListener(_onVideoPlayerChanged);
    _onVideoPlayerChanged();
  }

  @override
  set surfaceAspectRatio(double value) {
    _surfaceAspectRatio = value;
    _updateScaling();
  }
  
  double _surfaceAspectRatio = 1;

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
    _videoController?.removeListener(_onVideoPlayerChanged);
    loading.dispose();
    playing.dispose();
    textureId.dispose();
    aspectRatio.dispose();
    maxScale.dispose();
    scaleAnchors.dispose();
    position.dispose();
    duration.dispose();
  }

  void _onVideoPlayerChanged() {
    final VideoPlayerValue value = videoController.value;

    if (!value.isInitialized) {
      loading.value = true;
      return;
    }

    loading.value = !value.isInitialized || value.isBuffering;
    playing.value = value.isPlaying;
    textureId.value = videoController.textureId;
    aspectRatio.value = value.aspectRatio;
    position.value = value.position;
    duration.value = value.duration;

    _updateScaling();
  }
  
  void _updateScaling() {
    maxScale.value = max(
      _surfaceAspectRatio / videoController.value.aspectRatio,
      videoController.value.aspectRatio / _surfaceAspectRatio,
    );
    scaleAnchors.value = List.unmodifiable(<double>[1, maxScale.value]);
  }
}
