import 'package:movies/src/data/dto/movie_player.dart';
import 'package:movies/src/domain/models/episode.dart';

class MoviePlayerData {
  const MoviePlayerData({
    required this.id,
    required this.title,
    required this.episodes,
  });

  factory MoviePlayerData.fromDto(MoviePlayerDto dto) => MoviePlayerData(
        id: dto.id,
        title: dto.title,
        episodes: List.unmodifiable(dto.episodes.map(EpisodeData.fromDto)),
      );

  final int id;

  final String title;

  final List<EpisodeData> episodes;
}
