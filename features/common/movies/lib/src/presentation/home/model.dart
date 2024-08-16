import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/models/up_next.dart';

abstract interface class IHomeModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<UpNextData>> get upNext;

  ValueListenable<List<MovieBaseData>> get ongoings;

  ValueListenable<List<MovieBaseData>> get populars;
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
  final ValueNotifier<List<MovieBaseData>> ongoings = ValueNotifier(const []);

  @override
  final ValueNotifier<List<MovieBaseData>> populars = ValueNotifier(
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
    ongoings.dispose();
    populars.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    loading.value = true;

    final Future<List<UpNextData>> newUpNextFuture = _service.getUpNext();
    final Future<List<MovieBaseData>> newOngoingFuture =
        _service.getMovies(isOngoing: true);
    final Future<List<MovieBaseData>> newPopularFuture = _service.getMovies();

    final List<UpNextData> upNext = await newUpNextFuture;
    final List<MovieBaseData> ongoings = await newOngoingFuture;
    final List<MovieBaseData> populars = await newPopularFuture;

    this.upNext.value = List.unmodifiable(upNext.take(10));
    this.ongoings.value = List.unmodifiable(ongoings.take(10));
    this.populars.value = List.unmodifiable(populars.take(10));
    loading.value = false;
  }
}
