import 'package:core/core.dart';
import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/domain/models/movie_type.dart';

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    this.number,
    this.preview,
  });

  factory EpisodeData.fromDto(EpisodeDto dto) => EpisodeData(
        id: dto.id,
        type: MovieType.fromDto(dto.type),
        number: dto.number,
        preview: switch (dto.preview) {
          final ImageDto previewDto => ImageData.fromDto(previewDto),
          null => null,
        },
      );

  final int id;

  final MovieType type;

  final num? number;

  final ImageData? preview;
}
