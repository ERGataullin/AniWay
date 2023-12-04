import 'package:player/src/data/dto/movie.dart';
import 'package:player/src/data/dto/video.dart';
import 'package:player/src/data/dto/video_translation.dart';

export 'package:player/src/data/dto/movie.dart';
export 'package:player/src/data/dto/video.dart';
export 'package:player/src/data/dto/video_translation.dart';

abstract interface class PlayerDataSource {
  const PlayerDataSource();

  Future<MovieDto> getMovie(Object id);

  Future<List<VideoTranslationDto>> getTranslations(Object episodeId);

  Future<VideoDto> getTranslationVideo(String embedUrl);
}
