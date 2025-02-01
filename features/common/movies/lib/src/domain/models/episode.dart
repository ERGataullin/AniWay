import 'package:core/core.dart';
import 'package:movies/src/domain/models/movie_type.dart';

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    this.number,
    this.preview,
  });

  final int id;

  final MovieType type;

  final num? number;

  final ImageData? preview;
}
