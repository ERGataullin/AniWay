import 'package:movies/src/data/dto/episode.dart';

class MovieDetailsDto {
  const MovieDetailsDto({
    required this.id,
    required this.title,
    required this.episodes,
  });

  final int id;

  final String title;

  final List<EpisodeDto> episodes;
}
