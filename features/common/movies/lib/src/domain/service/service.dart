import 'dart:async';

import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';

abstract interface class MoviesService {
  const MoviesService();

  int get defaultMoviesLimit;

  Future<List<MovieBaseData>> getMovies({
    MovieOrderData? order,
    String? query,
    int? limit,
    int? offset,
    List<ViewStatusData> viewStatuses = const [],
  });

  Future<List<UpNextData>> getUpNext();
}
