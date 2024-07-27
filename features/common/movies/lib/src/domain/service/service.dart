import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_player.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/view_status.dart';
import 'package:player/player.dart';

abstract interface class MoviesService implements Initable {
  const MoviesService();

  Listenable get upNextChanges;

  Future<List<MovieBaseData>> getMovies({
    int page = 1,
    int limit,
    MoviesOrder order = MoviesOrder.byPopularity,
    String? query,
    List<ViewStatus> viewStatuses = const [],
  });

  Future<List<UpNextData>> getUpNext({int page = 1});

  Future<MoviePlayerData> getPlayerMovie(int id);

  Future<List<VideoTranslationData>> getTranslations(int episodeId);

  Future<VideoData> getTranslationVideo(int translationId);

  Future<void> saveTranslationWatched(int translationId);
}
