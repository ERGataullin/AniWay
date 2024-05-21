import 'package:flutter/services.dart';
import 'package:player/player.dart';

class PlatformFullscreen implements Fullscreen {
  const PlatformFullscreen();

  @override
  Future<void> request([String? elementQuerySelector]) {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exit([String? elementQuerySelector]) {
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
