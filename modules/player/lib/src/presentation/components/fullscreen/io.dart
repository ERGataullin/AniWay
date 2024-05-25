import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';

class FullscreenControllerPlatform
    with ChangeNotifier
    implements FullscreenController {
  FullscreenControllerPlatform({
    // ignore: avoid_unused_constructor_parameters
    String? webElementQuery,
  }) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  bool _isFullscreen = false;

  @override
  bool get isFullscreen {
    return _isFullscreen;
  }

  @override
  Future<void> request() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _isFullscreen = true;
    notifyListeners();
  }

  @override
  Future<void> exit() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _isFullscreen = false;
    notifyListeners();
  }

  @override
  Future<void> toggle() {
    return _isFullscreen ? exit() : request();
  }
}
