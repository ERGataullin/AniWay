import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  VideoController() : super(const VideoPlayerValue(duration: Duration.zero)) {
    unawaited(initialize());
  }

  VideoPlayerController? _controller;

  @override
  String get dataSource => _controller!.dataSource;

  @override
  Map<String, String> get httpHeaders => _controller!.httpHeaders;

  @override
  VideoFormat? get formatHint => _controller!.formatHint;

  @override
  DataSourceType get dataSourceType => _controller!.dataSourceType;

  @override
  VideoPlayerOptions? get videoPlayerOptions => _controller!.videoPlayerOptions;

  @override
  String? get package => _controller!.package;

  @override
  // ignore: invalid_use_of_visible_for_testing_member
  int get textureId => _controller!.textureId;

  @override
  Future<Duration?> get position => _controller!.position;

  @override
  Future<ClosedCaptionFile>? get closedCaptionFile =>
      _controller!.closedCaptionFile;

  @override
  Future<void> initialize([Uri? uri]) async {
    final VideoPlayerController? oldController = _controller;
    _controller = VideoPlayerController.networkUrl(uri ?? Uri())
      ..addListener(_onControllerValueChanged);
    oldController?.dispose();
    await Future.wait([
      if (uri != null) ...[
        _controller!.initialize(),
        _controller!.play(),
      ],
    ]);
  }

  @override
  Future<void> play() async {
    await _controller!.play();
  }

  @override
  Future<void> setLooping(bool looping) async {
    await _controller!.setLooping(looping);
  }

  @override
  Future<void> pause() async {
    await _controller!.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller!.seekTo(position);
  }

  @override
  void setCaptionOffset(Duration offset) {
    _controller!.setCaptionOffset(offset);
  }

  @override
  Future<void> setClosedCaptionFile(
    Future<ClosedCaptionFile>? closedCaptionFile,
  ) async {
    await _controller!.setClosedCaptionFile(closedCaptionFile);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _controller!.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _controller!.setVolume(volume);
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller?.dispose();
  }

  void _onControllerValueChanged() {
    value = _controller!.value;
  }
}
