import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:player/src/presentation/video_player/components/fullscreen/fullscreen_button.dart';
import 'package:web/web.dart';

extension _ElementFullscreen on Element {
  external bool get webkitDisplayingFullscreen;

  external void webkitEnterFullscreen();

  external void webkitExitFullscreen();

  Stream<Event> get nonWebkitOnFullscreenChange =>
      const EventStreamProvider<Event>('fullscreenchange').forElement(this);
}

class FullscreenControllerPlatform
    with ChangeNotifier
    implements FullscreenController {
  FullscreenControllerPlatform() : _element = document.documentElement! {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
    _fullscreenSubscription =
        _element.nonWebkitOnFullscreenChange.listen(_onFullscreenChanged);
  }

  Element _element;

  late StreamSubscription<Event> _fullscreenSubscription;

  @override
  bool get isFullscreen {
    return _isIos
        ? _element.tagName == 'video' && _element.webkitDisplayingFullscreen
        : document.fullscreenElement == _element;
  }

  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  set webElementQuery(String? value) {
    final Element newElement = value == null
        ? document.documentElement!
        : document.querySelector(value)!;

    if (_element == newElement) {
      return;
    }

    _element = newElement;
    _fullscreenSubscription.cancel();
    _fullscreenSubscription =
        _element.nonWebkitOnFullscreenChange.listen(_onFullscreenChanged);
  }

  @override
  Future<void> request() {
    _isIos ? _element.webkitEnterFullscreen() : _element.requestFullscreen();
    return SynchronousFuture(null);
  }

  @override
  Future<void> exit() {
    if (!isFullscreen) {
      return SynchronousFuture(null);
    }
    _isIos ? _element.webkitExitFullscreen() : document.exitFullscreen();
    return SynchronousFuture(null);
  }

  @override
  Future<void> toggle() {
    isFullscreen ? exit() : request();
    return SynchronousFuture(null);
  }

  @override
  void dispose() {
    super.dispose();
    _fullscreenSubscription.cancel();
  }

  void _onFullscreenChanged(Event event) {
    notifyListeners();
  }
}
