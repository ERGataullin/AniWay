import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart' as video_player;

sealed class VideoController {
  const VideoController();

  factory VideoController.videoPlayer() => VideoPlayerController();

  ValueListenable<bool> get loading;

  ValueListenable<bool> get playing;

  ValueListenable<double> get aspectRatio;

  ValueListenable<Duration> get position;

  ValueListenable<Duration> get duration;

  ValueListenable<String?> get webElementQuery;

  Future<void> setDataSource(
    Uri? uri, {
    bool saveState = false,
  });

  Future<void> play();

  Future<void> pause();

  Future<void> playPause();

  Future<void> seekTo(Duration position);

  @mustCallSuper
  void dispose() {}
}

class VideoPlayerController extends VideoController {
  @override
  final ValueNotifier<bool> loading = ValueNotifier(true);

  @override
  final ValueNotifier<bool> playing = ValueNotifier(false);

  @override
  final ValueNotifier<double> aspectRatio = ValueNotifier(1);

  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  @override
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);

  @override
  final ValueNotifier<String?> webElementQuery = ValueNotifier('');

  final ValueNotifier<video_player.VideoPlayerController?> _inner =
      ValueNotifier(null);

  ValueListenable<video_player.VideoPlayerController?> get inner => _inner;

  @override
  Future<void> setDataSource(
    Uri? uri, {
    bool saveState = false,
  }) async {
    await _inner.value?.pause();
    _inner.value
      ?..removeListener(_handleInnerValueChanged)
      ..dispose();
    _inner.value = null;
    loading.value = true;
    webElementQuery.value = null;

    if (!saveState) {
      position.value = Duration.zero;
      duration.value = Duration.zero;
      playing.value = true;
      aspectRatio.value = 1;
    }

    if (uri == null) return;

    _inner.value = video_player.VideoPlayerController.networkUrl(uri);
    await _inner.value!.initialize();
    aspectRatio.value = _inner.value!.value.aspectRatio;
    // ignore: invalid_use_of_visible_for_testing_member
    webElementQuery.value = 'video#videoElement-${_inner.value!.textureId}';
    await _inner.value!.seekTo(position.value);
    if (playing.value) await play();
    _inner.value!.addListener(_handleInnerValueChanged);
  }

  @override
  Future<void> play() async {
    _assertHasInner();
    await _inner.value?.play();
  }

  @override
  Future<void> pause() async {
    _assertHasInner();
    await _inner.value?.pause();
  }

  @override
  Future<void> playPause() async {
    playing.value ? await pause() : await play();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _assertHasInner();
    await _inner.value?.seekTo(position);
  }

  @override
  void dispose() {
    _inner.value?.dispose();
    _inner.dispose();
    loading.dispose();
    playing.dispose();
    aspectRatio.dispose();
    position.dispose();
    duration.dispose();
    webElementQuery.dispose();
    super.dispose();
  }

  void _assertHasInner() {
    assert(_inner.value != null);
  }

  void _handleInnerValueChanged() {
    final video_player.VideoPlayerValue value = _inner.value?.value ??
        const video_player.VideoPlayerValue(duration: Duration.zero);

    position.value = value.position;
    duration.value = value.duration;
    loading.value =
        _inner.value == null || !value.isInitialized || value.isBuffering;
    playing.value = value.isPlaying;
    aspectRatio.value = value.aspectRatio;
  }
}
