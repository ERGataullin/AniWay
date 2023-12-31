import 'package:core/core.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IWatchNowModel implements ElementaryModel {
  Future<List<UpNextData>> getUpNextItems();

  Future<List<MoviePreviewData>> getMostPopularItems();
}

class WatchNowModel extends ElementaryModel implements IWatchNowModel {
  WatchNowModel(
    ErrorHandler errorHandler, {
    required MoviesService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  final MoviesService _service;

  @override
  Future<List<UpNextData>> getUpNextItems() {
    return _service.getUpNext();
  }

  @override
  Future<List<MoviePreviewData>> getMostPopularItems() {
    return _service.getMovies(
      order: MovieOrderData.byPopularity,
    );
  }
}
