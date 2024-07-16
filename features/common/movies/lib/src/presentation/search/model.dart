import 'dart:async';

import 'package:core/core.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class IMoviesSearchModel implements ElementaryModel {
  Future<List<MovieBaseData>> loadPage({
    required int page,
    String? query,
  });
}

class MoviesSearchModel extends ElementaryModel implements IMoviesSearchModel {
  MoviesSearchModel({
    super.errorHandler,
    required MoviesService service,
  }) : _service = service;

  final MoviesService _service;

  @override
  Future<List<MovieBaseData>> loadPage({
    required int page,
    String? query,
  }) {
    return _service.getMovies(
      page: page,
      query: query,
    );
  }
}
