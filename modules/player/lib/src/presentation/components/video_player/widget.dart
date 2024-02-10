import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/widget_model.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends ElementaryWidget<IVideoPlayerWidgetModel> {
  const VideoPlayerWidget({
    super.key,
    required this.controller,
    WidgetModelFactory wmFactory = videoPlayerWidgetModelFactory,
  }) : super(wmFactory);

  final VideoController controller;

  @override
  Widget build(IVideoPlayerWidgetModel wm) {
    return Center(
      child: ValueListenableBuilder<double>(
        valueListenable: wm.playerAspectRatio,
        builder: (context, aspectRation, ___) => AspectRatio(
          aspectRatio: aspectRation,
          child: VideoPlayer(wm.controller),
        ),
      ),
    );
  }
}
