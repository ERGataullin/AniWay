import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:web/web.dart';

extension _DocumentFullscreen on Document {
  external Element? get fullscreenElement;

  external void exitFullscreen();
}

extension _ElementFullscreen on Element {
  external bool get webkitDisplayingFullscreen;

  external void requestFullscreen();

  external void webkitEnterFullscreen();

  external void webkitExitFullscreen();
}

class PlatformFullscreen implements Fullscreen {
  const PlatformFullscreen();

  @override
  bool isFullscreen([String? elementQuerySelector]) {
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          elementQuerySelector == null,
    );
    return elementQuerySelector == null
        ? document.fullscreenElement != null
        : document
            .querySelector(elementQuerySelector)!
            .webkitDisplayingFullscreen;
  }

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
    assert(
      defaultTargetPlatform == TargetPlatform.iOS ||
          elementQuerySelector == null,
    );
    elementQuerySelector == null
        ? document.exitFullscreen()
        : document.querySelector(elementQuerySelector)!.webkitExitFullscreen();
    return SynchronousFuture(null);
  }
}
