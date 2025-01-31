import 'package:core/core.dart';
import 'package:movies/src/data/dto/movie_type.dart';

class EpisodeDto {
  const EpisodeDto({
    required this.id,
    required this.type,
    this.number,
    this.preview,
  });

  final int id;

  final MovieTypeDto type;

  final num? number;

  final ImageData? preview;
}
