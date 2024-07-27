import 'package:movies/src/data/dto/up_next.dart';
import 'package:movies/src/domain/models/episode.dart';
import 'package:movies/src/domain/models/movie_base.dart';

class UpNextData {
  const UpNextData({
    required this.movie,
    required this.episode,
  });

  factory UpNextData.fromDto(UpNextDto dto) => UpNextData(
        movie: MovieBaseData.fromDto(dto.movie),
        episode: EpisodeData.fromDto(dto.episode),
      );

  final MovieBaseData movie;

  final EpisodeData episode;
}
