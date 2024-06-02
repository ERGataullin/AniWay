import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/components/show_on_mouse_hover.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/utils/video_controller.dart';

VideoPlayerWM videoPlayerWMFactory(BuildContext context) => VideoPlayerWM(
      VideoPlayerModel(context.read<ErrorHandler>()),
    );

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get aspectRatio;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  VideoController get controller;

  VisibilityController get controlsVisibilityController;

  FullscreenController get fullscreenController;

  void onTapUp(TapUpDetails details);

  void onPreferencesPressed();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

  void onPreviousPressed();

  void onNextPressed();
}

class VideoPlayerWM extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    implements IVideoPlayerWM {
  VideoPlayerWM(super._model);

  @override
  late final ComputationNotifier<double> aspectRatio = ComputationNotifier(
    trigger: model,
    computation: () => model.aspectRatio,
  );

  @override
  late final ComputationNotifier<double> maxScale = ComputationNotifier(
    trigger: model,
    computation: () => model.maxScale,
  );

  @override
  late final ComputationNotifier<List<double>> scaleAnchors =
      ComputationNotifier(
    trigger: model,
    computation: () => model.scaleAnchors,
  );

  @override
  late final ComputationNotifier<String> title = ComputationNotifier(
    computation: () => widget.title,
  );

  @override
  late final ComputationNotifier<String> subtitle = ComputationNotifier(
    computation: () => widget.subtitle,
  );

  @override
  final VisibilityController controlsVisibilityController =
      VisibilityController();

  @override
  final FullscreenController fullscreenController = FullscreenController();

  @override
  VideoController get controller => model.videoController;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..addListener(_onModelChanged)
      ..videoController = widget.controller;
    title.update();
    subtitle.update();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model.surfaceAspectRatio = MediaQuery.of(context).size.aspectRatio;
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    title.update();
    subtitle.update();
    if (widget.controller != oldWidget.controller) {
      model.videoController = widget.controller;
    }
  }

  @override
  void onTapUp(TapUpDetails details) {
    const Set<PointerDeviceKind> precisePointerDevices = {
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
    };
    if (precisePointerDevices.contains(details.kind)) {
      model.togglePlayPause();
    }
  }

  @override
  Future<void> onPreferencesPressed() async {
    await showModalMenuBottomSheet(
      context: context,
      items: widget.preferences,
    );
  }

  @override
  void onPositionChangeStart(double position) {
    controlsVisibilityController.startShowing();
  }

  @override
  void onPositionChangeEnd(double position) {
    controlsVisibilityController.scheduleStopShowing();
  }

  @override
  void onPreviousPressed() {
    widget.onPreviousPressed();
  }

  @override
  void onNextPressed() {
    widget.onNextPressed();
  }

  @override
  void dispose() {
    super.dispose();
    model.removeListener(_onModelChanged);
    aspectRatio.dispose();
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    subtitle.dispose();
    controlsVisibilityController.dispose();
    fullscreenController
      ..exit()
      ..dispose();
  }

  void _onModelChanged() {
    fullscreenController.webElementQuery =
        defaultTargetPlatform == TargetPlatform.iOS
            ? 'video#videoElement-${model.textureId}'
            : null;

    model.loading || !model.playing
        ? controlsVisibilityController.startShowing()
        : controlsVisibilityController.scheduleStopShowing();
  }
}
