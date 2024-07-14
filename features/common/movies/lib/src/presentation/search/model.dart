import 'dart:async';

import 'package:core/core.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class IMoviesSearchModel implements ElementaryModel {
  int get pageSize;

  Future<List<MovieBaseData>> loadPage(
    int page, {
    String? query,
  });
}

class MoviesSearchModel extends ElementaryModel implements IMoviesSearchModel {
  MoviesSearchModel({
    required MoviesService service,
  }) : _service = service;

  final MoviesService _service;

  @override
  int get pageSize => _service.defaultMoviesLimit;

  @override
  Future<List<MovieBaseData>> loadPage(
    int page, {
    String? query,
  }) {
    return _service.getMovies(
      query: query,
      offset: (page - 1) * pageSize,
    );
  }
}
