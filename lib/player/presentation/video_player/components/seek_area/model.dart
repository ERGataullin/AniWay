import 'dart:core';

import 'package:app/core/core.dart';
import 'package:app/player/domain/models/seek_type.dart';
import 'package:app/player/presentation/video_player/const.dart';
import 'package:flutter/foundation.dart';

abstract interface class ISeekAreaModel implements ElementaryModel {
  ValueListenable<Duration> get value;

  bool canSeek({
    required SeekType seekType,
    required Duration position,
    required Duration duration,
  });

  Duration getSeekPosition({
    required SeekType seekType,
    required Duration position,
  });

  void incrementValue({required SeekType seekType});

  void resetValue();
}

class SeekAreaModel extends ElementaryModel implements ISeekAreaModel {
  SeekAreaModel({super.errorHandler});

  @override
  final ValueNotifier<Duration> value = ValueNotifier(Duration.zero);

  @override
  bool canSeek({
    required SeekType seekType,
    required Duration position,
    required Duration duration,
  }) {
    return switch (seekType) {
      SeekType.rewind => position > Duration.zero,
      SeekType.fastForward => position < duration,
    };
  }

  @override
  Duration getSeekPosition({
    required SeekType seekType,
    required Duration position,
  }) {
    return switch (seekType) {
      SeekType.rewind => position - seekGestureRewindStep,
      SeekType.fastForward => position + seekGestureFastForwardStep,
    };
  }

  @override
  void incrementValue({required SeekType seekType}) {
    value.value += switch (seekType) {
      SeekType.rewind => seekGestureRewindStep,
      SeekType.fastForward => seekGestureFastForwardStep,
    };
  }

  @override
  void resetValue() {
    value.value = Duration.zero;
  }

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }
}
