import 'package:movies/src/data/dto/movie_type.dart';

class EpisodeDto {
  const EpisodeDto({
    required this.id,
    required this.type,
    required this.number,
    this.previewUrl,
  });

  final int id;

  final MovieTypeDto type;

  final num? number;

  final String? previewUrl;
}
