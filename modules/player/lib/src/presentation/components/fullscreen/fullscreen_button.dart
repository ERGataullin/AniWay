import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/fullscreen/io.dart'
    if (dart.library.html) 'package:player/src/presentation/components/fullscreen/web.dart';

abstract class FullscreenController implements ChangeNotifier {
  factory FullscreenController({
    String? webElementQuery,
  }) {
    return FullscreenControllerPlatform(webElementQuery: webElementQuery);
  }

  bool get isFullscreen;

  Future<void> request();

  Future<void> exit();

  Future<void> toggle();
}

class FullscreenButton extends StatelessWidget {
  const FullscreenButton({
    super.key,
    required this.controller,
  });

  final FullscreenController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: controller.toggle,
      icon: ListenableBuilder(
        listenable: controller,
        builder: (context, __) => AnimatedSwitcher(
          switchInCurve: Easing.standard,
          duration: Durations.medium2,
          child: Icon(
            controller.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            key: ValueKey(controller.isFullscreen),
          ),
        ),
      ),
    );
  }
}
