import '/modules/movies/data/sources/source.dart';

class MoviesRepository {
  const MoviesRepository({
    required MoviesDataSource remote,
  }) : _remote = remote;

  final MoviesDataSource _remote;

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    List<String?> watchStatus = const [],
  }) {
    return _remote.getMovies(
      order: order,
      watchStatus: watchStatus,
    );
  }

  Future<List<Map<String, dynamic>>> getUpNext() {
    return _remote.getUpNext();
  }
}
