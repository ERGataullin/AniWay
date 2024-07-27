import 'package:movies/src/data/dto/movie_type.dart';

class EpisodeDto {
  const EpisodeDto({
    required this.id,
    required this.type,
    required this.number,
  });

  final int id;

  final MovieTypeDto type;

  final num? number;
}
