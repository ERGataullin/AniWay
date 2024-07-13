import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/domain/models/movie_type.dart';

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    this.number,
  });

  factory EpisodeData.fromDto(EpisodeDto dto) => EpisodeData(
        id: dto.id,
        type: MovieType.valueOf(dto.type),
        number: dto.number,
      );

  final int id;

  final MovieType type;

  final num? number;
}
