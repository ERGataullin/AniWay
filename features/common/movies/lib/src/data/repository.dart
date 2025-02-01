import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/watch_list_element.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:player/player.dart';

class MoviesRepository implements Initable {
  MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

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
  }) async {
    final List<MovieBaseDto> dtos = await _remote.getMovies(
      offset: (page - 1) * limit,
      limit: limit,
      isOngoing: isOngoing,
      query: query,
      order: order.toDto(),
      watchStatuses: watchStatuses
          .map((watchStatus) => watchStatus.toDto())
          .toList(growable: false),
    );

    return dtos.map(MovieBaseData.fromDto).toList(growable: false);
  }

  Future<List<UpNextData>> getUpNext({int page = 1}) async {
    final List<UpNextDto> dtos = await _remote.getUpNext(page: page);
    return dtos.map(UpNextData.fromDto).toList(growable: false);
  }

  Future<MovieDetailsData> getMovie(int id) async {
    final MovieDetailsDto dto = await _remote.getMovie(id);
    return MovieDetailsData.fromDto(dto);
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

  Future<WatchListElementData?> getWatchStatusDetails(Uri movieUri) async {
    final WatchListElementDto dto =
        await _remote.getWatchStatusDetails(movieUri);
    return WatchListElementData.fromDto(dto);
  }
}
