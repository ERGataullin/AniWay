import 'package:movies/movies.dart';
import 'package:movies/src/data/dto/movie_player.dart';
import 'package:player/player.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    int? limit,
    int? offset,
    List<String?> watchStatus = const [],
  }) {
    return _remote.getMovies(
      order: order,
      query: query,
      limit: limit,
      offset: offset,
      watchStatus: watchStatus,
    );
  }

  Future<List<Map<String, dynamic>>> getUpNext({required int page}) {
    return _remote.getUpNext(page: page);
  }

  Future<MoviePlayerDto> getPlayerMovie(int id) {
    return _remote.getPlayerMovie(id);
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
}
