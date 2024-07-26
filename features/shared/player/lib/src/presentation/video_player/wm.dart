import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l10n/l10n.dart';
import 'package:player/player.dart';
import 'package:player/src/presentation/video_player/components/fullscreen/fullscreen_button.dart';
import 'package:player/src/presentation/video_player/components/show_on_mouse_hover.dart';
import 'package:player/src/presentation/video_player/const.dart';
import 'package:player/src/presentation/video_player/model.dart';
import 'package:player/src/utils/video_controller.dart';

VideoPlayerWM videoPlayerWMFactory(BuildContext context) => VideoPlayerWM(
      VideoPlayerModel(errorHandler: context.read<ErrorHandler>()),
    );

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<VoidCallback?> get menuCallback;

  ValueListenable<VoidCallback?> get previousCallback;

  ValueListenable<VoidCallback?> get nextCallback;

  VideoController get videoController;

  VisibilityController get controlsVisibilityController;

  FullscreenController get fullscreenController;

  Map<ShortcutActivator, VoidCallback> get shortcuts;

  void onAccurateTap();

  void onAccurateDoubleTap();

  void onInaccurateTap();

  void onPositionChangeStart(double position);

  void onPositionChangeEnd(double position);

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
  late final DynamicData<double> maxScale = DynamicData(
    trigger: videoController.aspectRatio,
    () => model.getMaxScale(
      surfaceAspectRatio: MediaQuery.sizeOf(context).aspectRatio,
      videoAspectRatio: videoController.aspectRatio.value,
    ),
  );

  @override
  late final DynamicData<List<double>> scaleAnchors = DynamicData(
    trigger: maxScale,
    () => [1, maxScale.value],
  );

  @override
  late final DynamicData<String> title = DynamicData(() => widget.title);

  @override
  late final DynamicData<String> subtitle = DynamicData(() => widget.subtitle);

  @override
  late final DynamicData<VoidCallback?> menuCallback = DynamicData(
    () => widget.translations.isEmpty ? null : _openMenu,
  );

  @override
  late final DynamicData<VoidCallback?> previousCallback = DynamicData(
    () => widget.onPreviousPressed == null
        ? null
        : () {
            controlsVisibilityController.show();
            widget.onPreviousPressed?.call();
          },
  );

  @override
  late final DynamicData<VoidCallback?> nextCallback = DynamicData(
    () => widget.onNextPressed == null
        ? null
        : () {
            controlsVisibilityController.show();
            widget.onNextPressed?.call();
          },
  );

  @override
  late final Map<ShortcutActivator, VoidCallback> shortcuts = {
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () => videoController
        .seekTo(videoController.position.value - shortcutSeekDuration),
    const SingleActivator(LogicalKeyboardKey.arrowRight): () => videoController
        .seekTo(videoController.position.value + shortcutSeekDuration),
    const SingleActivator(LogicalKeyboardKey.space): videoController.playPause,
  };

  bool _watched = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..videoResolver = widget.videoResolver
      ..setTranslations(widget.translations)
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
    model.locale = Localizations.localeOf(context);
    maxScale.update();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    model
      ..videoResolver = widget.videoResolver
      ..setTranslations(widget.translations);
    title.update();
    subtitle.update();
    menuCallback.update();
    previousCallback.update();
    nextCallback.update();
  }

  @override
  Future<void> onAccurateTap() async {
    await videoController.playPause();
  }

  @override
  Future<void> onAccurateDoubleTap() async {
    await fullscreenController.toggle();
  }

  @override
  void onInaccurateTap() {
    controlsVisibilityController.toggle(immediately: true);
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
  void onPopInvoked(bool didPop) {
    if (didPop) fullscreenController.exit();
  }

  @override
  void dispose() {
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    subtitle.dispose();
    menuCallback.dispose();
    previousCallback.dispose();
    nextCallback.dispose();
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

  void _openMenu() {
    controlsVisibilityController.show();
    showModalMenuBottomSheet(
      context: context,
      items: [
        MenuItemData.group(
          icon: Icons.language,
          label: l10n.value.languageLabel,
          children: model.translations.value.keys
              .map(
                (locale) => MenuItemData.group(
                  selected: locale == model.translation.value?.locale,
                  label: l10n.value.languageTitle(locale.toString()),
                  children: _getTranslationMenuItems(locale: locale),
                ),
              )
              .toList(growable: false),
        ),
        if (model.translation.value case final VideoTranslationData translation)
          MenuItemData.group(
            icon: Icons.person,
            label: l10n.value.authorLabel,
            children: _getTranslationMenuItems(locale: translation.locale),
          ),
      ],
    );
  }

  List<MenuItemData> _getTranslationMenuItems({
    required Locale locale,
  }) {
    return model.translations.value[locale]
            ?.map(
              (translation) => MenuItemData.single(
                selected: translation == model.translation.value,
                label: translation.title,
                onSelected: () => model.switchTranslation(translation),
              ),
            )
            .toList(growable: false) ??
        const [];
  }
}
