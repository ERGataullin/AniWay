import 'package:flutter/gestures.dart';

extension PointerDevicesAccuracy on PointerDeviceKind {
  static final Set<PointerDeviceKind> accurateDevices =
      PointerDeviceKind.values.where((device) => device.accurate).toSet();

  static final Set<PointerDeviceKind> inaccurateDevices =
      PointerDeviceKind.values.where((device) => !device.accurate).toSet();

  bool get accurate => switch (this) {
    PointerDeviceKind.mouse || PointerDeviceKind.trackpad => true,
    PointerDeviceKind.touch ||
    PointerDeviceKind.stylus ||
    PointerDeviceKind.invertedStylus ||
    PointerDeviceKind.unknown => false,
  };
}
