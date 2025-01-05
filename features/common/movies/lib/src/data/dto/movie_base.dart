import 'package:core/core.dart';
import 'package:movies/src/data/dto/movie_type.dart';

class MovieBaseDto {
  const MovieBaseDto({
    required this.id,
    required this.title,
    required this.poster,
    required this.type,
    this.score,
  });

  final int id;

  final String title;

  final ImageDto poster;

  final MovieTypeDto type;

  final double? score;
}
