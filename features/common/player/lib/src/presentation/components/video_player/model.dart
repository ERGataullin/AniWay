import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

abstract interface class IVideoPlayerModel
    implements ElementaryModel, Listenable {
  bool get loading;

  bool get playing;

  Object get textureId;

  double get aspectRatio;

  double get maxScale;

  List<double> get scaleAnchors;

  Duration get position;

  Duration get duration;

  VideoController get videoController;

  set videoController(VideoController value);

  set surfaceAspectRatio(double value);

  void togglePlayPause();
}

class VideoPlayerModel extends ElementaryModel
    with ChangeNotifier
    implements IVideoPlayerModel {
  VideoPlayerModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  bool loading = false;

  @override
  bool playing = false;

  @override
  Object textureId = VideoController.kUninitializedTextureId;

  @override
  double aspectRatio = 1;

  @override
  double maxScale = 1;

  @override
  List<double> scaleAnchors = const [1];

  @override
  Duration position = Duration.zero;

  @override
  Duration duration = Duration.zero;

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
  }

  void _onVideoPlayerChanged() {
    final VideoPlayerValue value = videoController.value;

    if (!value.isInitialized) {
      loading = true;
      notifyListeners();
      return;
    }

    loading = !value.isInitialized || value.isBuffering;
    playing = value.isPlaying;
    textureId = videoController.textureId;
    aspectRatio = value.aspectRatio;
    position = value.position;
    duration = value.duration;

    _updateScaling();
  }

  void _updateScaling() {
    maxScale = max(
      _surfaceAspectRatio / videoController.value.aspectRatio,
      videoController.value.aspectRatio / _surfaceAspectRatio,
    );
    scaleAnchors = List.unmodifiable([1, maxScale]);
    notifyListeners();
  }
}
