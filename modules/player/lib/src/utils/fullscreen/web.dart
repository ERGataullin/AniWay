import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:web/web.dart';

extension _ElementFullscreen on Element {
  external void requestFullscreen();

  external void exitFullscreen();

  external void webkitEnterFullscreen();

  external void webkitExitFullscreen();
}

class PlatformFullscreen implements Fullscreen {
  const PlatformFullscreen();

  @override
  Future<void> request([String? elementQuerySelector]) {
    final Element element = elementQuerySelector == null
        ? document.documentElement!
        : document.querySelector(elementQuerySelector)!;
    defaultTargetPlatform == TargetPlatform.iOS
        ? element.webkitEnterFullscreen()
        : element.requestFullscreen();
    return SynchronousFuture(null);
  }

  @override
  Future<void> exit([String? elementQuerySelector]) {
    final Element element = elementQuerySelector == null
        ? document.documentElement!
        : document.querySelector(elementQuerySelector)!;
    defaultTargetPlatform == TargetPlatform.iOS
        ? element.webkitExitFullscreen()
        : element.exitFullscreen();
    return SynchronousFuture(null);
  }
}
