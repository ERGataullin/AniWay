import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  ValueListenable<bool> get visible;

  ValueListenable<MouseCursor> get cursor;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<CrossFadeState> get playPauseLoaderState;

  ValueListenable<String> get position;

  ValueListenable<String> get duration;

  VideoPlayerController get controller;

  Animation<double> get playPauseAnimation;

  void onPlayPausePressed();

  void onPreferencesPressed();

  void onTapUp(TapUpDetails details);

  void onPointerHover(PointerHoverEvent event);

  void onPointerExit(PointerExitEvent event);
}

class VideoControlsWidgetModel
    extends WidgetModel<VideoControlsWidget, IVideoControlsModel>
    with
        SingleTickerProviderWidgetModelMixin,
        _HideOnUserInactivityWidgetModelMixin
    implements IVideoControlsWidgetModel {
  VideoControlsWidgetModel(super._model);

  @override
  ValueNotifier<double> maxScale = ValueNotifier(1);

  @override
  ValueNotifier<List<double>> scaleAnchors = ValueNotifier(const [1]);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<CrossFadeState> playPauseLoaderState = ValueNotifier(
    CrossFadeState.showFirst,
  );

  @override
  final ValueNotifier<String> position = ValueNotifier('');

  @override
  final ValueNotifier<String> duration = ValueNotifier('');

  @override
  late final AnimationController playPauseAnimation = AnimationController(
    vsync: this,
    duration: Durations.short4,
    value: controller.value.isPlaying ? 1 : 0,
  );

  @override
  late VideoController controller;

  double _screenAspectRatio = 1;

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

    playPauseLoaderState.value = !value.isInitialized || value.isBuffering
        ? CrossFadeState.showFirst
        : CrossFadeState.showSecond;
    value.isPlaying
        ? playPauseAnimation.forward()
        : playPauseAnimation.reverse();

    position.value = value.position.format();
    duration.value = value.duration.format();

    value.isPlaying
        ? hideOnUserInactivity(restartUserInactivityTimer: false)
        : show(hideOnUserInactivity: false);
  }
}

mixin _HideOnUserInactivityWidgetModelMixin<W extends ElementaryWidget,
    M extends ElementaryModel> on WidgetModel<W, M> {
  static const Duration _hideOnUserInactivityGap = Duration(seconds: 3);

  final ValueNotifier<bool> visible = ValueNotifier(false);

  final ValueNotifier<MouseCursor> cursor = ValueNotifier(
    SystemMouseCursors.none,
  );

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
    visible.value = true;
    cursor.value = SystemMouseCursors.basic;

    hideOnUserInactivity
        ? this.hideOnUserInactivity()
        : _cancelHideOnUserInactivityTimer();
  }

  void hide() {
    visible.value = false;
    cursor.value = SystemMouseCursors.none;

    _cancelHideOnUserInactivityTimer();
  }

  void hideOnUserInactivity({
    bool restartUserInactivityTimer = true,
  }) {
    if (!visible.value) {
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

    visible.value ? hide() : show();
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
