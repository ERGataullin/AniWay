import 'dart:core';

import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/player/player.dart';
import 'package:flutter/foundation.dart';

abstract interface class IMoviePlayerModel implements ElementaryModel {
  ValueListenable<MovieDetailsData?> get movie;

  ValueListenable<EpisodeData?> get episode;

  ValueListenable<List<TranslationData>> get translations;

  ValueListenable<bool> get hasPreviousEpisode;

  ValueListenable<bool> get hasNextEpisode;

  void loadData({required int movieId, int? episodeId});

  void loadPreviousEpisode();

  void loadNextEpisode();

  Future<VideoData> getVideo(int translationId);

  void saveTranslationWatched(int translationId);
}

class MoviePlayerModel extends ElementaryModel implements IMoviePlayerModel {
  MoviePlayerModel(
    ErrorHandler errorHandler, {
    required this._repository,
  }) : super(errorHandler: errorHandler);

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<EpisodeData?> episode = ValueNotifier(null);

  @override
  final ValueNotifier<List<TranslationData>> translations = ValueNotifier(
    const [],
  );

  @override
  final ValueNotifier<bool> hasPreviousEpisode = ValueNotifier(false);

  @override
  final ValueNotifier<bool> hasNextEpisode = ValueNotifier(false);

  final MoviesRepository _repository;

  late int _episodeIndex;

  @override
  Future<void> loadData({required int movieId, int? episodeId}) async {
    movie.value = await _repository.getMovie(movieId);
    _episodeIndex =
        episodeId == null
            ? 0
            : movie.value!.episodes.indexWhere(
              (episode) => episode.id == episodeId,
            );
    if (_episodeIndex < 0) _episodeIndex = 0;
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
  Future<VideoData> getVideo(int translationId) {
    return _repository.getTranslationVideo(translationId);
  }

  @override
  void saveTranslationWatched(int translationId) {
    _repository.saveTranslationWatched(translationId);
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

  Future<void> _loadEpisode({required int index}) async {
    translations.value = const [];
    _episodeIndex = index;
    episode.value = movie.value!.episodes[index];
    hasPreviousEpisode.value = index > 0;
    hasNextEpisode.value = index < movie.value!.episodes.length - 1;
    translations.value = await _repository.getTranslations(episode.value!.id);
  }
}
