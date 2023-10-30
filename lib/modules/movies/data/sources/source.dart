abstract interface class MoviesDataSource {
  const MoviesDataSource();

  Future<List<Map<String, dynamic>>> getMovies({
    String? order,
    List<String?> watchStatus = const [],
  });

  Future<List<Map<String, dynamic>>> getUpNext();
}
