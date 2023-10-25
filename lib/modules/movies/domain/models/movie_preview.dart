import '/modules/movies/domain/models/movie_type.dart';

class MoviePreviewData {
  const MoviePreviewData({
    required this.id,
    required this.title,
    required this.posterUri,
    required this.type,
    required this.score,
  });

  final int id;
  final String title;
  final Uri posterUri;
  final MovieTypeData type;
  final double score;
}
