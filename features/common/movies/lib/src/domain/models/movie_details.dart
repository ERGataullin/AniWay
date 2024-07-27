import 'package:movies/src/data/dto/movie_details.dart';
import 'package:movies/src/domain/models/episode.dart';

class MovieDetailsData {
  const MovieDetailsData({
    required this.id,
    required this.title,
    required this.episodes,
  });

  factory MovieDetailsData.fromDto(MovieDetailsDto dto) => MovieDetailsData(
        id: dto.id,
        title: dto.title,
        episodes: List.unmodifiable(dto.episodes.map(EpisodeData.fromDto)),
      );

  final int id;

  final String title;

  final List<EpisodeData> episodes;
}
