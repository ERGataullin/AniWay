import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_list_element.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/movies.dart';
import 'package:app/player/player.dart';
import 'package:flutter/foundation.dart';

class MoviesRepository implements Initable {
  MoviesRepository({
    required MoviesService moviesService,
  }) : _moviesService = moviesService;

  final MoviesService _moviesService;

  final _upNextChanges = ValueNotifier(0);

  Listenable get upNextChanges => _upNextChanges;

  @override
  void init() {}

  @override
  void dispose() {
    _upNextChanges.dispose();
  }

  Future<List<MovieBaseData>> getMovies({
    int page = 1,
    int limit = 50,
    bool? isOngoing,
    String? query,
    MoviesOrder order = MoviesOrder.byPopularity,
    List<WatchStatus> watchStatuses = const [],
  }) {
    return _moviesService.getMovies(
      offset: (page - 1) * limit,
      limit: limit,
      isOngoing: isOngoing,
      query: query,
      order: order,
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

  Future<WatchListElementData?> getWatchStatusDetails(Uri movieUri) {
    return _moviesService.getWatchStatusDetails(movieUri);
  }
}
