import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_details.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:app/player/player.dart';

abstract interface class MoviesService {
  const MoviesService();

  Future<List<MovieBaseData>> getMovies({
    int? limit,
    int? offset,
    bool? isOngoing,
    String? query,
    MoviesOrder order = MoviesOrder.byPopularity,
    List<MovieType> typesExcluded = const [],
    List<WatchStatus> watchStatuses = const [],
  });

  Future<List<UpNextData>> getUpNext({required int page});

  Future<MovieDetailsData> getMovie(int id);

  Future<List<VideoTranslationData>> getTranslations(int episodeId);

  Future<VideoData> getTranslationVideo(int translationId);

  Future<void> saveTranslationWatched(int translationId);

  Future<WatchStatusDetails> getWatchStatusDetails(Uri movieUri);

  Future<void> saveWatchStatus({
    required int movieId,
    required WatchStatusDetails watchStatusDetails,
  });
}
