import 'package:player/player.dart';

export 'package:player/src/domain/models/episode.dart';

/// {@template player.domain.models.movie.MovieData}
/// Фильм/сериал.
/// {@endtemplate}
class MovieData {
  const MovieData({
    required this.id,
    required this.title,
    required this.episodes,
  });

  /// Создание фильма/сериала из соответствующего [MovieDto].
  factory MovieData.fromDto(MovieDto dto) => MovieData(
        id: dto.id,
        title: dto.title,
        episodes: dto.episodes.map(EpisodeData.fromDto).toList(growable: false),
      );

  /// {@template player.domain.models.movie.MovieData.id}
  /// Идентификатор.
  /// {@endtemplate}
  final Object id;

  /// {@template player.domain.models.movie.MovieData.title}
  /// Название.
  /// {@endtemplate}
  final String title;

  /// {@template player.domain.models.movie.MovieData.episodes}
  /// Список эпизодов.
  /// {@endtemplate}
  final List<EpisodeData> episodes;
}
