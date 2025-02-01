import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IUpNextModel implements ElementaryModel {
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  Future<List<UpNextData>> loadPage({required int page});
}

class UpNextModel extends ElementaryModel implements IUpNextModel {
  UpNextModel({
    super.errorHandler,
    required MoviesRepository repository,
  }) : _repository = repository;

  final MoviesRepository _repository;

  @override
  void addListener(VoidCallback listener) {
    _repository.upNextChanges.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _repository.upNextChanges.removeListener(listener);
  }

  @override
  Future<List<UpNextData>> loadPage({required int page}) {
    return _repository.getUpNext(page: page);
  }
}
