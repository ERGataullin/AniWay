import 'package:player/player.dart';

class PlayerRepository {
  const PlayerRepository({
    required PlayerDataSource remote,
  }) : _remote = remote;

  final PlayerDataSource _remote;

  Future<MovieDto> getMovie(Object id) {
    return _remote.getMovie(id);
  }

  Future<List<VideoTranslationDto>> getTranslations(Object episodeId) {
    return _remote.getTranslations(episodeId);
  }

  Future<VideoDto> getTranslationVideo(String embedUrl) {
    return _remote.getTranslationVideo(embedUrl);
  }
}
