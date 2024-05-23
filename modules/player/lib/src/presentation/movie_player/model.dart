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

  void setMovieEpisode({
    required Object movieId,
    required Object episodeId,
  });

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

  final PlayerService _service;

  late int _episodeIndex;

  late VideoData _video;

  MovieData? _movie;

  @override
  void init() {
    translation.addListener(_loadVideo);
    videoController.addListener(_onVideoControllerValueChanged);
  }

  @override
  Future<void> setMovieEpisode({
    required Object movieId,
    required Object episodeId,
  }) async {
    if (movieId != _movie?.id) {
      await _loadMovie(movieId: movieId);
    }
    _episodeIndex = _movie!.episodes.indexWhere(
      (episode) => episode.id == episodeId,
    );
    await _loadTranslations();
  }

  @override
  void changeTranslation(VideoTranslationData value) {
    translation.value = value;
  }

  @override
  void loadPreviousEpisode() {
    _episodeIndex--;
    _loadTranslations();
  }

  @override
  void loadNextEpisode() {
    _episodeIndex++;
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
    title.value = _movie!.title;
  }

  Future<void> _loadTranslations() async {
    assert(_movie != null);

    final Object episodeId = _movie!.episodes[_episodeIndex].id;
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
    videoController.initializeUri(_video.sources.values.first.uri);
    await videoController.play();
  }

  Future<void> _onVideoControllerValueChanged() async {
    assert(_movie != null);

    if (videoController.value.isCompleted) {
      if (_episodeIndex < _movie!.episodes.length - 1) {
        loadNextEpisode();
      }
      await _service.postTranslationWatched(
        translation.value!.id,
        csrf: _video.csrf,
      );
    }
  }
}
