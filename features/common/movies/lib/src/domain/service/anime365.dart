import 'dart:async';

import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_type.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';

class Anime365MoviesService implements MoviesService {
  Anime365MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  static const int _defaultMoviesLimit = 50;

  @override
  int get defaultMoviesLimit => _defaultMoviesLimit;

  final MoviesRepository _repository;

  @override
  Future<List<MovieBaseData>> getMovies({
    MovieOrderData? order,
    String? query,
    int? limit = _defaultMoviesLimit,
    int? offset,
    List<ViewStatusData> viewStatuses = const [],
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
          watchStatus: viewStatuses
              .map(
                (watchStatus) => switch (watchStatus) {
                  ViewStatusData.none || ViewStatusData.unknown => null,
                  ViewStatusData.planned => 'planned',
                  ViewStatusData.watching => 'watching',
                  ViewStatusData.rewatching => 'rewatching',
                  ViewStatusData.completed => 'completed',
                  ViewStatusData.onHold => 'on_hold',
                  ViewStatusData.dropped => 'dropped',
                },
              )
              .toList(growable: false),
        )
        .then(
          (moviesJson) => moviesJson
              .map(
                (movieJson) => MovieBaseData(
                  id: movieJson['id'] as Object,
                  title: movieJson['titles']['ru'] as String,
                  posterUri: Uri.parse(movieJson['posterUrl'] as String),
                  type: switch (movieJson['type']) {
                    'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieTypeData.tv,
                    'movie' => MovieTypeData.movie,
                    'ova' => MovieTypeData.ova,
                    'ona' => MovieTypeData.ona,
                    'special' => MovieTypeData.special,
                    'tv_special' => MovieTypeData.tvSpecial,
                    'music' => MovieTypeData.music,
                    'pv' => MovieTypeData.pv,
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
              final MovieTypeData type = switch (itemJson['episode']['type']) {
                'tv' || 'tv_13' || 'tv_24' || 'tv_48' => MovieTypeData.tv,
                'movie' => MovieTypeData.movie,
                'ova' => MovieTypeData.ova,
                'ona' => MovieTypeData.ona,
                'special' => MovieTypeData.special,
                'tv_special' => MovieTypeData.tvSpecial,
                'music' => MovieTypeData.music,
                'pv' => MovieTypeData.pv,
                _ => throw UnimplementedError(
                    'Unimplemented movie type: '
                    '${itemJson['episode']['type']}',
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
}
