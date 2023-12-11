import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:player/src/utils/video_controller.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

VideoPlayerWidgetModel videoPlayerWidgetModelFactory(BuildContext context) =>
    VideoPlayerWidgetModel(
      VideoPlayerModel(
        context.read<ErrorHandler>(),
      ),
    );

abstract interface class IVideoPlayerWidgetModel implements IWidgetModel {
  ValueListenable<MouseCursor> get cursor;

  ValueListenable<bool> get showPlayer;

  ValueListenable<double> get playerAspectRatio;

  ValueListenable<bool> get showControls;

  VideoController get controller;

  void onTapUp(TapUpDetails details);

  void onPointerHover(PointerHoverEvent event);

  void onPointerExit(PointerExitEvent event);
}

class VideoPlayerWidgetModel
    extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    implements IVideoPlayerWidgetModel {
  VideoPlayerWidgetModel(super._model);

  static const Duration _hideOnUserInactivityGap = Duration(seconds: 3);

  @override
  final ValueNotifier<MouseCursor> cursor =
      ValueNotifier(SystemMouseCursors.none);

  @override
  final ValueNotifier<bool> showPlayer = ValueNotifier(false);

  @override
  final ValueNotifier<double> playerAspectRatio = ValueNotifier(1);

  @override
  final ValueNotifier<bool> showControls = ValueNotifier(false);

  @override
  late VideoController controller;

  Timer? _hideOnUserInactivityTimer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    controller = widget.controller..addListener(_onControllerValueChanged);
    _showControls();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    if (widget.controller != oldWidget.controller) {
      controller.removeListener(_onControllerValueChanged);
      controller = widget.controller..addListener(_onControllerValueChanged);
    }
  }

  @override
  void onTapUp(TapUpDetails details) {
    if (details.kind != PointerDeviceKind.touch) {
      return;
    }

    showControls.value ? _hideControls() : _showControls();
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      return;
    }

    _showControls();
  }

  @override
  void onPointerExit(PointerExitEvent event) {
    _hideControls();
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_onControllerValueChanged);
  }

  void _showControls({
    bool hideOnUserInactivity = true,
  }) {
    cursor.value = SystemMouseCursors.basic;
    showControls.value = true;

    hideOnUserInactivity
        ? _startHideOnUserInactivityTimer()
        : _cancelHideOnUserInactivityTimer();
  }

  void _startHideOnUserInactivityTimer() {
    _cancelHideOnUserInactivityTimer();
    _hideOnUserInactivityTimer = Timer(_hideOnUserInactivityGap, _hideControls);
  }

  void _cancelHideOnUserInactivityTimer() {
    _hideOnUserInactivityTimer?.cancel();
    _hideOnUserInactivityTimer = null;
  }

  void _hideControls() {
    cursor.value = SystemMouseCursors.none;
    showControls.value = false;

    _cancelHideOnUserInactivityTimer();
  }

  void _onControllerValueChanged() {
    final VideoPlayerValue value = controller.value;
    showPlayer.value = value.isInitialized;
    playerAspectRatio.value = value.aspectRatio;

    if (!value.isPlaying) {
      _showControls(hideOnUserInactivity: false);
    } else if (showControls.value && _hideOnUserInactivityTimer == null) {
      _startHideOnUserInactivityTimer();
    }
  }
}
