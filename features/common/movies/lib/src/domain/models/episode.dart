import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/domain/models/movie_type.dart';

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    this.number,
    required this.previewUri,
  });

  factory EpisodeData.fromDto(EpisodeDto dto) => EpisodeData(
        id: dto.id,
        type: MovieType.fromDto(dto.type),
        number: dto.number,
        previewUri: Uri.parse(dto.previewUrl ?? ''),
      );

  final int id;

  final MovieType type;

  final num? number;

  final Uri previewUri;
}
