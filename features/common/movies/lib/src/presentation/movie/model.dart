import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/watch_list.dart';

abstract interface class IMovieModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<MovieDetailsData?> get movie;

  ValueListenable<WatchListElementData?> get watchListElement;

  ValueListenable<int?> get currentEpisode;

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
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<WatchListElementData?> watchListElement =
      ValueNotifier(null);

  @override
  final ValueNotifier<int?> currentEpisode = ValueNotifier(null);

  final MoviesService _service;

  @override
  Future<void> loadData({
    required int movieId,
  }) async {
    loading.value = true;
    movie.value = await _service.getMovie(movieId);
    watchListElement.value = await _service.getWatchListElement(movieId);

    currentEpisode.value =
        (watchListElement.value?.countWatchedEpisodes == null)
            ? null
            : movie
                .value
                ?.episodes[watchListElement.value!.countWatchedEpisodes! + 1]
                .id;
    loading.value = false;
  }
}
