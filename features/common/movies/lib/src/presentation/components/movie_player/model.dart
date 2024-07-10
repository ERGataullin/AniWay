import 'dart:core';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_player.dart';
import 'package:player/player.dart';

abstract interface class IMoviePlayerModel implements ElementaryModel {
  ValueListenable<MoviePlayerData?> get movie;

  ValueListenable<EpisodeData?> get episode;

  ValueListenable<List<VideoTranslationData>> get translations;

  ValueListenable<bool> get hasPreviousEpisode;

  ValueListenable<bool> get hasNextEpisode;

  void loadData({
    required Object movieId,
    Object? episodeId,
  });

  void loadPreviousEpisode();

  void loadNextEpisode();

  Future<VideoData> getVideo(Object translationId);

  void saveTranslationWatched(Object translationId);
}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required MoviesService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<MoviePlayerData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<EpisodeData?> episode = ValueNotifier(null);

  @override
  final ValueNotifier<List<VideoTranslationData>> translations =
      ValueNotifier(const []);

  @override
  final ValueNotifier<bool> hasPreviousEpisode = ValueNotifier(false);

  @override
  final ValueNotifier<bool> hasNextEpisode = ValueNotifier(false);

  final MoviesService _service;

  late int _episodeIndex;

  @override
  Future<void> loadData({
    required Object movieId,
    Object? episodeId,
  }) async {
    movie.value = await _service.getPlayerMovie(movieId);
    _episodeIndex = episodeId == null
        ? 0
        : movie.value!.episodes.indexWhere(
            (episode) => episode.id == episodeId,
          );
    _loadEpisode(index: _episodeIndex);
  }

  @override
  Future<void> loadPreviousEpisode() async {
    await _loadEpisode(index: _episodeIndex - 1);
  }

  @override
  Future<void> loadNextEpisode() async {
    await _loadEpisode(index: _episodeIndex + 1);
  }

  @override
  Future<VideoData> getVideo(Object translationId) {
    return _service.getTranslationVideo(translationId);
  }

  @override
  void saveTranslationWatched(Object translationId) {
    _service.saveTranslationWatched(translationId);
  }

  @override
  void dispose() {
    movie.dispose();
    episode.dispose();
    translations.dispose();
    hasPreviousEpisode.dispose();
    hasNextEpisode.dispose();
    super.dispose();
  }

  Future<void> _loadEpisode({
    required int index,
  }) async {
    translations.value = const [];
    _episodeIndex = index;
    episode.value = movie.value!.episodes[index];
    hasPreviousEpisode.value = index > 0;
    hasNextEpisode.value = index < movie.value!.episodes.length - 1;
    translations.value = await _service.getTranslations(episode.value!.id);
  }
}
