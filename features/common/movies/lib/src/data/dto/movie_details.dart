import 'package:movies/src/data/dto/episode.dart';

class MovieDetailsDto {
  const MovieDetailsDto({
    required this.id,
    required this.url,
    required this.title,
    required this.posterUri,
    required this.previews,
    required this.episodes,
    required this.description,
    this.score,
  });

  final int id;

  final String url;

  final String title;

  final String posterUri;

  final List<EpisodeDto> previews;

  final List<EpisodeDto> episodes;

  final String description;

  final double? score;
}
