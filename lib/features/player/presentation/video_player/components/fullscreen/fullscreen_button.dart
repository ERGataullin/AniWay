import 'package:app/features/player/presentation/video_player/components/fullscreen/io.dart'
    if (dart.library.html) 'package:app/features/player/presentation/video_player/components/fullscreen/web.dart';
import 'package:flutter/material.dart';

abstract class FullscreenController implements ChangeNotifier {
  factory FullscreenController() {
    return FullscreenControllerPlatform();
  }

  bool get isFullscreen;

  set webElementQuery(String? value);

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
          switchOutCurve: Easing.standard.flipped,
          duration: Durations.medium2,
          child: Icon(
            controller.isFullscreen
                ? Icons.fullscreen_exit_outlined
                : Icons.fullscreen_outlined,
            key: ValueKey(controller.isFullscreen),
          ),
        ),
      ),
    );
  }
}
