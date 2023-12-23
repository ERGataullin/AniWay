import 'package:player/src/utils/fullscreen/io.dart'
    if (dart.library.html) 'package:player/src/utils/fullscreen/web.dart';

abstract class Fullscreen {
  factory Fullscreen() {
    return const PlatformFullscreen();
  }

  Future<void> request();

  Future<void> exit();
}
