import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_details.dart';

abstract interface class IEpisodesModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<MovieDetailsData?> get movie;

  void loadData({
    required int movieId,
  });
}

class EpisodesModel extends ElementaryModel implements IEpisodesModel {
  EpisodesModel({
    super.errorHandler,
    required MoviesRepository repository,
  }) : _repository = repository;

  final MoviesRepository _repository;

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<MovieDetailsData?> movie = ValueNotifier(null);

  @override
  Future<void> loadData({
    required int movieId,
  }) async {
    loading.value = true;
    movie.value = await _repository.getMovie(movieId);
    loading.value = false;
  }

  @override
  void dispose() {
    loading.dispose();
    movie.dispose();
    super.dispose();
  }
}
