import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l10n/l10n.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/components/show_on_mouse_hover.dart';
import 'package:player/src/presentation/components/video_player/model.dart';
import 'package:player/src/utils/pointer_device_kind_extension.dart';
import 'package:player/src/utils/video_controller.dart';

VideoPlayerWM videoPlayerWMFactory(BuildContext context) => VideoPlayerWM(
      VideoPlayerModel(context.read<ErrorHandler>()),
    );

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  VideoController get videoController;

  VisibilityController get controlsVisibilityController;

  FullscreenController get fullscreenController;

  void onTapUp(TapUpDetails details);

  void onPreferencesPressed();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

  void onPreviousPressed();

  void onNextPressed();

  void onPopInvoked(bool didPop);
}

class VideoPlayerWM extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    with L10nWMMixin
    implements IVideoPlayerWM {
  VideoPlayerWM(super._model);

  @override
  final VideoController videoController = VideoController.videoPlayer();

  @override
  final VisibilityController controlsVisibilityController =
      VisibilityController();

  @override
  final FullscreenController fullscreenController = FullscreenController();

  @override
  late final ComputationNotifier<double> maxScale = ComputationNotifier(
    trigger: videoController.aspectRatio,
    () => model.getMaxScale(
      surfaceAspectRatio: MediaQuery.sizeOf(context).aspectRatio,
      videoAspectRatio: videoController.aspectRatio.value,
    ),
  );

  @override
  late final ComputationNotifier<List<double>> scaleAnchors =
      ComputationNotifier(
    trigger: maxScale,
    () => [1, maxScale.value],
  );

  @override
  late final ComputationNotifier<String> title = ComputationNotifier(
    () => widget.title,
  );

  @override
  late final ComputationNotifier<String> subtitle = ComputationNotifier(
    () => widget.subtitle,
  );

  bool _watched = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..videoResolver = widget.videoResolver
      ..translations = widget.translations
      ..video.addListener(_onVideoChanged)
      ..videoDataSource.addListener(_onVideoDataSourceChanged);
    if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      videoController.webElementQuery
          .addListener(_updateFullscreenWebElementQuery);
    }
    videoController
      ..loading.addListener(_updateControlsVisibility)
      ..playing.addListener(_updateControlsVisibility)
      ..position.addListener(_onPositionDurationChanged)
      ..duration.addListener(_onPositionDurationChanged);
    title.update();
    subtitle.update();
    _updateControlsVisibility();
  }

  @override
  void didChangeDependencies() {
    maxScale.update();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    model
      ..videoResolver = widget.videoResolver
      ..translations = widget.translations;
    title.update();
    subtitle.update();
  }

  @override
  void onTapUp(TapUpDetails details) {
    details.kind.mobile
        ? controlsVisibilityController.toggle(immediately: true)
        : videoController.playPause();
  }

  @override
  Future<void> onPreferencesPressed() async {
    controlsVisibilityController.show();
    await showModalMenuBottomSheet(
      context: context,
      items: [
        MenuItemData.group(
          icon: Icons.type_specimen,
          label: l10n.value.translationTypeLabel,
          children: VideoTranslationType.values
              .map(
                (type) => MenuItemData.group(
                  selected: type == model.translation.value?.type,
                  label: l10n.value.translationType(type.toString()),
                  children: _getTranslationMenuItems(type: type),
                ),
              )
              .toList(growable: false),
        ),
        if (model.translation.value != null)
          MenuItemData.group(
            icon: Icons.voice_chat,
            label: l10n.value.translationLabel,
            children: _getTranslationMenuItems(
              type: model.translation.value!.type,
            ),
          ),
      ],
    );
  }

  @override
  void onPositionChangeStart(double position) {
    controlsVisibilityController.show(autohide: false);
  }

  @override
  void onPositionChangeEnd(double position) {
    controlsVisibilityController.hide();
  }

  @override
  void onPreviousPressed() {
    controlsVisibilityController.show();
    widget.onPreviousPressed();
  }

  @override
  void onNextPressed() {
    controlsVisibilityController.show();
    widget.onNextPressed();
  }

  @override
  void onPopInvoked(bool didPop) {
    if (didPop) fullscreenController.exit();
  }

  @override
  void dispose() {
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    subtitle.dispose();
    videoController.dispose();
    controlsVisibilityController.dispose();
    fullscreenController.dispose();
    super.dispose();
  }

  void _onVideoChanged() {
    videoController.setDataSource(model.videoDataSource.value);
    _watched = false;
  }

  Future<void> _onVideoDataSourceChanged() async {
    await videoController.setDataSource(
      model.videoDataSource.value,
      saveState: true,
    );
    if (model.videoDataSource.value != null) await videoController.play();
  }

  List<MenuItemData> _getTranslationMenuItems({
    required VideoTranslationType type,
  }) {
    return model
        .getTranslations(type: type)
        .map(
          (translation) => MenuItemData.single(
            selected: translation == model.translation.value,
            label: translation.title,
            onSelected: () => model.switchTranslation(translation),
          ),
        )
        .toList(growable: false);
  }

  void _onPositionDurationChanged() {
    if (videoController.loading.value) return;

    if (!_watched) {
      _watched = videoController.position.value >=
          videoController.duration.value - const Duration(minutes: 4);
      if (_watched) widget.onWatched(model.translation.value!.id);
    }

    final bool finished =
        videoController.position.value >= videoController.duration.value;
    if (finished) widget.onFinished();
  }

  void _updateControlsVisibility() {
    videoController.loading.value || !videoController.playing.value
        ? controlsVisibilityController.show(autohide: false)
        : controlsVisibilityController.hide();
  }

  void _updateFullscreenWebElementQuery() {
    fullscreenController.webElementQuery =
        videoController.webElementQuery.value;
  }
}
