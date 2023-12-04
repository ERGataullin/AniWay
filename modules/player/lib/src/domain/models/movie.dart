import 'package:player/player.dart';

export 'package:player/src/domain/models/episode.dart';

class MovieData {
  const MovieData({
    required this.id,
    required this.title,
    required this.episodes,
  });

  factory MovieData.fromDto(MovieDto dto) => MovieData(
        id: dto.id,
        title: dto.title,
        episodes: dto.episodes.map(EpisodeData.fromDto).toList(growable: false),
      );

  final Object id;

  final String title;

  final List<EpisodeData> episodes;
}
