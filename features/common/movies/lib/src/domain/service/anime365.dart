import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/movie_type.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';
import 'package:player/player.dart';

class Anime365MoviesService implements MoviesService {
  Anime365MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  @override
  final ValueNotifier<int> upNextChanges = ValueNotifier(0);

  final MoviesRepository _repository;

  @override
  void init() {}

  @override
  Future<List<MovieBaseData>> getMovies({
    int page = 1,
    int limit = 50,
    MoviesOrder order = MoviesOrder.byPopularity,
    String? query,
    List<ViewStatus> viewStatuses = const [],
  }) {
    return _repository
        .getMovies(
          query: query,
          limit: limit,
          offset: (page - 1) * limit,
          order: switch (order) {
            MoviesOrder.byScore => 'ranked',
            MoviesOrder.byPopularity => 'popularity',
            MoviesOrder.byName => 'name',
            MoviesOrder.byReleaseDate => 'aired_on',
            MoviesOrder.random => 'random',
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
                  id: movieJson['id']! as int,
                  title: (movieJson['titles'] as Json?)?['ru'] as String? ??
                      movieJson['title']! as String,
                  posterUri: Uri.parse(movieJson['posterUrl']! as String),
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
                    final Object? unsupported => throw UnsupportedError(
                        'Unsupported movie type: $unsupported',
                      ),
                  },
                  score: movieJson['myAnimeListScore'] == '-1'
                      ? null
                      : double.parse(movieJson['myAnimeListScore']! as String),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<List<UpNextData>> getUpNext({int page = 1}) async {
    final List<Json> jsons = await _repository.getUpNext(page: page);
    return jsons.map(
      (itemJson) {
        final Json movieJson = itemJson['movie']! as Json;
        final Json episodeJson = itemJson['episode']! as Json;
        final MovieType type = switch (episodeJson['type']) {
          'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieType.tv,
          'movie' => MovieType.movie,
          'ova' => MovieType.ova,
          'ona' => MovieType.ona,
          'special' => MovieType.special,
          'tv_special' => MovieType.tvSpecial,
          'cm' => MovieType.ad,
          'music' => MovieType.music,
          'pv' => MovieType.preview,
          final Object? unsupportedType => throw UnsupportedError(
              'Unimplemented movie type: $unsupportedType',
            ),
        };

        return UpNextData(
          movie: MovieBaseData(
            id: movieJson['id']! as int,
            title: (movieJson['titles']! as Json)['ru']! as String,
            posterUri: Uri.parse(movieJson['posterUrl']! as String),
            type: type,
          ),
          episode: EpisodeData(
            id: episodeJson['id']! as int,
            type: type,
            number: episodeJson['number'] as num?,
          ),
        );
      },
    ).toList(growable: false);
  }

  @override
  Future<MovieDetailsData> getMovie(int id) {
    return _repository.getMovie(id).then(MovieDetailsData.fromDto);
  }

  @override
  Future<List<VideoTranslationData>> getTranslations(int episodeId) async {
    final List<VideoTranslationDto> dtos = await _repository.getTranslations(
      episodeId,
    );
    return dtos.map(VideoTranslationData.fromDto).toList(growable: false);
  }

  @override
  Future<VideoData> getTranslationVideo(int translationId) async {
    return _repository
        .getTranslationVideo(translationId)
        .then(VideoData.fromDto);
  }

  @override
  Future<void> saveTranslationWatched(int translationId) async {
    await _repository.saveTranslationWatched(translationId);
    upNextChanges.value++;
  }

  @override
  void dispose() {
    upNextChanges.dispose();
  }
}
