import 'package:movies/src/domain/models/movie_type.dart';

class EpisodeData {
  const EpisodeData({
    required this.id,
    required this.type,
    this.number,
  });

  final Object id;
  final MovieTypeData type;
  final num? number;
}
