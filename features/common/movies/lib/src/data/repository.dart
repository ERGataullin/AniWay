import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/watch_list_element.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:player/player.dart';

class MoviesRepository implements Initable {
  MoviesRepository({
    required MoviesService remote,
  }) : _remote = remote;

  final MoviesService _remote;

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
    return _remote.getMovies(
      offset: (page - 1) * limit,
      limit: limit,
      isOngoing: isOngoing,
      query: query,
      order: order,
      watchStatuses: watchStatuses,
    );
  }

  Future<List<UpNextData>> getUpNext({int page = 1}) {
    return _remote.getUpNext(page: page);
  }

  Future<MovieDetailsData> getMovie(int id) {
    return _remote.getMovie(id);
  }

  Future<List<VideoTranslationData>> getTranslations(int episodeId) {
    return _remote.getTranslations(episodeId);
  }

  Future<VideoData> getTranslationVideo(int translationId) {
    return _remote.getTranslationVideo(translationId);
  }

  Future<void> saveTranslationWatched(int translationId) async {
    await _remote.saveTranslationWatched(translationId);
    _upNextChanges.value++;
  }

  Future<WatchListElementData?> getWatchStatusDetails(Uri movieUri) {
    return _remote.getWatchStatusDetails(movieUri);
  }
}
