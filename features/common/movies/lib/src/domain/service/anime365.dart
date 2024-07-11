import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_player.dart';
import 'package:movies/src/domain/models/movie_type.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';
import 'package:player/player.dart';

class Anime365MoviesService implements MoviesService {
  Anime365MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  static const int _defaultMoviesLimit = 50;

  @override
  final ValueNotifier<int> upNextChanges = ValueNotifier(0);

  @override
  int get defaultMoviesLimit => _defaultMoviesLimit;

  final MoviesRepository _repository;

  @override
  void init() {}

  @override
  Future<List<MovieBaseData>> getMovies({
    MovieOrder? order,
    String? query,
    int? limit = _defaultMoviesLimit,
    int? offset,
    List<ViewStatus> viewStatuses = const [],
  }) {
    return _repository
        .getMovies(
          query: query,
          limit: limit,
          offset: offset,
          order: switch (order) {
            MovieOrder.byScore => 'ranked',
            MovieOrder.byPopularity => 'popularity',
            MovieOrder.byName => 'name',
            MovieOrder.byReleaseDate => 'aired_on',
            MovieOrder.random => 'random',
            null => null,
          },
          watchStatus: viewStatuses
              .map(
                (watchStatus) => switch (watchStatus) {
                  ViewStatus.none || ViewStatus.unknown => null,
                  ViewStatus.planned => 'planned',
                  ViewStatus.watching => 'watching',
                  ViewStatus.rewatching => 'rewatching',
                  ViewStatus.completed => 'completed',
                  ViewStatus.onHold => 'on_hold',
                  ViewStatus.dropped => 'dropped',
                },
              )
              .toList(growable: false),
        )
        .then(
          (moviesJson) => moviesJson
              .map(
                (movieJson) => MovieBaseData(
                  id: movieJson['id'] as Object,
                  title:
                      movieJson['titles']['ru'] ?? movieJson['title'] as String,
                  posterUri: Uri.parse(movieJson['posterUrl'] as String),
                  type: switch (movieJson['type']) {
                    'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieType.tv,
                    'movie' => MovieType.movie,
                    'ova' => MovieType.ova,
                    'ona' => MovieType.ona,
                    'special' => MovieType.special,
                    'tv_special' => MovieType.tvSpecial,
                    'cm' => MovieType.ad,
                    'music' => MovieType.music,
                    'pv' => MovieType.preview,
                    _ => throw UnimplementedError(
                        'Unimplemented movie type: ${movieJson['type']}',
                      ),
                  },
                  score: movieJson['myAnimeListScore'] == '-1'
                      ? null
                      : double.parse(movieJson['myAnimeListScore'] as String),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<List<UpNextData>> getUpNext() {
    return _repository.getUpNext().then(
          (upNextJson) => upNextJson.map(
            (itemJson) {
              final MovieType type = switch (itemJson['episode']['type']) {
                'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieType.tv,
                'movie' => MovieType.movie,
                'ova' => MovieType.ova,
                'ona' => MovieType.ona,
                'special' => MovieType.special,
                'tv_special' => MovieType.tvSpecial,
                'cm' => MovieType.ad,
                'music' => MovieType.music,
                'pv' => MovieType.preview,
                _ => throw UnimplementedError(
                    'Unimplemented movie type: ${itemJson['episode']['type']}',
                  ),
              };
              return UpNextData(
                movie: MovieBaseData(
                  id: itemJson['movie']['id'] as Object,
                  title: itemJson['movie']['titles']['ru'] as String,
                  posterUri: Uri.parse(
                    itemJson['movie']['posterUrl'] as String,
                  ),
                  type: type,
                ),
                episode: EpisodeData(
                  id: itemJson['episode']['id'] as Object,
                  type: type,
                  number: itemJson['episode']['number'] as num?,
                ),
              );
            },
          ).toList(growable: false),
        );
  }

  @override
  Future<MoviePlayerData> getPlayerMovie(Object id) {
    return _repository.getPlayerMovie(id).then(MoviePlayerData.fromDto);
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(Object episodeId) async {
    final List<VideoTranslationDto> dtos =
        await _repository.getTranslations(episodeId);
    return dtos.map(VideoTranslationData.fromDto).toList(growable: false);
  }

  @override
  Future<VideoData> getTranslationVideo(Object translationId) async {
    return _repository
        .getTranslationVideo(translationId)
        .then(VideoData.fromDto);
  }

  @override
  Future<void> saveTranslationWatched(Object translationId) async {
    await _repository.saveTranslationWatched(translationId);
    upNextChanges.value++;
  }

  @override
  void dispose() {
    upNextChanges.dispose();
  }
}
