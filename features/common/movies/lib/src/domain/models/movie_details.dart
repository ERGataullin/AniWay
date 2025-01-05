import 'package:core/core.dart';
import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/domain/models/episode.dart';

class MovieDetailsData {
  const MovieDetailsData({
    required this.id,
    required this.uri,
    required this.title,
    required this.poster,
    required this.previews,
    required this.episodes,
    this.description,
    this.score,
  });

  factory MovieDetailsData.fromDto(MovieDetailsDto dto) => MovieDetailsData(
        id: dto.id,
        uri: Uri.parse(dto.url),
        title: dto.title,
        poster: ImageData.fromDto(dto.poster),
        previews: List.unmodifiable(dto.previews.map(EpisodeData.fromDto)),
        episodes: List.unmodifiable(dto.episodes.map(EpisodeData.fromDto)),
        description: dto.description,
        score: dto.score,
      );

  final int id;

  final Uri uri;

  final String title;

  final ImageData poster;

  final List<EpisodeData> previews;

  final List<EpisodeData> episodes;

  final String? description;

  final double? score;
}
