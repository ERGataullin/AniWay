import 'package:movies/src/domain/models/movie_episode.dart';
import 'package:movies/src/domain/models/up_next_movie.dart';

class UpNextData {
  const UpNextData({
    required this.movie,
    required this.episode,
  });

  final UpNextMovieData movie;
  final MovieEpisodeData episode;
}
