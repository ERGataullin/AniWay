import 'package:movies/src/data/dto/episode.dart';

class MovieDetailsDto {
  const MovieDetailsDto({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.episodes,
  });

  final int id;

  final String title;

  final String posterUrl;

  final List<EpisodeDto> episodes;
}
