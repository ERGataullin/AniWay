import 'package:core/core.dart';
import 'package:movies/src/data/dto/movie_base.dart';
import 'package:movies/src/domain/models/movie_type.dart';

class MovieBaseData {
  const MovieBaseData({
    required this.id,
    required this.title,
    required this.poster,
    required this.type,
    this.score,
  });

  factory MovieBaseData.fromDto(MovieBaseDto dto) => MovieBaseData(
        id: dto.id,
        title: dto.title,
        poster: ImageData.fromDto(dto.poster),
        type: MovieType.fromDto(dto.type),
        score: dto.score,
      );

  final int id;

  final String title;

  final ImageData poster;

  final MovieType type;

  final double? score;
}
