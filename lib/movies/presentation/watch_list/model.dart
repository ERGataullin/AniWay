import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/watch_status.dart';
import 'package:elementary/elementary.dart';

abstract interface class IWatchListModel implements ElementaryModel {
  Future<void> saveWatchStatus({
    required int movieId,
    required WatchStatus status,
    required int score,
    required int episodes,
    required String comment,
  });
}

class WatchListModel extends ElementaryModel implements IWatchListModel {
  WatchListModel({super.errorHandler, required MoviesRepository repository})
    : _repository = repository;

  final MoviesRepository _repository;

  @override
  Future<void> saveWatchStatus({
    required int movieId,
    required WatchStatus status,
    required int score,
    required int episodes,
    required String comment,
  }) async {
    await _repository.saveWatchStatus(
      movieId: movieId,
      status: status,
      score: score,
      episodes: episodes,
      comment: comment,
    );
  }
}
