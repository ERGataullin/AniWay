import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/watch_list_element.dart';

abstract interface class IMovieModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<MovieDetailsData?> get movie;

  ValueListenable<WatchListElementData?> get watchStatusDetails;

  int? get nextEpisodeId;

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
  final ValueNotifier<WatchListElementData?> watchStatusDetails =
      ValueNotifier(null);

  @override
  late final int? nextEpisodeId;

  final MoviesService _service;

  @override
  Future<void> loadData({
    required int movieId,
  }) async {
    loading.value = true;
    movie.value = await _service.getMovie(movieId);
    watchStatusDetails.value = await _service.getWatchStatusDetails(
      movie.value!.uri,
    );
    final int watchedEpisodesCount =
        watchStatusDetails.value!.watchedEpisodesCount;
    nextEpisodeId = watchedEpisodesCount >= movie.value!.episodes.length
        ? null
        : movie.value?.episodes
            .getRange(
              watchedEpisodesCount == 0 ? 0 : watchedEpisodesCount - 1,
              movie.value!.episodes.length,
            )
            .firstWhere(
              (episode) => episode.number! > watchedEpisodesCount,
              orElse: () => movie.value!.episodes.first,
            )
            .id;
    loading.value = false;
  }
}
