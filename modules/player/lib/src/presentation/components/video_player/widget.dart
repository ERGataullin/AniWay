import 'package:elementary/elementary.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

extension _VideoPlayerContext on BuildContext {
  IVideoPlayerWidgetModel get wm => read<IVideoPlayerWidgetModel>();
}

class VideoPlayerWidget extends ElementaryWidget<IVideoPlayerWidgetModel> {
  const VideoPlayerWidget({
    super.key,
    required this.controller,
    required this.controlsBuilder,
    WidgetModelFactory wmFactory = videoPlayerWidgetModelFactory,
  }) : super(wmFactory);

  final VideoController controller;

  final WidgetBuilder? controlsBuilder;

  @override
  Widget build(IVideoPlayerWidgetModel wm) {
    return Provider<IVideoPlayerWidgetModel>.value(
      value: wm,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _Player(),
            if (controlsBuilder != null) _Controls(builder: controlsBuilder!),
          ],
        ),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.wm.showPlayer,
      builder: (context, showPlayer, ___) => showPlayer
          ? ValueListenableBuilder<double>(
              valueListenable: context.wm.playerAspectRatio,
              builder: (context, aspectRation, ___) => AspectRatio(
                aspectRatio: aspectRation,
                child: VideoPlayer(context.wm.controller),
              ),
            )
          : const SizedBox.expand(),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return _UserActivityListener(
      child: ValueListenableBuilder<bool>(
        valueListenable: context.wm.showControls,
        child: builder(context),
        builder: (context, showControls, child) => AnimatedSwitcher(
          switchInCurve: Easing.emphasizedDecelerate,
          // TODO(ERGataullin): replace with Easing.emphasized
          switchOutCurve: Easing.emphasizedAccelerate,
          duration: Durations.long2,
          reverseDuration: Durations.short4,
          child: showControls ? child : null,
        ),
      ),
    );
  }
}

class _UserActivityListener extends StatelessWidget {
  const _UserActivityListener({
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MouseCursor>(
      valueListenable: context.wm.cursor,
      child: GestureDetector(
        onTapUp: context.wm.onTapUp,
        child: child,
      ),
      builder: (context, cursor, child) => MouseRegion(
        cursor: cursor,
        onHover: context.wm.onPointerHover,
        onExit: context.wm.onPointerExit,
        child: child,
      ),
    );
  }
}
