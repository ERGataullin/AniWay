import 'dart:core';

import 'package:app/core/core.dart';
import 'package:app/features/player/domain/models/seek_type.dart';
import 'package:app/features/player/presentation/video_player/const.dart';
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

  void incrementValue();

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
      SeekType.rewind => position - shortcutSeekDuration,
      SeekType.fastForward => position + shortcutSeekDuration,
    };
  }

  @override
  void incrementValue() {
    value.value += shortcutSeekDuration;
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
