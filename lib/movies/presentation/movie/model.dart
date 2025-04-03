import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:flutter/foundation.dart';

abstract interface class IMovieModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<MovieDetailsData?> get movie;

  ValueNotifier<WatchStatusDetails?> get watchStatusDetails;

  ValueListenable<int?> get nextEpisodeId;

  void loadData({required int movieId});
}

class MovieModel extends ElementaryModel implements IMovieModel {
  MovieModel({super.errorHandler, required MoviesRepository repository})
    : _repository = repository;

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  @override
  final ValueNotifier<WatchStatusDetails?> watchStatusDetails = ValueNotifier(
    null,
  );

  @override
  late final Computed<int?> nextEpisodeId = Computed(
    trigger: Listenable.merge([movie, watchStatusDetails]),
    () {
      final int watchedEpisodesCount =
          watchStatusDetails.value?.watchedEpisodesCount ?? 0;
      return watchedEpisodesCount >= movie.value!.episodes.length
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
    },
  );

  final MoviesRepository _repository;

  @override
  Future<void> loadData({required int movieId}) async {
    try {
      loading.value = true;
      movie.value = await _repository.getMovie(movieId);
      watchStatusDetails.value = await _repository.getWatchStatusDetails(
        movie.value!.uri,
      );
    } finally {
      loading.value = false;
    }
  }

  @override
  void dispose() {
    nextEpisodeId.dispose();
    watchStatusDetails.dispose();
    movie.dispose();
    loading.dispose();
    super.dispose();
  }
}
