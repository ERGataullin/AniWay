import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/domain/models/side.dart';
import 'package:player/src/utils/video_controller.dart';

abstract interface class ISeekGestureModel implements ElementaryModel {
  ValueListenable<bool> get canSeek;

  ValueListenable<Duration> get value;

  set videoController(VideoController value);

  set side(Side value);

  void seek();

  void submit();
}

class SeekGestureModel extends ElementaryModel implements ISeekGestureModel {
  SeekGestureModel(ErrorHandler errorHandler)
      : super(errorHandler: errorHandler);

  static const Duration _step = Duration(seconds: 10);

  @override
  final ValueNotifier<bool> canSeek = ValueNotifier(false);

  @override
  final ValueNotifier<Duration> value = ValueNotifier(Duration.zero);

  @override
  set videoController(VideoController value) {
    _videoController?.removeListener(_onVideoControllerValueChanged);
    _videoController = value..addListener(_onVideoControllerValueChanged);
    _onVideoControllerValueChanged();
  }

  @override
  set side(Side value) => _side = value;

  late Side _side;

  VideoController? _videoController;

  @override
  Future<void> seek() async {
    assert(_videoController != null);
    assert(canSeek.value);

    value.value += _step;
    await _videoController!.seekTo(
      _videoController!.value.position +
          switch (_side) {
            Side.left => -_step,
            Side.right => _step,
          },
    );
  }

  @override
  void submit() {
    value.value = Duration.zero;
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.removeListener(_onVideoControllerValueChanged);
    canSeek.dispose();
    value.dispose();
  }

  void _onVideoControllerValueChanged() {
    assert(_videoController != null);

    final bool canSeek = switch (_side) {
      Side.left => _videoController!.value.position > Duration.zero,
      Side.right =>
        _videoController!.value.position < _videoController!.value.duration,
    };

    if (this.canSeek.value != canSeek) {
      this.canSeek.value = canSeek;
    }
  }
}
