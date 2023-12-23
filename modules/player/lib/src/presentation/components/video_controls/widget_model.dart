import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/domain/models/seek_gesture_detector_side.dart';
import 'package:player/src/presentation/components/video_controls/model.dart';
import 'package:player/src/presentation/components/video_controls/widget.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

VideoControlsWidgetModel videoControlsWidgetModelFactory(
  BuildContext context,
) =>
    VideoControlsWidgetModel(
      VideoControlsModel(
        context.read<ErrorHandler>(),
      ),
    );

extension _DurationFormat on Duration {
  String format() {
    final int hours = inHours;
    final int minutes = inMinutes % 60;
    final int seconds = inSeconds % 60;

    final StringBuffer buffer = StringBuffer();
    if (hours > 0) {
      buffer
        ..write(hours)
        ..write(':');
    }
    buffer
      ..write(minutes.toString().padLeft(hours > 0 ? 2 : 1, '0'))
      ..write(':')
      ..write(seconds.toString().padLeft(2, '0'));

    return buffer.toString();
  }
}

abstract interface class IVideoControlsWidgetModel implements IWidgetModel {
  ValueListenable<MouseCursor> get cursor;

  ValueListenable<bool> get controlsIgnorePointer;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get position;

  ValueListenable<String> get duration;

  VideoPlayerController get controller;

  Animation<double> get fadeAnimation;

  Animation<double> get playPauseAnimation;

  void onPlayPausePressed();

  void onPreferencesPressed();

  void onTapUp(TapUpDetails details);

  void onPointerHover(PointerHoverEvent event);

  void onPointerExit(PointerExitEvent event);

  void onSeekGesture(SeekGestureDetectorSide side);
}

class VideoControlsWidgetModel
    extends WidgetModel<VideoControlsWidget, IVideoControlsModel>
    with TickerProviderWidgetModelMixin, _HideOnUserInactivityWidgetModelMixin
    implements IVideoControlsWidgetModel {
  VideoControlsWidgetModel(super._model);

  static const Duration _rewindFastForwardValue = Duration(seconds: 10);

  @override
  ValueNotifier<double> maxScale = ValueNotifier(1);

  @override
  ValueNotifier<List<double>> scaleAnchors = ValueNotifier(const [1]);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> position = ValueNotifier('');

  @override
  final ValueNotifier<String> duration = ValueNotifier('');

  @override
  late final CurvedAnimation playPauseAnimation = CurvedAnimation(
    parent: _playPauseAnimationController,
    curve: Easing.standard,
  );

  @override
  late VideoController controller;

  late final AnimationController _playPauseAnimationController =
      AnimationController(
    vsync: this,
    duration: Durations.short4,
    value: controller.value.isPlaying ? 1 : 0,
  );

  double _screenAspectRatio = 1;

  @override
  ValueListenable<bool> get controlsIgnorePointer => ignorePointer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    controller = widget.controller..addListener(_onControllerValueChanged);
    title.value = widget.title;
    _onControllerValueChanged();

    show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenAspectRatio = MediaQuery.of(context).size.aspectRatio;
  }

  @override
  void didUpdateWidget(VideoControlsWidget oldWidget) {
    title.value = widget.title;

    if (widget.controller != oldWidget.controller) {
      controller.removeListener(_onControllerValueChanged);
      controller = widget.controller..addListener(_onControllerValueChanged);
    }
  }

  @override
  Future<void> onPlayPausePressed() async {
    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  @override
  Future<void> onPreferencesPressed() async {
    await showModalMenuBottomSheet(
      context: context,
      items: widget.preferences,
    );
  }

  @override
  Future<void> onTapUp(TapUpDetails details) async {
    super.onTapUp(details);

    if (details.kind == PointerDeviceKind.touch) {
      return;
    }

    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
  }

  @override
  Future<void> onSeekGesture(SeekGestureDetectorSide side) async {
    await controller.seekTo(
      controller.value.position +
          switch (side) {
            SeekGestureDetectorSide.left => -_rewindFastForwardValue,
            SeekGestureDetectorSide.right => _rewindFastForwardValue,
          },
    );
  }

  @override
  void dispose() {
    super.dispose();
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    position.dispose();
    duration.dispose();
    playPauseAnimation.dispose();
    controller.removeListener(_onControllerValueChanged);
  }

  void _onControllerValueChanged() {
    final VideoPlayerValue value = controller.value;

    maxScale.value = _screenAspectRatio / value.aspectRatio;
    scaleAnchors.value = [1, maxScale.value];

    position.value = value.position.format();
    duration.value = value.duration.format();

    value.isPlaying
        ? _playPauseAnimationController.forward()
        : _playPauseAnimationController.reverse();

    value.isPlaying
        ? hideOnUserInactivity(restartUserInactivityTimer: false)
        : show(hideOnUserInactivity: false);
  }
}

mixin _HideOnUserInactivityWidgetModelMixin<W extends ElementaryWidget,
        M extends ElementaryModel>
    on WidgetModel<W, M>, TickerProviderWidgetModelMixin<W, M> {
  static const Duration _hideOnUserInactivityGap = Duration(seconds: 3);

  final ValueNotifier<MouseCursor> cursor = ValueNotifier(
    SystemMouseCursors.none,
  );

  late final ValueNotifier<bool> ignorePointer = ValueNotifier(_hidden);

  late final CurvedAnimation fadeAnimation = CurvedAnimation(
    parent: _fadeAnimationController,
    curve: Easing.emphasizedDecelerate,
    // TODO(ERGataullin): replace with Easing.emphasized
    reverseCurve: Curves.easeInOutCubicEmphasized,
  );

  late final AnimationController _fadeAnimationController = AnimationController(
    vsync: this,
    value: _hidden ? 0 : 1,
    duration: Durations.long2,
    reverseDuration: Durations.short4,
  );

  bool _hidden = true;

  Timer? _hideOnUserInactivityTimer;

  @override
  void dispose() {
    super.dispose();
    cursor.dispose();
    ignorePointer.dispose();
    fadeAnimation.dispose();
    _fadeAnimationController.dispose();
    _cancelHideOnUserInactivityTimer();
  }

  void show({
    bool hideOnUserInactivity = true,
  }) {
    _hidden = false;
    ignorePointer.value = false;
    cursor.value = SystemMouseCursors.basic;
    _fadeAnimationController.forward();

    hideOnUserInactivity
        ? this.hideOnUserInactivity()
        : _cancelHideOnUserInactivityTimer();
  }

  void hide() {
    _hidden = true;
    ignorePointer.value = true;
    cursor.value = SystemMouseCursors.none;
    _fadeAnimationController.reverse();

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
