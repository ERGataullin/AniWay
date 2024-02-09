import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:video_player/video_player.dart';

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
  final ValueNotifier<double> playerAspectRatio = ValueNotifier(1);

  @override
  late VideoController controller;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    controller = widget.controller..addListener(_onControllerValueChanged);
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    if (widget.controller != oldWidget.controller) {
      controller.removeListener(_onControllerValueChanged);
      controller = widget.controller..addListener(_onControllerValueChanged);
    }
  }

  @override
  void dispose() {
    super.dispose();
    playerAspectRatio.dispose();
    controller.removeListener(_onControllerValueChanged);
  }

  void _onControllerValueChanged() {
    final VideoPlayerValue value = controller.value;

    playerAspectRatio.value = value.aspectRatio;
  }
}
