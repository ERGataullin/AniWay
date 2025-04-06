import 'package:app/player/presentation/video_player/components/fullscreen/fullscreen_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class FullscreenControllerPlatform
    with ChangeNotifier
    implements FullscreenController {
  FullscreenControllerPlatform() {
    ServicesBinding.instance.keyboard.addHandler(_handleKeyPressed);
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  var _isFullscreen = false;
  @override
  bool get isFullscreen => _isFullscreen;

  @override
  set webElementQuery(String? value) {}

  @override
  Future<void> request() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        await windowManager.ensureInitialized();
        windowManager.waitUntilReadyToShow(
          const WindowOptions(fullScreen: true),
        );
      case TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.iOS ||
          TargetPlatform.linux ||
          TargetPlatform.macOS:
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    _isFullscreen = true;
    notifyListeners();
  }

  @override
  Future<void> exit() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        await windowManager.ensureInitialized();
        windowManager.waitUntilReadyToShow(
          const WindowOptions(fullScreen: false),
        );
      case TargetPlatform.android ||
          TargetPlatform.fuchsia ||
          TargetPlatform.iOS ||
          TargetPlatform.linux ||
          TargetPlatform.macOS:
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _isFullscreen = false;
    notifyListeners();
  }

  @override
  Future<void> toggle() {
    return _isFullscreen ? exit() : request();
  }

  bool _handleKeyPressed(KeyEvent event) {
    if (!_isFullscreen) return false;
    if (event is! KeyUpEvent) return false;
    if (event.physicalKey != PhysicalKeyboardKey.escape) return false;
    exit();
    return true;
  }
}
