import 'package:player/src/domain/models/movie.dart';
import 'package:player/src/domain/models/video.dart';
import 'package:player/src/domain/models/video_translation.dart';

export 'package:player/src/domain/models/movie.dart';
export 'package:player/src/domain/models/video.dart';
export 'package:player/src/domain/models/video_translation.dart';

abstract interface class PlayerService {
  const PlayerService();

  Future<MovieData> getMovie(Object id);

  Future<List<VideoTranslationData>> getTranslations(Object episodeId);

  Future<VideoData> getTranslationVideo(Uri embedUri);

  Future<void> postTranslationWatched(Object id);
}
