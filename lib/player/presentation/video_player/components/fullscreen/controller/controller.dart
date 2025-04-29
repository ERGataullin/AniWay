import 'package:app/player/presentation/video_player/components/fullscreen/controller/io.dart'
    if (dart.library.html) 'package:app/player/presentation/video_player/components/fullscreen/controller/web.dart';
import 'package:flutter/material.dart';

abstract class FullscreenController implements ChangeNotifier {
  factory FullscreenController() {
    return FullscreenControllerImpl();
  }

  bool get supported;

  bool get isFullscreen;

  set webElementQuery(String? value);

  Future<void> request();

  Future<void> exit();

  Future<void> toggle();
}
