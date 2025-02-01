import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_details.dart';
import 'package:movies/src/domain/models/movies_order.dart';
import 'package:movies/src/domain/models/up_next.dart';
import 'package:movies/src/domain/models/watch_list_element.dart';
import 'package:movies/src/domain/models/watch_status.dart';
import 'package:player/player.dart';

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
