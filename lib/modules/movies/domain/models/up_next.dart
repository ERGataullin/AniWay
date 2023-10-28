import '/modules/movies/domain/models/movie_episode.dart';
import '/modules/movies/domain/models/up_next_movie.dart';

export '/modules/movies/domain/models/movie_episode.dart';
export '/modules/movies/domain/models/up_next_movie.dart';

class UpNextData {
  const UpNextData({
    required this.movie,
    required this.episode,
  });

  final UpNextMovieData movie;
  final MovieEpisodeData episode;
}
