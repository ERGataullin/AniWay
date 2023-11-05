export '/modules/movies/domain/models/movie_type.dart';

class UpNextMovieData {
  const UpNextMovieData({
    required this.id,
    required this.title,
    required this.posterUri,
  });

  final int id;
  final String title;
  final Uri posterUri;
}
