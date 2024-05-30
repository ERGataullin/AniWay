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

VideoPlayerWM videoPlayerWMFactory(
  BuildContext context,
) =>
    VideoPlayerWM(
      VideoPlayerModel(context.read<ErrorHandler>()),
    );

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get aspectRatio;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  VideoController get controller;

  HideOnUserInactivityController get controlsVisibilityController;

  FullscreenController get fullscreenController;

  void onTapUp(TapUpDetails details);

  void onPreferencesPressed();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

  void onPreviousPressed();

  void onNextPressed();
}

class VideoPlayerWM
    extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    implements IVideoPlayerWM {
  VideoPlayerWM(super._model);

  @override
  final ValueNotifier<double> aspectRatio = ValueNotifier(1);

  @override
  final ValueNotifier<double> maxScale = ValueNotifier(1);

  @override
  final ValueNotifier<List<double>> scaleAnchors = ValueNotifier(const [1]);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> subtitle = ValueNotifier('');

  @override
  final HideOnUserInactivityController controlsVisibilityController =
      HideOnUserInactivityController();

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
    title.value = widget.title;
    subtitle.value = widget.subtitle;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model.surfaceAspectRatio = MediaQuery.of(context).size.aspectRatio;
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    title.value = widget.title;
    subtitle.value = widget.subtitle;

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
    controlsVisibilityController.stopShowing();
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
    aspectRatio.value = model.aspectRatio;
    maxScale.value = model.maxScale;
    scaleAnchors.value = model.scaleAnchors;

    fullscreenController.webElementQuery =
        defaultTargetPlatform == TargetPlatform.iOS
            ? 'video#videoElement-${model.textureId}'
            : null;

    model.loading || !model.playing
        ? controlsVisibilityController.startShowing()
        : controlsVisibilityController.stopShowing();
  }
}
