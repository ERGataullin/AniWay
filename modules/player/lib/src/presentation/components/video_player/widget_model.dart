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

abstract interface class IVideoPlayerWidgetModel implements IWidgetModel {
  ValueListenable<bool> get visible;

  ValueListenable<MouseCursor> get cursor;

  ValueListenable<double> get aspectRatio;

  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<CrossFadeState> get playPauseLoaderState;

  ValueListenable<VoidCallback?> get playPauseLoaderCallback;

  ValueListenable<bool> get rewindEnabled;

  ValueListenable<bool> get fastForwardEnabled;

  ValueListenable<TextSpan> get timer;

  ValueListenable<double> get positionValue;

  VideoController get controller;

  FullscreenController get fullscreenController;

  Animation<double> get playPauseAnimation;

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
    with TickerProviderWidgetModelMixin, _HideOnUserInactivityWidgetModelMixin
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
  final ValueNotifier<CrossFadeState> playPauseLoaderState = ValueNotifier(
    CrossFadeState.showFirst,
  );

  @override
  final ValueNotifier<VoidCallback?> playPauseLoaderCallback = ValueNotifier(
    null,
  );

  @override
  final ValueNotifier<bool> rewindEnabled = ValueNotifier(false);

  @override
  final ValueNotifier<bool> fastForwardEnabled = ValueNotifier(false);

  @override
  final ValueNotifier<TextSpan> timer = ValueNotifier(const TextSpan());

  @override
  final ValueNotifier<double> positionValue = ValueNotifier(0);

  @override
  final FullscreenController fullscreenController = FullscreenController();

  @override
  late final CurvedAnimation playPauseAnimation = CurvedAnimation(
    parent: _playPauseAnimationController,
    curve: Easing.standard,
    reverseCurve: Easing.standard.flipped,
  );

  @override
  VideoController get controller => model.videoController;

  late final AnimationController _playPauseAnimationController =
      AnimationController(
    vsync: this,
    duration: Durations.medium2,
    value: controller.value.isPlaying ? 1 : 0,
  );

  Color? _onSurfaceColor;

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
    _onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    _updateTimer();
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
    _playPauseAnimationController.dispose();
    aspectRatio.dispose();
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    subtitle.dispose();
    playPauseLoaderState.dispose();
    playPauseLoaderCallback.dispose();
    rewindEnabled.dispose();
    fastForwardEnabled.dispose();
    timer.dispose();
    positionValue.dispose();
    fullscreenController
      ..exit()
      ..dispose();
    playPauseAnimation.dispose();
  }

  void _onModelChanged() {
    aspectRatio.value = model.aspectRatio;
    maxScale.value = model.maxScale;
    scaleAnchors.value = model.scaleAnchors;

    if (model.playing) {
      _playPauseAnimationController.forward();
      hideOnUserInactivity(restartUserInactivityTimer: false);
    } else {
      _playPauseAnimationController.reverse();
      show(hideOnUserInactivity: false);
    }

    playPauseLoaderState.value =
        model.loading ? CrossFadeState.showSecond : CrossFadeState.showFirst;
    playPauseLoaderCallback.value =
        model.loading ? null : model.togglePlayPause;
    if (model.loading) {
      show(hideOnUserInactivity: false);
    }

    fullscreenController.webElementQuery =
        defaultTargetPlatform == TargetPlatform.iOS
            ? 'video#videoElement-${model.textureId}'
            : null;

    rewindEnabled.value = model.position > Duration.zero;
    fastForwardEnabled.value = model.position < model.duration;

    _updateTimer();

    positionValue.value = model.duration == Duration.zero
        ? 0
        : model.position.inSeconds / model.duration.inSeconds;
  }

  void _updateTimer() {
    timer.value = TextSpan(
      children: [
        TextSpan(
          text: model.position.format(),
          style: TextStyle(color: _onSurfaceColor),
        ),
        const TextSpan(text: ' / '),
        TextSpan(text: model.duration.format()),
      ],
    );
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
