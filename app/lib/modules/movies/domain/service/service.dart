import 'dart:async';

import '/modules/movies/domain/models/movie_order.dart';
import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/domain/models/movie_watch_status.dart';
import '/modules/movies/domain/models/up_next.dart';

export '/modules/movies/domain/models/movie_order.dart';
export '/modules/movies/domain/models/movie_preview.dart';
export '/modules/movies/domain/models/movie_watch_status.dart';
export '/modules/movies/domain/models/up_next.dart';

abstract interface class MoviesService {
  const MoviesService();

  Future<List<MoviePreviewData>> getMovies({
    MovieOrderData? order,
    List<MovieWatchStatusData> watchStatus = const [],
  });

  Future<List<UpNextData>> getUpNext();
}
