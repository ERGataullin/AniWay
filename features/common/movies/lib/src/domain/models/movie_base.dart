import 'package:movies/src/domain/models/movie_type.dart';

class MovieBaseData {
  const MovieBaseData({
    required this.id,
    required this.title,
    required this.posterUri,
    required this.type,
    this.score,
  });

  final Object id;
  final String title;
  final Uri posterUri;
  final MovieType type;
  final double? score;
}
