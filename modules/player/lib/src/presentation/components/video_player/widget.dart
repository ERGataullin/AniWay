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
    WidgetModelFactory wmFactory = videoPlayerWidgetModelFactory,
  }) : super(wmFactory);

  final VideoController controller;

  @override
  Widget build(IVideoPlayerWidgetModel wm) {
    return Provider<IVideoPlayerWidgetModel>.value(
      value: wm,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Colors.black),
        child: _Player(),
      ),
    );
  }
}

class _Player extends StatelessWidget {
  const _Player();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: context.wm.playerAspectRatio,
      builder: (context, aspectRation, ___) => AspectRatio(
        aspectRatio: aspectRation,
        child: VideoPlayer(context.wm.controller),
      ),
    );
  }
}
