import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/data/dto/movies_order.dart';
import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/data/dto/watch_list_element.dart';
import 'package:movies/src/data/dto/watch_status.dart';
import 'package:player/player.dart';

abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<MovieBaseDto>> getMovies({
    MoviesOrderDto order = MoviesOrderDto.byPopularity,
    String? query,
    int? limit,
    int? offset,
    List<WatchStatusDto> watchStatuses = const [],
  });

  Future<List<UpNextDto>> getUpNext({required int page});

  Future<MovieDetailsDto> getMovie(int id);

  Future<List<VideoTranslationDto>> getTranslations(int episodeId);

  Future<VideoDto> getTranslationVideo(int translationId);

  Future<void> saveTranslationWatched(int translationId);

  Future<WatchListElementDto> getWatchListElement(int movieId);
}
