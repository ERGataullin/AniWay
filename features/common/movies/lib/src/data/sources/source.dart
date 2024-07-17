import 'package:core/core.dart';
import 'package:movies/src/data/dto/movie_player.dart';
import 'package:player/player.dart';

abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<Json>> getMovies({
    String? order,
    String? query,
    int? limit,
    int? offset,
    List<String?> watchStatus = const [],
  });

  Future<List<Json>> getUpNext({required int page});

  Future<MoviePlayerDto> getPlayerMovie(int id);

  Future<List<VideoTranslationDto>> getTranslations(int episodeId);

  Future<VideoDto> getTranslationVideo(int translationId);

  Future<void> saveTranslationWatched(int translationId);
}
