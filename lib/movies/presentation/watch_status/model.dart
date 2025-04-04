import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/watch_status_details.dart';
import 'package:elementary/elementary.dart';

abstract interface class IWatchStatusModel implements ElementaryModel {
  Future<void> save({required int movieId, required WatchStatusDetails status});
}

class WatchStatusModel extends ElementaryModel implements IWatchStatusModel {
  WatchStatusModel({super.errorHandler, required MoviesRepository repository})
    : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<void> save({
    required int movieId,
    required WatchStatusDetails status,
  }) async {
    await _repository.saveWatchStatus(movieId: movieId, status: status);
  }
}
