import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/presentation/components/video_player/widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

VideoPlayerWidgetModel videoPlayerWidgetModelFactory(BuildContext context) =>
    VideoPlayerWidgetModel(
      VideoPlayerModel(
        context.read<ErrorHandler>(),
        service: context.read<PlayerService>(),
      ),
      fullscreen: context.read<Fullscreen>(),
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
  ValueListenable<VideoPlayerController> get controller;

  ValueListenable<bool> get showPlayer;

  ValueListenable<double> get aspectRatio;

  ValueListenable<bool> get showControls;

  ValueListenable<Duration> get controlsAnimationDuration;

  ValueListenable<MouseCursor> get mouseCursor;

  ValueListenable<String> get title;

  ValueListenable<String> get position;

  ValueListenable<String> get duration;

  Animation<double> get playPauseAnimation;

  void onPlayPausePressed();

  void onPointerHover(PointerHoverEvent event);

  void onPreferencesPressed();
}

class VideoPlayerWidgetModel
    extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    with SingleTickerProviderWidgetModelMixin
    implements IVideoPlayerWidgetModel {
  VideoPlayerWidgetModel(
    super._model, {
    required Fullscreen fullscreen,
  }) : _fullscreen = fullscreen;

  static const Duration _controlsVisibilityDuration = Duration(seconds: 3);

  @override
  final ValueNotifier<VideoPlayerController> controller = ValueNotifier(
    VideoPlayerController.networkUrl(Uri()),
  );

  @override
  final ValueNotifier<bool> showPlayer = ValueNotifier(false);

  @override
  final ValueNotifier<double> aspectRatio = ValueNotifier(1);

  @override
  final ValueNotifier<bool> showControls = ValueNotifier(false);

  @override
  final ValueNotifier<Duration> controlsAnimationDuration =
      ValueNotifier(Duration.zero);

  @override
  final ValueNotifier<MouseCursor> mouseCursor =
      ValueNotifier(SystemMouseCursors.basic);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<String> position = ValueNotifier('');

  @override
  final ValueNotifier<String> duration = ValueNotifier('');

  @override
  late final AnimationController playPauseAnimation = AnimationController(
    vsync: this,
    duration: Durations.short4,
  );

  final Fullscreen _fullscreen;

  Timer? _controlsHidingTimer;

  VideoTranslationTypeData? _translationType;

  VideoTranslationData? _translation;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    title.value = widget.title;
    _translationType = widget.translations.isEmpty
        ? null
        : widget.translations.entries.first.key;
    _translation = _translationType == null
        ? null
        : widget.translations[_translationType]?.first;
    _showControls();
    if (!_fullscreen.isDynamicFullscreenSupported) {
      unawaited(_fullscreen.request());
    }
    unawaited(_lockOrientation());
    unawaited(_initializeController());
  }

  @override
  Future<void> didUpdateWidget(VideoPlayerWidget oldWidget) async {
    title.value = widget.title;

    if (widget.translations != oldWidget.translations) {
      _translationType = widget.translations.isEmpty
          ? null
          : widget.translations.entries.first.key;
      _translation = _translationType == null
          ? null
          : widget.translations[_translationType]?.first;
      controller.value.removeListener(_onControllerValueChanged);
      await controller.value.dispose();
      await _initializeController();
    }
  }

  @override
  void onPlayPausePressed() {
    unawaited(
      controller.value.value.isPlaying
          ? controller.value.pause()
          : controller.value.play(),
    );
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    _showControls();
  }

  @override
  void onPreferencesPressed() {
    unawaited(
      showSelectionBottomSheet<void>(
        context: context,
        items: [
          SelectionGroupItemData(
            label: 'Тип перевода',
            items: VideoTranslationTypeData.values
                .map(
                  (type) => SelectionSingleItemData(
                    enabled: widget.translations[type]?.isNotEmpty ?? false,
                    label: type.toString(),
                    onSelected: () {
                      _translationType = type;
                      onPreferencesPressed();
                    },
                  ),
                )
                .toList(growable: false),
          ),
          SelectionGroupItemData(
            label: 'Перевод',
            items: widget.translations[_translationType]!
                .map(
                  (translation) => SelectionSingleItemData(
                    label: translation.title,
                    onSelected: () => _onTranslationSelected(translation),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    unawaited(_unlockOrientation());
    unawaited(_fullscreen.exit());
    showControls.dispose();
    controlsAnimationDuration.dispose();
    mouseCursor.dispose();
    title.dispose();
    position.dispose();
    duration.dispose();
    controller.value.removeListener(_onControllerValueChanged);
    unawaited(controller.value.dispose());
    controller.dispose();
    playPauseAnimation.dispose();
    _controlsHidingTimer?.cancel();
  }

  Future<void> _lockOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeController() async {
    if (_translation == null) {
      return;
    }

    final VideoData video =
        await model.getTranslationVideo(_translation!.embedUri);
    final Uri uri = video.sources.entries.first.value.uri;

    controller.value = VideoPlayerController.networkUrl(uri)
      ..addListener(_onControllerValueChanged);
    await controller.value.initialize();
    await controller.value.play();
  }

  void _showControls() {
    mouseCursor.value = SystemMouseCursors.basic;
    showControls.value = true;
    controlsAnimationDuration.value = Durations.long2;

    if (_fullscreen.isDynamicFullscreenSupported) {
      unawaited(_fullscreen.exit());
    }

    _controlsHidingTimer?.cancel();
    _controlsHidingTimer = Timer(
      _controlsVisibilityDuration,
      _maybeHideControls,
    );
  }

  void _maybeHideControls() {
    if (!controller.value.value.isPlaying) {
      return;
    }

    _hideControls();
  }

  void _hideControls() {
    mouseCursor.value = SystemMouseCursors.none;
    showControls.value = false;
    controlsAnimationDuration.value = Durations.short4;

    if (_fullscreen.isDynamicFullscreenSupported) {
      unawaited(_fullscreen.request());
    }

    _controlsHidingTimer?.cancel();
  }

  void _onTranslationSelected(VideoTranslationData translation) {
    _translation = translation;
    unawaited(controller.value.dispose());
    unawaited(_initializeController());
  }

  void _onControllerValueChanged() {
    final VideoPlayerController controller = this.controller.value;

    showPlayer.value = controller.value.isInitialized;
    aspectRatio.value = controller.value.aspectRatio;
    position.value = controller.value.position.format();
    duration.value = controller.value.duration.format();

    if (controller.value.isPlaying) {
      playPauseAnimation.forward();
    } else {
      playPauseAnimation.reverse();
      _controlsHidingTimer?.cancel();
      _controlsHidingTimer = null;
      _showControls();
    }

    if (controller.value.position == controller.value.duration) {
      widget.onFinished?.call(_translation!.id);
    }
  }

  Future<void> _unlockOrientation() {
    return SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
