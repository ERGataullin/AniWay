import 'package:app/player/presentation/video_player/components/fullscreen/controller/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class FullscreenControllerImpl
    with ChangeNotifier
    implements FullscreenController {
  FullscreenControllerImpl() {
    ServicesBinding.instance.keyboard.addHandler(_handleKeyPressed);
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  var _isFullscreen = false;
  @override
  bool get isFullscreen => _isFullscreen;

  @override
  bool get supported => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.fuchsia ||
    TargetPlatform.iOS => false,
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => true,
  };

  @override
  set webElementQuery(String? value) {}

  @override
  Future<void> request() async {
    assert(supported);
    await windowManager.ensureInitialized();
    windowManager.setFullScreen(true);
    _isFullscreen = true;
    notifyListeners();
  }

  @override
  Future<void> exit() async {
    await windowManager.ensureInitialized();
    windowManager.setFullScreen(false);
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
