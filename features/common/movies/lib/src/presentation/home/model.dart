import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/movie_order.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IHomeModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<UpNextData>> get upNext;

  ValueListenable<List<MovieBaseData>> get popular;
}

class HomeModel extends ElementaryModel implements IHomeModel {
  HomeModel({
    super.errorHandler,
    required MoviesService service,
  }) : _service = service;

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<UpNextData>> upNext = ValueNotifier(const []);

  @override
  final ValueNotifier<List<MovieBaseData>> popular = ValueNotifier(
    const [],
  );

  final MoviesService _service;

  @override
  void init() {
    _load();
    _service.upNextChanges.addListener(_load);
  }

  @override
  void dispose() {
    _service.upNextChanges.removeListener(_load);
    loading.dispose();
    upNext.dispose();
    popular.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    loading.value = true;

    final Future<List<UpNextData>> newUpNextFuture = _service.getUpNext();
    final Future<List<MovieBaseData>> newPopularFuture =
        _service.getMovies(order: MovieOrder.byPopularity);

    final List<UpNextData> upNext = await newUpNextFuture;
    final List<MovieBaseData> popular = await newPopularFuture;

    loading.value = false;
    this.upNext.value = List.unmodifiable(upNext.take(10));
    this.popular.value = List.unmodifiable(popular.take(10));
  }
}
