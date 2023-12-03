import 'package:player/src/data/dto/movie.dart';
import 'package:player/src/data/dto/video.dart';
import 'package:player/src/data/dto/video_translation.dart';

export 'package:player/src/data/dto/movie.dart';
export 'package:player/src/data/dto/video.dart';
export 'package:player/src/data/dto/video_translation.dart';

/// {@template player.data.sources.source.PlayerDataSource}
/// Источник данных.
/// {@endtemplate}
abstract interface class PlayerDataSource {
  const PlayerDataSource();

  /// {@template player.data.sources.source.PlayerDataSource.getMovie}
  /// Получение фильма/сериала.
  ///
  /// [id] - идентификатор фильма/сериала.
  /// {@endtemplate}
  Future<MovieDto> getMovie(Object id);

  /// {@template player.data.sources.source.PlayerDataSource.getTranslations}
  /// Получение переводов эпизода.
  ///
  /// [episodeId] - идентификатор эпизода.
  /// {@endtemplate}
  Future<List<VideoTranslationDto>> getTranslations(Object episodeId);

  // ignore: lines_longer_than_80_chars
  /// {@template player.data.sources.source.PlayerDataSource.getTranslationVideo}
  /// Получение видео перевода.
  ///
  /// [embedUrl] - URL HTML для встраивания видео.
  /// {@endtemplate}
  Future<VideoDto> getTranslationVideo(String embedUrl);
}
