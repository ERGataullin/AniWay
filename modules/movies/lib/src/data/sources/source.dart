abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    String? query,
    List<String?> watchStatus = const [],
  });

  Future<List<Map<String, dynamic>>> getUpNext();
}
