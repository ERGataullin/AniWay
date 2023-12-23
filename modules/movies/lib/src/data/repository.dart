import 'package:movies/movies.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    String? limit,
    String? offset,
    List<String?> watchStatus = const [],
  }) {
    return _remote.getMovies(
      order: order,
      query: query,
      limit: limit,
      offset: offset,
      watchStatus: watchStatus,
    );
  }

  Future<List<Map<String, dynamic>>> getUpNext() {
    return _remote.getUpNext();
  }
}
