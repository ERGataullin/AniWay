import 'dart:async';

import 'package:app/core/data/services/network/network.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoController {
  VideoController({required NetworkService networkService})
    : _networkService = networkService;

  final loading = ValueNotifier<bool>(true);

  final playing = ValueNotifier<bool>(false);

  final aspectRatio = ValueNotifier<double>(1);

  final position = ValueNotifier<Duration>(Duration.zero);

  final duration = ValueNotifier<Duration>(Duration.zero);

  final playbackSpeed = ValueNotifier<double>(1);

  final webElementQuery = ValueNotifier<String?>('');

  final caption = ValueNotifier<Caption>(Caption.none);

  final _inner = ValueNotifier<VideoPlayerController?>(null);
  ValueListenable<VideoPlayerController?> get inner => _inner;

  final NetworkService _networkService;

  Future<void> setDataSource(
    Uri? uri, {
    Uri? subtitlesUri,
    bool saveState = false,
  }) async {
    await _inner.value?.pause();
    _inner.value
      ?..removeListener(_handleInnerValueChanged)
      ..dispose();
    _inner.value = null;
    loading.value = true;
    webElementQuery.value = null;
    caption.value = Caption.none;

    if (!saveState) {
      position.value = Duration.zero;
      duration.value = Duration.zero;
      playing.value = true;
      aspectRatio.value = 1;
    }

    if (uri == null) return;

    _inner.value = VideoPlayerController.networkUrl(uri);
    await _inner.value!.initialize();
    aspectRatio.value = _inner.value!.value.aspectRatio;
    // ignore: invalid_use_of_visible_for_testing_member
    webElementQuery.value = 'video#videoElement-${_inner.value!.textureId}';
    await _inner.value!.seekTo(position.value);
    if (playing.value) await play();
    if (subtitlesUri != null) {
      _inner.value!.setClosedCaptionFile(_getCaptions(subtitlesUri));
    }
    _inner.value!.addListener(_handleInnerValueChanged);
  }

  Future<void> play() async {
    _assertHasInner();
    await _inner.value?.play();
  }

  Future<void> pause() async {
    _assertHasInner();
    await _inner.value?.pause();
  }

  Future<void> playPause() async {
    playing.value ? await pause() : await play();
  }

  Future<void> seekTo(Duration position) async {
    _assertHasInner();
    await _inner.value?.seekTo(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _assertHasInner();
    await _inner.value?.setPlaybackSpeed(speed);
  }

  void dispose() {
    _inner
      ..value?.dispose()
      ..dispose();
    loading.dispose();
    playing.dispose();
    aspectRatio.dispose();
    position.dispose();
    duration.dispose();
    webElementQuery.dispose();
    caption.dispose();
  }

  void _assertHasInner() {
    assert(_inner.value != null);
  }

  void _handleInnerValueChanged() {
    final VideoPlayerValue value =
        _inner.value?.value ?? const VideoPlayerValue(duration: Duration.zero);

    position.value = value.position;
    duration.value = value.duration;
    playbackSpeed.value = value.playbackSpeed;
    loading.value =
        kIsWeb ? value.isBuffering : value.isBuffering && !value.isPlaying;
    playing.value = value.isPlaying;
    aspectRatio.value = value.aspectRatio;
    caption.value = value.caption;
  }

  Future<ClosedCaptionFile> _getCaptions(Uri subtitlesUri) async {
    final ResponseData<String> response = await _networkService.request(
      RequestData(uri: subtitlesUri, method: RequestMethod.get),
    );
    return WebVTTCaptionFile(response.body);
  }
}
