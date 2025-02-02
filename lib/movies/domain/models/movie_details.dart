import 'package:app/core/core.dart';
import 'package:app/movies/domain/models/episode.dart';

class MovieDetailsData {
  const MovieDetailsData({
    required this.id,
    required this.uri,
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

  final Uri uri;

  final String title;

  final List<String> genres;

  final ImageData poster;

  final List<EpisodeData> previews;

  final int? episodesCount;

  final List<EpisodeData> episodes;

  final String? description;

  final double? score;
}
