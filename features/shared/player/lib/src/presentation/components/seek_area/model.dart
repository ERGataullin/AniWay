import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/domain/models/seek_type.dart';

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
  SeekAreaModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);

  static const Duration _step = Duration(seconds: 10);

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
      SeekType.rewind => position - _step,
      SeekType.fastForward => position + _step,
    };
  }

  @override
  void incrementValue() {
    value.value += _step;
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
