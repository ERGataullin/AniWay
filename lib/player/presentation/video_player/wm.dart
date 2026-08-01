import 'dart:async';

import 'package:app/core/core.dart';
import 'package:app/l10n/l10n.dart';
import 'package:app/player/player.dart';
import 'package:app/player/presentation/video_player/components/fullscreen/controller/controller.dart';
import 'package:app/player/presentation/video_player/const.dart';
import 'package:app/player/presentation/video_player/model.dart';
import 'package:app/player/utils/video_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

VideoPlayerWM videoPlayerWMFactory(BuildContext context) => VideoPlayerWM(
  VideoPlayerModel(
    errorHandler: context.read<ErrorHandler>(),
    repository: context.read<PlayerRepository>(),
  ),
  networkService: context.read<NetworkService>(),
);

abstract interface class IVideoPlayerWM implements IWidgetModel {
  ValueListenable<double> get maxZoom;

  ValueListenable<String> get title;

  ValueListenable<String> get subtitle;

  ValueListenable<String?> get translationTitle;

  ValueListenable<VoidCallback?> get onSharePressed;

  ValueListenable<VoidCallback?> get onMenuPressed;

  ValueListenable<VoidCallback?> get onPreviousPressed;

  ValueListenable<VoidCallback?> get onNextPressed;

  VideoController get videoController;

  FullscreenController get fullscreenController;

  Map<ShortcutActivator, VoidCallback> get shortcuts;

  void handleAccurateTap();

  void handleAccurateDoubleTap();

  void handlePopInvoked(bool didPop, [Object? result]);
}

class VideoPlayerWM extends WidgetModel<VideoPlayerWidget, IVideoPlayerModel>
    with L10nWMMixin
    implements IVideoPlayerWM {
  VideoPlayerWM(super._model, {required this._networkService});

  @override
  late final videoController = VideoController(networkService: _networkService);

  @override
  final fullscreenController = FullscreenController();

  @override
  late final Computed<double> maxZoom = .new(
    trigger: videoController.aspectRatio,
    () => model.getMaxScale(
      surfaceAspectRatio: MediaQuery.sizeOf(context).aspectRatio,
      videoAspectRatio: videoController.aspectRatio.value,
    ),
  );

  @override
  late final Computed<String> title = .new(() => widget.title);

  @override
  late final Computed<String> subtitle = .new(() => widget.subtitle);

  @override
  late final Computed<String?> translationTitle = .new(
    trigger: model.translation,
    () => model.translation.value?.title,
  );

  @override
  late final Computed<VoidCallback?> onSharePressed = .new(
    trigger: model.translation,
    () => model.translation.value == null ? null : _handleSharePressed,
  );

  @override
  late final Computed<VoidCallback?> onMenuPressed = .new(
    () => widget.translations.isEmpty ? null : _handleMenuPressed,
  );

  @override
  late final Computed<VoidCallback?> onPreviousPressed = .new(
    () => widget.onPreviousPressed,
  );

  @override
  late final Computed<VoidCallback?> onNextPressed = .new(
    () => widget.onNextPressed,
  );

  @override
  late final Map<ShortcutActivator, VoidCallback> shortcuts = {
    const SingleActivator(.arrowLeft): () => videoController.seekTo(
      videoController.position.value - seekGestureRewindStep,
    ),
    const SingleActivator(.arrowRight): () => videoController.seekTo(
      videoController.position.value + seekGestureFastForwardStep,
    ),
    const SingleActivator(.space): videoController.playPause,
  };

  var _watched = false;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    model
      ..videoResolver = widget.videoResolver
      ..setTranslations(widget.translations)
      ..video.addListener(_handleVideoChanged)
      ..videoDataSource.addListener(_handleVideoDataSourceChanged);
    if (kIsWeb && defaultTargetPlatform == .iOS) {
      videoController.webElementQuery.addListener(
        _updateFullscreenWebElementQuery,
      );
    }
    videoController
      ..playing.addListener(
        () => WakelockPlus.toggle(enable: videoController.playing.value),
      )
      ..position.addListener(_handlePositionDurationChanged)
      ..duration.addListener(_handlePositionDurationChanged);
  }

  @override
  void didChangeDependencies() {
    model.currentLocale = Localizations.localeOf(context);
    maxZoom.update();
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
    onPreviousPressed.update();
    onNextPressed.update();
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
  void handlePopInvoked(bool didPop, [Object? result]) {
    if (!didPop) return;
    fullscreenController.exit();
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    maxZoom.dispose();
    title.dispose();
    subtitle.dispose();
    translationTitle.dispose();
    onSharePressed.dispose();
    onMenuPressed.dispose();
    onPreviousPressed.dispose();
    onNextPressed.dispose();
    videoController.dispose();
    fullscreenController.dispose();
    super.dispose();
  }

  void _handleVideoChanged() {
    videoController.setDataSource(model.videoDataSource.value);
    _watched = false;
  }

  final NetworkService _networkService;

  Future<void> _handleVideoDataSourceChanged() async {
    await videoController.setDataSource(
      model.videoDataSource.value,
      captionsUri: model.video.value?.captionsUri,
      saveState: true,
    );
    if (model.videoDataSource.value != null) await videoController.play();
  }

  void _handlePositionDurationChanged() {
    if (videoController.loading.value) return;

    final Duration position = videoController.position.value;
    final Duration duration = videoController.duration.value;

    if (duration == .zero) return;

    final bool finished = position >= duration;
    if (finished) widget.onFinished();

    if (_watched) return;
    _watched = position >= duration - const .new(minutes: 4);
    if (_watched) {
      widget.onWatched(model.translation.value!.id);
      model.handleVideoWatched();
    }
  }

  Future<void> _handleSharePressed() async {
    final Uri translationUri = model.translation.value!.uri;
    switch (defaultTargetPlatform) {
      case .android || .fuchsia || .iOS || .linux || .macOS:
        SharePlus.instance.share(.new(uri: translationUri));
      case .windows:
        await Clipboard.setData(.new(text: '$translationUri'));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            .new(
              behavior: .floating,
              duration: Durations.extralong4,
              content: Text(context.l10n.linkCopied),
            ),
          );
    }
  }

  void _handleMenuPressed() {
    showModalMenuBottomSheet(
      context: context,
      items: [
        .group(
          icon: Icons.language_outlined,
          label: l10n.value.languageLabel,
          children: model.translations.value.keys
              .map(
                (locale) => MenuItemData.group(
                  selected: locale == model.translation.value?.locale,
                  label: l10n.value.languageTitle(locale.toString()),
                  children: _getTranslationTypeMenuItems(locale),
                ),
              )
              .toList(growable: false),
        ),
        .group(
          icon: Icons.subtitles_outlined,
          label: l10n.value.translationTypeLabel,
          children: switch (model.translation.value) {
            final TranslationData translation => _getTranslationTypeMenuItems(
              translation.locale,
            ),
            _ => const [],
          },
        ),
        .group(
          icon: Icons.person_outlined,
          label: l10n.value.authorLabel,
          children: switch (model.translation.value) {
            final TranslationData translation => _getTranslationMenuItems(
              locale: translation.locale,
              type: translation.type,
            ),
            _ => const [],
          },
        ),
        .group(
          icon: Icons.high_quality_outlined,
          label: l10n.value.qualityLabel,
          children: model.video.value == null
              ? const []
              : model.video.value!.stream.keys
                    .map(
                      (quality) => MenuItemData.single(
                        selected: quality == model.quality.value,
                        label: l10n.value.quality(quality),
                        onSelected: () => model.setQuality(quality),
                      ),
                    )
                    .toList(growable: false),
        ),
        .group(
          icon: Icons.speed_outlined,
          label: l10n.value.playbackSpeedLabel,
          children: model.video.value == null
              ? const []
              : const <double>[.25, .5, .75, 1, 1.25, 1.5, 1.75, 2]
                    .map(
                      (speed) => MenuItemData.single(
                        selected: speed == videoController.playbackSpeed.value,
                        label: l10n.value.playbackSpeed(speed),
                        onSelected: () =>
                            videoController.setPlaybackSpeed(speed),
                      ),
                    )
                    .toList(growable: false),
        ),
      ],
    );
  }

  void _updateFullscreenWebElementQuery() {
    fullscreenController.webElementQuery =
        videoController.webElementQuery.value;
  }

  List<MenuItemData> _getTranslationTypeMenuItems(Locale locale) {
    return model.translations.value[locale]!.keys
        .map(
          (type) => MenuItemData.group(
            selected: type == model.translation.value?.type,
            label: l10n.value.translationType(type.name),
            children: _getTranslationMenuItems(locale: locale, type: type),
          ),
        )
        .toList(growable: false);
  }

  List<MenuItemData> _getTranslationMenuItems({
    required Locale locale,
    required TranslationType type,
  }) {
    return model.translations.value[locale]![type]
            ?.map(
              (translation) => MenuItemData.single(
                selected: translation == model.translation.value,
                label: translation.title,
                trailing: switch (translation.qualityType) {
                  .bd ||
                  .dvd => l10n.value.qualityType(translation.qualityType.name),
                  .tv => null,
                },
                onSelected: () => model.setTranslation(translation),
              ),
            )
            .toList(growable: false) ??
        const [];
  }
}
