import 'package:movies/movies.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    List<String?> watchStatus = const [],
    String? query,
  }) {
    return _remote.getMovies(
      order: order,
      watchStatus: watchStatus,
      query: query,
    );
  }

  Future<List<Map<String, dynamic>>> getUpNext() {
    return _remote.getUpNext();
  }
}
