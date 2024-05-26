import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/utils/video_controller.dart';

VideoPlayerWidgetModel videoPlayerWidgetModelFactory(
  BuildContext context,
) =>
    VideoPlayerWidgetModel(
      VideoPlayerModel(context.read<ErrorHandler>()),
    );

abstract interface class IVideoPlayerWidgetModel implements IWidgetModel {
  ValueListenable<bool> get visible;

  ValueListenable<MouseCursor> get cursor;

  ValueListenable<double> get aspectRatio;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<bool> get rewindEnabled;

  ValueListenable<bool> get fastForwardEnabled;

  ValueListenable<double> get positionValue;

  VideoController get controller;

  FullscreenController get fullscreenController;

  void onTapUp(TapUpDetails details);

  void onPointerHover(PointerHoverEvent event);

  void onPointerExit(PointerExitEvent event);

  void onPreferencesPressed();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

  void onPositionChanged(double position);

  void onSeek(Duration seekDuration);

  void onPreviousButtonPressed();

  void onNextPressed();
}

class VideoPlayerWidgetModel
    extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    with _HideOnUserInactivityWidgetModelMixin
    implements IVideoPlayerWidgetModel {
  VideoPlayerWidgetModel(super._model);

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
  final ValueNotifier<bool> rewindEnabled = ValueNotifier(false);

  @override
  final ValueNotifier<bool> fastForwardEnabled = ValueNotifier(false);

  @override
  final ValueNotifier<double> positionValue = ValueNotifier(0);

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
    show();
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
    super.onTapUp(details);

    if (details.kind == PointerDeviceKind.touch) {
      return;
    }

    model.togglePlayPause();
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
    show(hideOnUserInactivity: false);
  }

  @override
  void onPositionChangeEnd(double position) {
    show();
  }

  @override
  Future<void> onPositionChanged(double position) async {
    await controller.seekTo(controller.value.duration * position);
  }

  @override
  Future<void> onSeek(Duration seekDuration) async {
    await controller.seekTo(controller.value.position + seekDuration);
  }

  @override
  void onPreviousButtonPressed() {
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
    rewindEnabled.dispose();
    fastForwardEnabled.dispose();
    positionValue.dispose();
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

    rewindEnabled.value = model.position > Duration.zero;
    fastForwardEnabled.value = model.position < model.duration;

    positionValue.value = model.duration == Duration.zero
        ? 0
        : model.position.inSeconds / model.duration.inSeconds;

    if (model.loading || !model.playing) {
      show(hideOnUserInactivity: false);
    } else if (model.playing) {
      hideOnUserInactivity(restartUserInactivityTimer: false);
    }
  }
}

mixin _HideOnUserInactivityWidgetModelMixin<W extends ElementaryWidget,
    M extends ElementaryModel> on WidgetModel<W, M> {
  static const Duration _hideOnUserInactivityGap = Duration(seconds: 3);

  final ValueNotifier<bool> visible = ValueNotifier(false);

  final ValueNotifier<MouseCursor> cursor = ValueNotifier(
    SystemMouseCursors.none,
  );

  bool _hidden = true;

  Timer? _hideOnUserInactivityTimer;

  @override
  void dispose() {
    super.dispose();
    visible.dispose();
    cursor.dispose();
    _cancelHideOnUserInactivityTimer();
  }

  void show({
    bool hideOnUserInactivity = true,
  }) {
    _hidden = false;
    visible.value = true;
    cursor.value = SystemMouseCursors.basic;

    hideOnUserInactivity
        ? this.hideOnUserInactivity()
        : _cancelHideOnUserInactivityTimer();
  }

  void hide() {
    _hidden = true;
    visible.value = false;
    cursor.value = SystemMouseCursors.none;

    _cancelHideOnUserInactivityTimer();
  }

  void hideOnUserInactivity({
    bool restartUserInactivityTimer = true,
  }) {
    if (_hidden) {
      return;
    }
    if (_hideOnUserInactivityTimer != null && !restartUserInactivityTimer) {
      return;
    }

    _cancelHideOnUserInactivityTimer();
    _hideOnUserInactivityTimer = Timer(_hideOnUserInactivityGap, hide);
  }

  void onTapUp(TapUpDetails details) {
    if (details.kind != PointerDeviceKind.touch) {
      return;
    }

    _hidden ? show() : hide();
  }

  void onPointerHover(PointerHoverEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      return;
    }
    if (!_hidden && _hideOnUserInactivityTimer == null) {
      return;
    }

    show();
  }

  void onPointerExit(PointerExitEvent event) {
    hide();
  }

  void _cancelHideOnUserInactivityTimer() {
    _hideOnUserInactivityTimer?.cancel();
    _hideOnUserInactivityTimer = null;
  }
}
