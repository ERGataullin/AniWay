import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:flutter/foundation.dart';

abstract interface class IMovieDetailsModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<MovieDetailsData?> get movie;

  ValueNotifier<WatchStatusDetails?> get watchStatusDetails;

  ValueListenable<int?> get nextEpisodeId;

  void loadData({required int movieId});
}

class MovieDetailsModel extends ElementaryModel implements IMovieDetailsModel {
  MovieDetailsModel({super.errorHandler, required MoviesRepository repository})
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
      final int episodesCount = watchStatusDetails.value?.episodesCount ?? 0;
      return episodesCount >= movie.value!.episodes.length
          ? movie.value!.episodes.first.id
          : movie.value?.episodes
              .getRange(
                episodesCount == 0 ? 0 : episodesCount - 1,
                movie.value!.episodes.length,
              )
              .firstWhere(
                (episode) => episode.number! > episodesCount,
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
      watchStatusDetails.value = await _repository.getWatchStatus(
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
