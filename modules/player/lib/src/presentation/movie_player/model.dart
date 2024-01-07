import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:player/player.dart';
import 'package:player/src/utils/video_controller.dart';

typedef TranslationsData
    = Map<VideoTranslationTypeData, List<VideoTranslationData>>;

abstract interface class IMoviePlayerModel implements ElementaryModel {
  ValueListenable<String> get title;

  ValueListenable<TranslationsData> get translations;

  ValueListenable<VideoTranslationData?> get translation;

  VideoController get videoController;

  set movieId(Object value);

  set episodeId(Object value);

  void changeTranslation(VideoTranslationData value);
}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required PlayerService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<String> title = ValueNotifier('');

  @override
  final ValueNotifier<TranslationsData> translations = ValueNotifier(const {});

  @override
  final ValueNotifier<VideoTranslationData?> translation = ValueNotifier(null);

  @override
  final VideoController videoController = VideoController();

  @override
  set movieId(Object value) {
    _loadMovie(movieId: value);
  }

  @override
  set episodeId(Object value) {
    _loadTranslations(episodeId: value);
  }

  final PlayerService _service;

  late MovieData _movie;

  late VideoData _video;

  @override
  void init() {
    videoController.addListener(_onVideoControllerValueChanged);
  }

  @override
  Future<void> changeTranslation(VideoTranslationData value) async {
    translation.value = value;
    await _loadVideo();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    title.dispose();
    translations.dispose();
    translation.dispose();
    await videoController.dispose();
  }

  Future<void> _loadMovie({
    required Object movieId,
  }) async {
    _movie = await _service.getMovie(movieId);
    title.value = _movie.title;
  }

  Future<void> _loadTranslations({
    required Object episodeId,
  }) async {
    final List<VideoTranslationData> translationsList =
        await _service.getTranslations(episodeId);
    final TranslationsData translations = {
      for (final VideoTranslationTypeData type
          in VideoTranslationTypeData.values)
        type: translationsList
            .where((translation) => translation.type == type)
            .toList(growable: false),
    };
    this.translations.value = translations;
    translation.value = translations[VideoTranslationTypeData.raw]!.first;
  }

  Future<void> _loadVideo() async {
    _video = await _service.getTranslationVideo(translation.value!.embedUri);
    videoController.initialize(_video.sources.values.first.uri);
  }

  Future<void> _onVideoControllerValueChanged() async {
    if (videoController.value.isCompleted) {
      await _service.postTranslationWatched(translation.value!.id);
    }
  }
}
