import 'package:movies/movies.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    List<String?> watchStatus = const [],
  }) {
    return _remote.getMovies(
      order: order,
      query: query,
      watchStatus: watchStatus,
    );
  }

  Future<List<Map<String, dynamic>>> getUpNext() {
    return _remote.getUpNext();
  }
}
