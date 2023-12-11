// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:player/player.dart';

class PlatformFullscreen implements Fullscreen {
  const PlatformFullscreen();

  @override
  Future<void> request() {
    return document.documentElement!.requestFullscreen();
  }

  @override
  Future<void> exit() {
    return Future(document.exitFullscreen);
  }
}
