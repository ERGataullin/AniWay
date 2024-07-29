import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_details.dart';

abstract interface class IMovieModel implements ElementaryModel {
  ValueListenable<MovieDetailsData?> get movie;

  void loadData({
    required int movieId,
  });
}

class MovieModel extends ElementaryModel implements IMovieModel {
  MovieModel({
    super.errorHandler,
    required MoviesService service,
  }) : _service = service;

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  final MoviesService _service;

  @override
  Future<void> loadData({
    required int movieId,
  }) async {
    movie.value = await _service.getMovie(movieId);
  }
}
