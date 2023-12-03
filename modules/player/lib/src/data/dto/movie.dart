import 'package:player/src/data/dto/episode.dart';

export 'package:player/src/data/dto/episode.dart';

/// {@macro player.domain.models.movie.MovieData}
class MovieDto {
  const MovieDto({
    required this.id,
    required this.title,
    required this.episodes,
  });

  /// {@macro player.domain.models.movie.MovieData.id}
  final Object id;

  /// {@macro player.domain.models.movie.MovieData.title}
  final String title;

  /// {@macro player.domain.models.movie.MovieData.episodes}
  final List<EpisodeDto> episodes;
}
