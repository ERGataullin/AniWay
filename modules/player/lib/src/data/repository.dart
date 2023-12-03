import 'package:player/player.dart';

/// Репозиторий.
class PlayerRepository {
  const PlayerRepository({
    required PlayerDataSource remote,
  }) : _remote = remote;

  /// Удалённый источник данных.
  final PlayerDataSource _remote;

  /// {@macro player.data.sources.source.PlayerDataSource.getMovie}
  Future<MovieDto> getMovie(Object id) {
    return _remote.getMovie(id);
  }

  /// {@macro player.data.sources.source.PlayerDataSource.getTranslations}
  Future<List<VideoTranslationDto>> getTranslations(Object episodeId) {
    return _remote.getTranslations(episodeId);
  }

  /// {@macro player.data.sources.source.PlayerDataSource.getTranslationVideo}
  Future<VideoDto> getTranslationVideo(String embedUrl) {
    return _remote.getTranslationVideo(embedUrl);
  }
}
