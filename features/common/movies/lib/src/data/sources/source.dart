import 'package:movies/src/data/dto/movie_player.dart';
import 'package:player/player.dart';

abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    int? limit,
    int? offset,
    List<String?> watchStatus = const [],
  });

  Future<List<Map<String, dynamic>>> getUpNext();

  Future<MoviePlayerDto> getPlayerMovie(Object id);

  Future<List<VideoTranslationDto>> getTranslations(Object episodeId);

  Future<VideoDto> getTranslationVideo(Object translationId);

  Future<void> saveTranslationWatched(Object translationId);
}
