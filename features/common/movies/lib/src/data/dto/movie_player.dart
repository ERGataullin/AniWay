import 'package:movies/src/data/dto/episode.dart';

class MoviePlayerDto {
  const MoviePlayerDto({
    required this.id,
    required this.title,
    required this.episodes,
  });

  final Object id;

  final String title;

  final List<EpisodeDto> episodes;
}
