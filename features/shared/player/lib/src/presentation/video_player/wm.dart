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
      VideoPlayerModel(
        errorHandler: context.read<ErrorHandler>(),
        repository: context.read<PlayerRepository>(),
      ),
    );

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get maxScale;

  ValueListenable<List<double>> get scaleAnchors;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<VoidCallback?> get onMenuPressed;

  ValueListenable<VoidCallback?> get previousCallback;

  ValueListenable<VoidCallback?> get nextCallback;

  VideoController get videoController;

  VisibilityController get controlsVisibilityController;

  FullscreenController get fullscreenController;

  Map<ShortcutActivator, VoidCallback> get shortcuts;

  void handleAccurateTap();

  void handleAccurateDoubleTap();

  void handleInaccurateTap();

  void handlePositionChangeStart(double position);

  void handlePositionChangeEnd(double position);

  void handlePopInvoked(bool didPop, [Object? result]);
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
  late final Computed<double> maxScale = Computed(
    trigger: videoController.aspectRatio,
    () => model.getMaxScale(
      surfaceAspectRatio: MediaQuery.sizeOf(context).aspectRatio,
      videoAspectRatio: videoController.aspectRatio.value,
    ),
  );

  @override
  late final Computed<List<double>> scaleAnchors = Computed(
    trigger: maxScale,
    () => [1, maxScale.value],
  );

  @override
  late final Computed<String> title = Computed(() => widget.title);

  @override
  late final Computed<String> subtitle = Computed(() => widget.subtitle);

  @override
  late final Computed<VoidCallback?> onMenuPressed = Computed(
    () => widget.translations.isEmpty ? null : _handleMenuPressed,
  );

  @override
  late final Computed<VoidCallback?> previousCallback = Computed(
    () => widget.onPreviousPressed == null
        ? null
        : () {
            controlsVisibilityController.show();
            widget.onPreviousPressed?.call();
          },
  );

  @override
  late final Computed<VoidCallback?> nextCallback = Computed(
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
      ..video.addListener(_handleVideoChanged)
      ..videoDataSource.addListener(_handleVideoDataSourceChanged);
    if (kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      videoController.webElementQuery
          .addListener(_updateFullscreenWebElementQuery);
    }
    videoController
      ..loading.addListener(_updateControlsVisibility)
      ..playing.addListener(_updateControlsVisibility)
      ..position.addListener(_handlePositionDurationChanged)
      ..duration.addListener(_handlePositionDurationChanged);
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
    onMenuPressed.update();
    previousCallback.update();
    nextCallback.update();
  }

  @override
  Future<void> handleAccurateTap() async {
    await videoController.playPause();
  }

  @override
  Future<void> handleAccurateDoubleTap() async {
    await fullscreenController.toggle();
  }

  @override
  void handleInaccurateTap() {
    controlsVisibilityController.toggle(immediately: true);
  }

  @override
  void handlePositionChangeStart(double position) {
    controlsVisibilityController.show(autohide: false);
  }

  @override
  void handlePositionChangeEnd(double position) {
    controlsVisibilityController.hide();
  }

  @override
  void handlePopInvoked(bool didPop, [Object? result]) {
    if (didPop) fullscreenController.exit();
  }

  @override
  void dispose() {
    maxScale.dispose();
    scaleAnchors.dispose();
    title.dispose();
    subtitle.dispose();
    onMenuPressed.dispose();
    previousCallback.dispose();
    nextCallback.dispose();
    videoController.dispose();
    controlsVisibilityController.dispose();
    fullscreenController.dispose();
    super.dispose();
  }

  void _handleVideoChanged() {
    videoController.setDataSource(model.videoDataSource.value);
    _watched = false;
  }

  Future<void> _handleVideoDataSourceChanged() async {
    await videoController.setDataSource(
      model.videoDataSource.value,
      saveState: true,
    );
    if (model.videoDataSource.value != null) await videoController.play();
  }

  void _handlePositionDurationChanged() {
    if (videoController.loading.value) return;

    if (!_watched) {
      _watched = videoController.position.value >=
          videoController.duration.value - const Duration(minutes: 4);
      if (_watched) {
        widget.onWatched(model.translation.value!.id);
        model.handleVideoWatched();
      }
    }

    final bool finished =
        videoController.position.value >= videoController.duration.value;
    if (finished) widget.onFinished();
  }

  void _handleMenuPressed() {
    controlsVisibilityController.show();
    showModalMenuBottomSheet(
      context: context,
      items: [
        MenuItemData.group(
          icon: Icons.language_outlined,
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
        MenuItemData.group(
          icon: Icons.person_outlined,
          label: l10n.value.authorLabel,
          children: switch (model.translation.value) {
            final VideoTranslationData translation => _getTranslationMenuItems(
                locale: translation.locale,
              ),
            _ => const [],
          },
        ),
        MenuItemData.group(
          icon: Icons.high_quality_outlined,
          label: l10n.value.videoQualityLabel,
          children: model.video.value == null
              ? const []
              : model.video.value!.stream.keys
                  .map(
                    (quality) => MenuItemData.single(
                      selected: quality == model.quality.value,
                      label: l10n.value.videoQuality(quality),
                      onSelected: () => model.setQuality(quality),
                    ),
                  )
                  .toList(growable: false),
        ),
        MenuItemData.group(
          icon: Icons.speed_outlined,
          label: l10n.value.videoPlaybackSpeedLabel,
          children: model.video.value == null
              ? const []
              : const <double>[.25, .5, .75, 1, 1.25, 1.5, 1.75, 2]
                  .map(
                    (speed) => MenuItemData.single(
                      selected: speed == videoController.playbackSpeed.value,
                      label: l10n.value.videoPlaybackSpeed(speed),
                      onSelected: () => videoController.setPlaybackSpeed(speed),
                    ),
                  )
                  .toList(growable: false),
        ),
      ],
    );
  }

  void _updateControlsVisibility() {
    videoController.loading.value &&
                defaultTargetPlatform != TargetPlatform.iOS ||
            !videoController.playing.value
        ? controlsVisibilityController.show(autohide: false)
        : controlsVisibilityController.hide();
  }

  void _updateFullscreenWebElementQuery() {
    fullscreenController.webElementQuery =
        videoController.webElementQuery.value;
  }

  List<MenuItemData> _getTranslationMenuItems({
    required Locale locale,
  }) {
    return model.translations.value[locale]
            ?.map(
              (translation) => MenuItemData.single(
                selected: translation == model.translation.value,
                label: translation.title,
                trailing: switch (translation.qualityType) {
                  VideoQualityType.bd ||
                  VideoQualityType.dvd =>
                    l10n.value.videoQualityType(translation.qualityType.name),
                  VideoQualityType.tv => null,
                },
                onSelected: () => model.setTranslation(translation),
              ),
            )
            .toList(growable: false) ??
        const [];
  }
}
