import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/utils/video_controller.dart';

VideoPlayerWidgetModel videoPlayerWidgetModelFactory(BuildContext context) =>
    VideoPlayerWidgetModel(
      VideoPlayerModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IVideoPlayerWidgetModel implements IWidgetModel {
  ValueListenable<double> get playerAspectRatio;

  VideoController get controller;
}

class VideoPlayerWidgetModel
    extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    implements IVideoPlayerWidgetModel {
  VideoPlayerWidgetModel(super._model);

  @override
  ValueListenable<double> get playerAspectRatio => model.videoAspectRatio;

  @override
  VideoController get controller => model.videoController;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model.videoController = widget.controller;
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    model.videoController = widget.controller;
  }
}
