import 'package:movies/src/data/dto/movie_type.dart';

enum MovieType {
  tv,
  movie,
  ova,
  ona,
  special,
  tvSpecial,
  ad,
  music,
  preview;

  factory MovieType.fromDto(MovieTypeDto dto) => switch (dto) {
        MovieTypeDto.tv => MovieType.tv,
        MovieTypeDto.movie => MovieType.movie,
        MovieTypeDto.ova => MovieType.ova,
        MovieTypeDto.ona => MovieType.ona,
        MovieTypeDto.special => MovieType.special,
        MovieTypeDto.tvSpecial => MovieType.tvSpecial,
        MovieTypeDto.ad => MovieType.ad,
        MovieTypeDto.music => MovieType.music,
        MovieTypeDto.preview => MovieType.preview,
      };
}
