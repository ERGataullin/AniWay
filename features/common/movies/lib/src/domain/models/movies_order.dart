import 'package:movies/src/data/dto/movies_order.dart';

enum MoviesOrder {
  byScore,
  byPopularity,
  byName,
  byReleaseDate,
  random;

  MoviesOrderDto toDto() => switch (this) {
        MoviesOrder.byScore => MoviesOrderDto.byScore,
        MoviesOrder.byPopularity => MoviesOrderDto.byPopularity,
        MoviesOrder.byName => MoviesOrderDto.byName,
        MoviesOrder.byReleaseDate => MoviesOrderDto.byReleaseDate,
        MoviesOrder.random => MoviesOrderDto.random,
      };
}
