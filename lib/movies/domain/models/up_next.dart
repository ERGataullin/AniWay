import 'package:app/movies/domain/models/episode.dart';
import 'package:app/movies/domain/models/movie_base.dart';

class UpNextData {
  const UpNextData({
    required this.movie,
    required this.episode,
  });

  final MovieBaseData movie;

  final EpisodeData episode;
}
