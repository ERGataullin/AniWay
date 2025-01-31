import 'package:core/core.dart';
import 'package:movies/src/data/dto/episode.dart';

class MovieDetailsDto {
  const MovieDetailsDto({
    required this.id,
    required this.url,
    required this.title,
    required this.genres,
    required this.poster,
    required this.previews,
    this.episodesCount,
    required this.episodes,
    this.description,
    this.score,
  });

  final int id;

  final String url;

  final String title;

  final List<String> genres;

  final ImageData poster;

  final List<EpisodeDto> previews;

  final int? episodesCount;

  final List<EpisodeDto> episodes;

  final String? description;

  final double? score;
}
