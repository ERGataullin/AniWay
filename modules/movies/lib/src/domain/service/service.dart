import 'dart:async';

import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/movie_watch_status.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class MoviesService {
  const MoviesService();

  int get defaultMoviesLimit;

  Future<List<MoviePreviewData>> getMovies({
    MovieOrderData? order,
    String? query,
    int? limit,
    int? offset,
    List<MovieWatchStatusData> watchStatus = const [],
  });

  Future<List<UpNextData>> getUpNext();
}
