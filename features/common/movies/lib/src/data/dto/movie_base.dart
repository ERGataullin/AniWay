import 'package:movies/src/data/dto/movie_type.dart';

class MovieBaseDto {
  const MovieBaseDto({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
    this.score,
  });

  final int id;

  final String title;

  final String posterUrl;

  final MovieTypeDto type;

  final double? score;
}
