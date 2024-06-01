import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_base.dart';

class UpNextData {
  const UpNextData({
    required this.movie,
    required this.episode,
  });

  final MovieBaseData movie;

  final EpisodeData episode;
}
