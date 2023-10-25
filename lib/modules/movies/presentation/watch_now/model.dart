import 'package:elementary/elementary.dart';

import '/modules/movies/domain/models/movie_preview.dart';
import '/modules/movies/domain/service/service.dart';

abstract interface class IWatchNowModel implements ElementaryModel {
  Future<List<MoviePreviewData>> getUpNextMovies();

  Future<List<MoviePreviewData>> getMostPopularMovies();
}

class WatchNowModel extends ElementaryModel implements IWatchNowModel {
  WatchNowModel(
    ErrorHandler errorHandler, {
    required MoviesService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final MoviesService _service;

  @override
  Future<List<MoviePreviewData>> getUpNextMovies() {
    return _service.getMovies();
  }

  @override
  Future<List<MoviePreviewData>> getMostPopularMovies() {
    return _service.getMovies();
  }
}
