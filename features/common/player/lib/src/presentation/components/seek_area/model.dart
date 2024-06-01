import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';
import 'package:video_player/video_player.dart';

abstract interface class ISeekAreaModel implements ElementaryModel, Listenable {
  bool get canSeek;

  Duration get value;

  set videoController(VideoPlayerController value);

  set type(SeekType value);

  void seek();

  void submit();
}

class SeekAreaModel extends ElementaryModel
    with ChangeNotifier
    implements ISeekAreaModel {
  SeekAreaModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);

  static const Duration _step = Duration(seconds: 10);

  @override
  bool canSeek = false;

  @override
  Duration value = Duration.zero;

  @override
  set videoController(VideoPlayerController value) {
    _videoController?.removeListener(_onVideoPlayerChanged);
    _videoController = value..addListener(_onVideoPlayerChanged);
    _onVideoPlayerChanged();
  }

  @override
  set type(SeekType value) => _seekDuration = switch (value) {
        SeekType.rewind => -_step,
        SeekType.fastForward => _step,
      };

  late Duration _seekDuration;

  VideoPlayerController? _videoController;

  @override
  void seek() {
    value += _seekDuration;
    notifyListeners();
    _videoController!.seekTo(_videoController!.value.position + _seekDuration);
  }

  @override
  void submit() {
    value = Duration.zero;
    notifyListeners();
  }

  void _onVideoPlayerChanged() {
    final VideoPlayerValue videoPlayerValue = _videoController!.value;
    final bool newCanSeek = _seekDuration > Duration.zero
        ? videoPlayerValue.position < videoPlayerValue.duration
        : videoPlayerValue.position > Duration.zero;
    if (newCanSeek != canSeek) {
      canSeek = newCanSeek;
      notifyListeners();
    }
  }
}
