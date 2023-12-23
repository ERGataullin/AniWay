import 'dart:async';

import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_episode.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/movie_type.dart';
import 'package:movies/src/domain/models/movie_watch_status.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/up_next_movie.dart';

class Anime365MoviesService implements MoviesService {
  Anime365MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<List<MoviePreviewData>> getMovies({
    MovieOrderData? order,
    String? query,
    String? limit,
    String? offset,
    List<MovieWatchStatusData> watchStatus = const [],
  }) {
    return _repository
        .getMovies(
          query: query,
          limit: limit,
          offset: offset,
          order: switch (order) {
            MovieOrderData.byScore => 'ranked',
            MovieOrderData.byPopularity => 'popularity',
            MovieOrderData.byName => 'name',
            MovieOrderData.byReleaseDate => 'aired_on',
            MovieOrderData.random => 'random',
            null => null,
          },
          watchStatus: watchStatus
              .map(
                (watchStatus) => switch (watchStatus) {
                  MovieWatchStatusData.none => null,
                  MovieWatchStatusData.planned => 'planned',
                  MovieWatchStatusData.watching => 'watching',
                  MovieWatchStatusData.rewatching => 'rewatching',
                  MovieWatchStatusData.completed => 'completed',
                  MovieWatchStatusData.onHold => 'on_hold',
                  MovieWatchStatusData.dropped => 'dropped',
                },
              )
              .toList(growable: false),
        )
        .then(
          (moviesJson) => moviesJson
              .map(
                (movieJson) => MoviePreviewData(
                  id: movieJson['id'] as int,
                  title: movieJson['titles']['ru'] as String,
                  posterUri: Uri.parse(movieJson['posterUrl'] as String),
                  type: switch (movieJson['type']) {
                    'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieTypeData.tv,
                    'movie' => MovieTypeData.movie,
                    'ova' => MovieTypeData.ova,
                    'ona' => MovieTypeData.ona,
                    'special' => MovieTypeData.special,
                    'music' => MovieTypeData.music,
                    _ => throw UnsupportedError(
                        'Unsupported movie type: ${movieJson['type']}',
                      ),
                  },
                  score: double.parse(movieJson['myAnimeListScore'] as String),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<List<UpNextData>> getUpNext() {
    return _repository.getUpNext().then(
          (upNextJson) => upNextJson
              .map(
                (itemJson) => UpNextData(
                  movie: UpNextMovieData(
                    id: itemJson['movie']['id'] as int,
                    title: itemJson['movie']['titles']['ru'] as String,
                    posterUri: Uri.parse(
                      itemJson['movie']['posterUrl'] as String,
                    ),
                  ),
                  episode: MovieEpisodeData(
                    id: itemJson['episode']['id'] as int,
                    type: switch (itemJson['episode']['type']) {
                      'tv' => MovieEpisodeTypeData.tv,
                      'movie' => MovieEpisodeTypeData.movie,
                      'ova' => MovieEpisodeTypeData.ova,
                      'ona' => MovieEpisodeTypeData.ona,
                      'special' => MovieEpisodeTypeData.special,
                      _ => throw UnsupportedError(
                          'Unsupported episode type: '
                          '${itemJson['episode']['type']}',
                        )
                    },
                    number: itemJson['episode']['number'] as num?,
                  ),
                ),
              )
              .toList(growable: false),
        );
  }
}
