import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movies_order.dart';
import 'package:app/movies/domain/models/watch_status.dart';

abstract interface class ILibraryModel implements ElementaryModel {
  Future<List<MovieBaseData>> getMovies({
    required int page,
    required List<WatchStatus> statuses,
  });
}

class LibraryModel extends ElementaryModel implements ILibraryModel {
  LibraryModel({super.errorHandler, required MoviesRepository repository})
    : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<List<MovieBaseData>> getMovies({
    required int page,
    required List<WatchStatus> statuses,
  }) {
    return _repository.getMovies(
      order: MoviesOrder.byName,
      page: page,
      watchStatuses: statuses,
    );
  }
}
