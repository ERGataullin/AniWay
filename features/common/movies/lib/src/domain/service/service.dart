import 'dart:async';

import 'package:core/core.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_player.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';
import 'package:player/player.dart';

abstract interface class MoviesService implements Initable {
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

  Future<MoviePlayerData> getPlayerMovie(Object id);

  Future<List<VideoTranslationData>> getTranslations(Object episodeId);

  Future<VideoData> getTranslationVideo(Object translationId);

  Future<void> saveTranslationWatched(Object translationId);
}
