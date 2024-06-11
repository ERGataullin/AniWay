import 'package:flutter/gestures.dart';

extension PointerDeviceKindExtension on PointerDeviceKind {
  bool get mobile => switch (this) {
        PointerDeviceKind.touch ||
        PointerDeviceKind.stylus ||
        PointerDeviceKind.invertedStylus =>
          true,
        PointerDeviceKind.mouse ||
        PointerDeviceKind.trackpad ||
        PointerDeviceKind.unknown =>
          false,
      };
}
