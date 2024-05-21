import 'package:flutter/services.dart';
import 'package:player/player.dart';

class PlatformFullscreen implements Fullscreen {
  PlatformFullscreen();

  bool _isFullscreen = false;

  @override
  bool isFullscreen([String? elementQuerySelector]) {
    return _isFullscreen;
  }

  @override
  Future<void> request([String? elementQuerySelector]) {
    _isFullscreen = true;
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Future<void> exit([String? elementQuerySelector]) {
    _isFullscreen = false;
    return SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
