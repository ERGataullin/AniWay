import 'package:app/core/core.dart';
import 'package:app/movies/data/services/service.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/player/player.dart';
import 'package:flutter/foundation.dart';

class MoviesRepository with Initable {
  MoviesRepository({required MoviesService moviesService})
    : _moviesService = moviesService;

  final MoviesService _moviesService;

  final _upNextChanges = ValueNotifier<int>(0);

  Listenable get upNextChanges => _upNextChanges;

  @override
  void dispose() {
    _upNextChanges.dispose();
    super.dispose();
  }

  Future<List<MovieBaseData>> getMovies({
    int page = 1,
    int limit = 50,
    bool? isOngoing,
    String? query,
    MoviesOrder order = MoviesOrder.byPopularity,
    List<MovieType> typesExcluded = const [],
    List<WatchStatus> watchStatuses = const [],
  }) {
    return _moviesService.getMovies(
      offset: (page - 1) * limit,
      limit: limit,
      isOngoing: isOngoing,
      query: query,
      order: order,
      typesExcluded: typesExcluded,
      watchStatuses: watchStatuses,
    );
  }

  Future<List<UpNextData>> getUpNext({int page = 1}) {
    return _moviesService.getUpNext(page: page);
  }

  Future<MovieDetailsData> getMovie(int id) {
    return _moviesService.getMovie(id);
  }

  Future<List<VideoTranslationData>> getTranslations(int episodeId) {
    return _moviesService.getTranslations(episodeId);
  }

  Future<VideoData> getTranslationVideo(int translationId) {
    return _moviesService.getTranslationVideo(translationId);
  }

  Future<void> saveTranslationWatched(int translationId) async {
    await _moviesService.saveTranslationWatched(translationId);
    _upNextChanges.value++;
  }

  Future<WatchStatusDetails> getWatchStatus(Uri movieUri) {
    return _moviesService.getWatchStatus(movieUri);
  }

  Future<void> saveWatchStatus({
    required int movieId,
    required WatchStatusDetails status,
  }) {
    return _moviesService.saveWatchStatus(
      movieId: movieId,
      watchStatusDetails: status,
    );
  }
}
