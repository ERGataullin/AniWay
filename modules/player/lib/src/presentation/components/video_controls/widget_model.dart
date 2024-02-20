import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_controls/model.dart';
import 'package:player/src/presentation/components/video_controls/widget.dart';
import 'package:player/src/utils/video_controller.dart';

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
  ValueListenable<bool> get visible;

  ValueListenable<MouseCursor> get cursor;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<CrossFadeState> get playPauseLoaderState;

  ValueListenable<VoidCallback?> get playPauseLoaderCallback;

  ValueListenable<String> get position;

  ValueListenable<String> get duration;

  ValueListenable<double> get positionValue;

  VideoController get controller;

  Animation<double> get playPauseAnimation;

  void onTapUp(TapUpDetails details);

  void onPointerHover(PointerHoverEvent event);

  void onPointerExit(PointerExitEvent event);

  void onPreferencesPressed();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

  void onPositionChanged(double position);
}

class VideoControlsWidgetModel
    extends WidgetModel<VideoControlsWidget, IVideoControlsModel>
    with TickerProviderWidgetModelMixin, _HideOnUserInactivityWidgetModelMixin
    implements IVideoControlsWidgetModel {
  VideoControlsWidgetModel(super._model);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<CrossFadeState> playPauseLoaderState = ValueNotifier(
    CrossFadeState.showFirst,
  );

  @override
  final ValueNotifier<VoidCallback?> playPauseLoaderCallback =
      ValueNotifier(null);

  @override
  final ValueNotifier<String> position = ValueNotifier('');

  @override
  final ValueNotifier<String> duration = ValueNotifier('');

  @override
  final ValueNotifier<double> positionValue = ValueNotifier(0);

  @override
  late final CurvedAnimation playPauseAnimation = CurvedAnimation(
    parent: _playPauseAnimationController,
    curve: Easing.standard,
    reverseCurve: Easing.standard.flipped,
  );

  @override
  ValueListenable<double> get maxScale => model.maxScale;

  @override
  ValueListenable<List<double>> get scaleAnchors => model.scaleAnchors;

  @override
  VideoController get controller => model.videoController;

  late final AnimationController _playPauseAnimationController =
      AnimationController(
    vsync: this,
    duration: Durations.medium2,
    value: controller.value.isPlaying ? 1 : 0,
  );

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..playing.addListener(_onPlayingChanged)
      ..loading.addListener(_updatePlayPauseLoaderState)
      ..loading.addListener(_updatePlayPauseLoaderCallback)
      ..position.addListener(_updatePosition)
      ..position.addListener(_updatePositionValue)
      ..duration.addListener(_updateDuration)
      ..duration.addListener(_updatePositionValue)
      ..videoController = widget.controller;
    _updateTitle();
    show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model.aspectRatio = MediaQuery.of(context).size.aspectRatio;
  }

  @override
  void didUpdateWidget(VideoControlsWidget oldWidget) {
    _updateTitle();

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
  void dispose() {
    super.dispose();
    model
      ..playing.removeListener(_onPlayingChanged)
      ..loading.removeListener(_updatePlayPauseLoaderState)
      ..loading.removeListener(_updatePlayPauseLoaderCallback)
      ..position.removeListener(_updatePosition)
      ..position.removeListener(_updatePositionValue)
      ..duration.removeListener(_updateDuration)
      ..duration.removeListener(_updatePositionValue);
    _playPauseAnimationController.dispose();
    title.dispose();
    playPauseLoaderState.dispose();
    playPauseLoaderCallback.dispose();
    position.dispose();
    duration.dispose();
    positionValue.dispose();
    playPauseAnimation.dispose();
  }

  void _onPlayingChanged() {
    if (model.playing.value) {
      _playPauseAnimationController.forward();
      hideOnUserInactivity(restartUserInactivityTimer: false);
    } else {
      _playPauseAnimationController.reverse();
      show(hideOnUserInactivity: false);
    }
  }

  void _updateTitle() {
    title.value = widget.title;
  }

  void _updatePlayPauseLoaderState() {
    playPauseLoaderState.value = model.loading.value
        ? CrossFadeState.showSecond
        : CrossFadeState.showFirst;
  }

  void _updatePlayPauseLoaderCallback() {
    playPauseLoaderCallback.value =
        model.loading.value ? null : model.togglePlayPause;
  }

  void _updatePosition() {
    position.value = model.position.value.format();
  }

  void _updateDuration() {
    duration.value = model.duration.value.format();
  }

  void _updatePositionValue() {
    positionValue.value = model.duration.value == Duration.zero
        ? 0
        : model.position.value.inSeconds / model.duration.value.inSeconds;
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
