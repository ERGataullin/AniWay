import 'package:core/core.dart';
import 'package:movies/src/data/dto/episode.dart';

class MovieDetailsDto {
  const MovieDetailsDto({
    required this.id,
    required this.url,
    required this.title,
    required this.poster,
    required this.previews,
    required this.episodes,
    required this.numberOfEpisodes,
    this.description,
    this.score,
  });

  final int id;

  final String url;

  final String title;

  final ImageDto poster;

  final List<EpisodeDto> previews;

  final List<EpisodeDto> episodes;

  final int numberOfEpisodes;

  final String? description;

  final double? score;
}
