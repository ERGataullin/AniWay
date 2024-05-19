import 'dart:core';
import 'dart:math';

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

  void loadPreviousEpisode();

  void loadNextEpisode();
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
    _episodeId = value;
    _loadTranslations();
  }

  final PlayerService _service;

  late MovieData _movie;

  late Object _episodeId;

  late VideoData _video;

  @override
  void init() {
    translation.addListener(_loadVideo);
    videoController.addListener(_onVideoControllerValueChanged);
  }

  @override
  void changeTranslation(VideoTranslationData value) {
    translation.value = value;
  }

  @override
  void loadPreviousEpisode() {
    List<EpisodeData> episodes = _movie.episodes;
    int previousIndex =
        episodes.indexWhere((episode) => episode.id == _episodeId) - 1;
    _episodeId = episodes[previousIndex].id;
    _loadTranslations();
  }

  @override
  void loadNextEpisode() {
    List<EpisodeData> episodes = _movie.episodes;
    int nextIndex =
        episodes.indexWhere((episode) => episode.id == _episodeId) + 1;
    _episodeId = episodes[nextIndex].id;
    _loadTranslations();
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

  Future<void> _loadTranslations() async {
    final List<VideoTranslationData> translationsList =
        await _service.getTranslations(_episodeId);
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
      await _service.postTranslationWatched(
        translation.value!.id,
        csrf: _video.csrf,
      );
    }
  }
}
