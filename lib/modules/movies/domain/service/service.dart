import 'dart:async';

import '/modules/movies/domain/models/movie_preview.dart';

abstract interface class MoviesService {
  const MoviesService();

  Future<List<MoviePreviewData>> getMovies();
}
