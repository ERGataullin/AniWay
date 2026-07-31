import 'package:app/player/presentation/video_player/components/fullscreen/controller/controller.dart';
import 'package:flutter/material.dart';

class FullscreenButton extends StatelessWidget {
  const FullscreenButton({super.key, required this.controller});

  final FullscreenController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: controller.toggle,
      icon: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => AnimatedSwitcher(
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
