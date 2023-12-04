import 'package:player/src/data/dto/episode.dart';

export 'package:player/src/data/dto/episode.dart';

class MovieDto {
  const MovieDto({
    required this.id,
    required this.title,
    required this.episodes,
  });

  final Object id;

  final String title;

  final List<EpisodeDto> episodes;
}
