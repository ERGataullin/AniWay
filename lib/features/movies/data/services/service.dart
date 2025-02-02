import 'package:app/features/movies/domain/models/movie_base.dart';
import 'package:app/features/movies/domain/models/movie_details.dart';
import 'package:app/features/movies/domain/models/movies_order.dart';
import 'package:app/features/movies/domain/models/up_next.dart';
import 'package:app/features/movies/domain/models/watch_list_element.dart';
import 'package:app/features/movies/domain/models/watch_status.dart';
import 'package:app/features/player/player.dart';

abstract interface class MoviesService {
  const MoviesService();

  Future<List<MovieBaseData>> getMovies({
    int? limit,
    int? offset,
    bool? isOngoing,
    String? query,
    MoviesOrder order = MoviesOrder.byPopularity,
    List<WatchStatus> watchStatuses = const [],
  });

  Future<List<UpNextData>> getUpNext({required int page});

  Future<MovieDetailsData> getMovie(int id);

  Future<List<VideoTranslationData>> getTranslations(int episodeId);

  Future<VideoData> getTranslationVideo(int translationId);

  Future<void> saveTranslationWatched(int translationId);

  Future<WatchListElementData?> getWatchStatusDetails(Uri movieUri);
}
