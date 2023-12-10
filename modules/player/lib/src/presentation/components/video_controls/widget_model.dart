import 'dart:async';

import 'package:core/core.dart';
import 'package:elementary/elementary.dart' hide ErrorHandler;
import 'package:flutter/foundation.dart';
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
  ValueListenable<String> get title;

  ValueListenable<String> get position;

  ValueListenable<String> get duration;

  VideoPlayerController get controller;

  Animation<double> get playPauseAnimation;

  void onPlayPausePressed();

  void onPreferencesPressed();
}

class VideoControlsWidgetModel
    extends WidgetModel<VideoControlsWidget, IVideoControlsModel>
    with SingleTickerProviderWidgetModelMixin
    implements IVideoControlsWidgetModel {
  VideoControlsWidgetModel(super._model);

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
    value: controller.value.isPlaying ? 1 : 0,
  );

  @override
  late VideoController controller;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    controller = widget.controller..addListener(_onControllerValueChanged);
    title.value = widget.title;
    _onControllerValueChanged();
  }

  @override
  Future<void> didUpdateWidget(VideoControlsWidget oldWidget) async {
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
  void dispose() {
    super.dispose();
    title.dispose();
    position.dispose();
    duration.dispose();
    playPauseAnimation.dispose();
    controller.removeListener(_onControllerValueChanged);
  }

  void _onControllerValueChanged() {
    final VideoPlayerValue value = controller.value;

    position.value = value.position.format();
    duration.value = value.duration.format();

    value.isPlaying
        ? playPauseAnimation.forward()
        : playPauseAnimation.reverse();
  }
}
