import 'package:core/core.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class ISearchModel implements ElementaryModel {
  int get defaultMoviesLimit;

  Future<List<MoviePreviewData>> getMovies({
    String? query,
    int? offset,
  });
}

class SearchModel extends ElementaryModel implements ISearchModel {
  SearchModel({
    required MoviesService service,
  }) : _service = service;

  @override
  int get defaultMoviesLimit => _service.defaultMoviesLimit;

  final MoviesService _service;

  @override
  Future<List<MoviePreviewData>> getMovies({
    String? query,
    int? offset,
  }) {
    return _service.getMovies(
      query: query,
      offset: offset,
    );
  }
}
