abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    List<String?> watchStatus = const [],
    String? query,
  });

  Future<List<Map<String, dynamic>>> getUpNext();
}
