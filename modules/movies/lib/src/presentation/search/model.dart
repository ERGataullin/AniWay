import 'package:elementary/elementary.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class ISearchModel implements ElementaryModel {
  Future<List<MoviePreviewData>> getMovies({
    String? query,
    String? limit,
    String? offset,
  });
}

class SearchModel extends ElementaryModel implements ISearchModel {
  SearchModel({
    required MoviesService service,
  }) : _service = service;

  final MoviesService _service;

  @override
  Future<List<MoviePreviewData>> getMovies({
    String? query,
    String? limit,
    String? offset,
  }) {
    return _service.getMovies(
      query: query,
      limit: limit,
      offset: offset,
    );
  }
}
