import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/data/dto/movies_order.dart';
import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/data/dto/watch_status.dart';
import 'package:player/player.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<MovieBaseDto>> getMovies({
    MoviesOrderDto order = MoviesOrderDto.byPopularity,
    int? isAiring,
    String? query,
    int? limit,
    int? offset,
    List<WatchStatusDto> watchStatus = const [],
  }) {
    return _remote.getMovies(
      order: order,
      isAiring: isAiring,
      query: query,
      limit: limit,
      offset: offset,
      watchStatuses: watchStatus,
    );
  }

  Future<List<UpNextDto>> getUpNext({required int page}) {
    return _remote.getUpNext(page: page);
  }

  Future<MovieDetailsDto> getMovie(int id) {
    return _remote.getMovie(id);
  }

  Future<List<VideoTranslationDto>> getTranslations(int episodeId) {
    return _remote.getTranslations(episodeId);
  }

  Future<VideoDto> getTranslationVideo(int translationId) {
    return _remote.getTranslationVideo(translationId);
  }

  Future<void> saveTranslationWatched(int translationId) {
    return _remote.saveTranslationWatched(translationId);
  }

  Future<WatchListElementDto> getWatchListElement(Uri movieUri) {
    return _remote.getWatchListElement(movieUri);
  }
}
