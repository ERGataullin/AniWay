import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IHomeModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<UpNextData>> get upNext;

  ValueListenable<List<MovieBaseData>> get mostPopular;
}

class HomeModel extends ElementaryModel implements IHomeModel {
  HomeModel(
    ErrorHandler errorHandler, {
    required MoviesService service,
  })  : _service = service,
        super(errorHandler: errorHandler);

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<UpNextData>> upNext = ValueNotifier(const []);

  @override
  final ValueNotifier<List<MovieBaseData>> mostPopular = ValueNotifier(
    const [],
  );

  final MoviesService _service;

  final List<UpNextData> _upNext = [];

  final List<MovieBaseData> _mostPopular = [];

  @override
  void init() {
    _load();
  }

  @override
  void dispose() {
    super.dispose();
    loading.dispose();
    upNext.dispose();
    mostPopular.dispose();
  }

  Future<void> _load() async {
    loading.value = true;

    final Future<List<UpNextData>> newUpNextFuture = _service.getUpNext();
    final Future<List<MovieBaseData>> newMostPopularFuture =
        _service.getMovies(order: MovieOrderData.byPopularity);

    final List<UpNextData> newUpNext = await newUpNextFuture;
    final List<MovieBaseData> newMostPopular = await newMostPopularFuture;

    _upNext
      ..clear()
      ..addAll(newUpNext);
    _mostPopular
      ..clear()
      ..addAll(newMostPopular);
    loading.value = false;
    upNext.value = List.unmodifiable(_upNext);
    mostPopular.value = List.unmodifiable(_mostPopular);
  }
}
