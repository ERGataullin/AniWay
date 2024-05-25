import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/src/presentation/components/seek_area/widget.dart';

abstract interface class ISeekAreaModel implements ElementaryModel, Listenable {
  Duration get value;

  set type(SeekType value);

  set onSeek(OnSeek value);

  void seek();

  void submit();
}

class SeekAreaModel extends ElementaryModel
    with ChangeNotifier
    implements ISeekAreaModel {
  SeekAreaModel(ErrorHandler errorHandler) : super(errorHandler: errorHandler);

  static const Duration _step = Duration(seconds: 10);

  @override
  Duration value = Duration.zero;

  @override
  set type(SeekType value) => _type = value;

  @override
  set onSeek(OnSeek value) => _onSeek = value;

  late SeekType _type;

  late OnSeek _onSeek;

  @override
  void seek() {
    final Duration seekDuration = switch (_type) {
      SeekType.rewind => -_step,
      SeekType.fastForward => _step,
    };
    value += seekDuration;
    notifyListeners();
    _onSeek(seekDuration);
  }

  @override
  void submit() {
    value = Duration.zero;
    notifyListeners();
  }
}
