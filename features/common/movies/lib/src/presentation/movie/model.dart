import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_details.dart';

abstract interface class IMovieModel implements ElementaryModel {
  ValueListenable<MovieDetailsData?> get movie;

  ValueListenable<String?> get poster;

  void loadData({
    required int movieId,
  });
}

class MovieModel extends ElementaryModel implements IMovieModel {
  MovieModel({
    super.errorHandler,
    required MoviesService service,
    required Network network,
  })  : _service = service,
        _network = network;

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<String?> poster = ValueNotifier('');

  final MoviesService _service;

  final Network _network;

  //poster убрать в wm сделать
  @override
  Future<void> loadData({
    required int movieId,
  }) async {
    movie.value = await _service.getMovie(movieId);
    poster.value =
        _network.baseUri.resolveUri(movie.value!.posterUri).toString();
  }
}
