import 'package:app/core/core.dart';
import 'package:app/features/movies/domain/models/movie_type.dart';

class MovieBaseData {
  const MovieBaseData({
    required this.id,
    required this.title,
    required this.poster,
    required this.type,
    this.score,
  });

  final int id;

  final String title;

  final ImageData poster;

  final MovieType type;

  final double? score;
}
