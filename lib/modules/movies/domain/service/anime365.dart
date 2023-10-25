import 'dart:async';

import '/modules/movies/data/repository.dart';
import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/domain/models/movie_type.dart';
import '/modules/movies/domain/service/service.dart';

class Anime365MoviesService implements MoviesService {
  Anime365MoviesService({
    required MoviesRepository repository,
  }) : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<List<MoviePreviewData>> getMovies() {
    return _repository.getMovies().then(
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
                  score: movieJson['myAnimeListScore'] as double,
                ),
              )
              .toList(growable: false),
        );
  }
}
