import 'dart:async';

import 'package:app/core/data/services/network/network.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoController {
  VideoController({required NetworkService networkService})
    : _networkService = networkService;

  final loading = ValueNotifier<bool>(true);

  final aspectRatio = ValueNotifier<double>(1);

  final playing = ValueNotifier<bool>(false);

  final playbackSpeed = ValueNotifier<double>(1);

  final position = ValueNotifier<Duration>(Duration.zero);

  final duration = ValueNotifier<Duration>(Duration.zero);

  final caption = ValueNotifier<Caption>(Caption.none);

  final webElementQuery = ValueNotifier<String?>('');

  final _inner = ValueNotifier<VideoPlayerController?>(null);
  ValueListenable<VideoPlayerController?> get inner => _inner;

  final NetworkService _networkService;

  Future<void> setDataSource(
    Uri? uri, {
    Uri? captionsUri,
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
    if (captionsUri != null) {
      _inner.value!.setClosedCaptionFile(_getCaptions(captionsUri));
    }
    _inner.value!.addListener(_handleInnerValueChanged);
  }

  Future<void> play() async {
    _assertHasInner();
    playing.value = true;
    await _inner.value?.play();
  }

  Future<void> pause() async {
    _assertHasInner();
    playing.value = false;
    await _inner.value?.pause();
  }

  Future<void> playPause() async {
    playing.value ? await pause() : await play();
  }

  Future<void> seekTo(Duration position) async {
    _assertHasInner();
    final effectivePosition = Duration(
      milliseconds: (position.inMilliseconds ~/ 100) * 100,
    );
    print('Log: Seek to $position');
    this.position.value = effectivePosition;
    await _inner.value?.seekTo(effectivePosition);
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
    playbackSpeed.dispose();
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
        _inner.value?.value ?? const VideoPlayerValue.uninitialized();

    const positionMeasurementError = Duration(seconds: 1);
    final bool isPositionCorrect =
        (position.value - value.position).abs() <= positionMeasurementError;
    final bool isPositionBuffered = value.buffered.any(
      (range) =>
          range.start <= position.value + positionMeasurementError &&
          position.value <= range.end + positionMeasurementError,
    );
    loading.value = switch (defaultTargetPlatform) {
      _ when !value.isInitialized => true,
      _ when value.isCompleted || value.hasError => false,
      _ when kIsWeb => value.isBuffering,
      TargetPlatform.linux || TargetPlatform.windows => value.isBuffering,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS =>
        playing.value && (!isPositionCorrect || !isPositionBuffered),
    };
    // final Duration positionChangeMax = switch (defaultTargetPlatform) {
    //   _ when kIsWeb => Duration.zero,
    //   TargetPlatform.android ||
    //   TargetPlatform.iOS => const Duration(seconds: 1),
    //   TargetPlatform.fuchsia ||
    //   TargetPlatform.linux ||
    //   TargetPlatform.macOS ||
    //   TargetPlatform.windows => Duration.zero,
    // };
    // final bool isPositionCorrect =
    //     (position.value - value.position).abs() < positionChangeMax;
    // final bool isPositionBuffered = value.buffered.any(
    //   (range) =>
    //       range.start <= position.value + positionChangeMax &&
    //       position.value < range.end + positionChangeMax,
    // );
    // loading.value =
    //     !value.isCompleted &&
    //     !value.hasError &&
    //     playing.value &&
    //     (!isPositionCorrect || !isPositionBuffered);
    print(
      'Log: -----------------------------------------------------------------\n'
      'Log: Loading: ${loading.value}\n'
      'Log: Buffered: ${value.buffered}\n'
      'Log: Position: ${position.value}\n'
      'Log: Inner position: ${value.position}\n',
    );

    aspectRatio.value = value.aspectRatio;
    if (value.isCompleted || value.hasError) playing.value = false;
    playbackSpeed.value = value.playbackSpeed;
    if (!loading.value) position.value = value.position;
    duration.value = value.duration;
    caption.value = value.caption;
  }

  Future<ClosedCaptionFile> _getCaptions(Uri uri) async {
    final ResponseData<String> response = await _networkService.request(
      RequestData(uri: uri, method: RequestMethod.get),
    );
    return WebVTTCaptionFile(response.body);
  }
}
