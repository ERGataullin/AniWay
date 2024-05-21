import 'package:player/src/utils/fullscreen/io.dart'
    if (dart.library.html) 'package:player/src/utils/fullscreen/web.dart';

abstract class Fullscreen {
  factory Fullscreen() {
    return PlatformFullscreen();
  }

  bool isFullscreen([String? elementQuerySelector]);

  Future<void> request([String? elementQuerySelector]);

  Future<void> exit([String? elementQuerySelector]);
}
