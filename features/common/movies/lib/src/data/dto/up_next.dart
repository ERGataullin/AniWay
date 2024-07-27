import 'package:movies/src/data/dto/episode.dart';
import 'package:movies/src/data/dto/movie_base.dart';

class UpNextDto {
  const UpNextDto({
    required this.movie,
    required this.episode,
  });

  final MovieBaseDto movie;

  final EpisodeDto episode;
}
