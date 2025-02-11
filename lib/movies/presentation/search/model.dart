import 'dart:async';

import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:elementary/elementary.dart';

abstract interface class IMoviesSearchModel implements ElementaryModel {
  Future<List<MovieBaseData>> loadPage({
    required int page,
    String? query,
    bool? isOngoing,
  });
}

class MoviesSearchModel extends ElementaryModel implements IMoviesSearchModel {
  MoviesSearchModel({
    super.errorHandler,
    required MoviesRepository repository,
  }) : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<List<MovieBaseData>> loadPage({
    required int page,
    String? query,
    bool? isOngoing,
  }) {
    return _repository.getMovies(
      page: page,
      query: query,
      isOngoing: isOngoing,
    );
  }
}
