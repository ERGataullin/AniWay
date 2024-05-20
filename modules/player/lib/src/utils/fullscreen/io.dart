import 'package:flutter/services.dart';
import 'package:player/player.dart';

class PlatformFullscreen implements Fullscreen {
  PlatformFullscreen();

  @override
  bool isFullscreen = false;

  @override
  Future<void> request() {
    isFullscreen = true;
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exit() {
    isFullscreen = false;
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
