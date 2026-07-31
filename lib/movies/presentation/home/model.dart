import 'package:app/core/core.dart';
import 'package:app/movies/data/repository.dart';
import 'package:app/movies/domain/models/movie_base.dart';
import 'package:app/movies/domain/models/movie_type.dart';
import 'package:app/movies/domain/models/up_next.dart';
import 'package:flutter/foundation.dart';

abstract interface class IHomeModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<UpNextData>> get upNext;

  ValueListenable<List<MovieBaseData>> get ongoings;

  ValueListenable<List<MovieBaseData>> get populars;

  Future<void> refresh();
}

class HomeModel extends ElementaryModel implements IHomeModel {
  HomeModel({super.errorHandler, required this._repository});

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<UpNextData>> upNext = ValueNotifier(const []);

  @override
  final ValueNotifier<List<MovieBaseData>> ongoings = ValueNotifier(const []);

  @override
  final ValueNotifier<List<MovieBaseData>> populars = ValueNotifier(const []);

  final MoviesRepository _repository;

  @override
  Future<void> refresh() async {
    final Future<List<UpNextData>> newUpNextFuture = _repository.getUpNext();
    final Future<List<MovieBaseData>> newOngoingFuture = _repository.getMovies(
      isOngoing: true,
      typesExcluded: const [MovieType.ad, MovieType.music, MovieType.preview],
    );
    final Future<List<MovieBaseData>> newPopularFuture =
        _repository.getMovies();

    final List<UpNextData> upNext = await newUpNextFuture;
    final List<MovieBaseData> ongoings = await newOngoingFuture;
    final List<MovieBaseData> populars = await newPopularFuture;

    this.upNext.value = List.unmodifiable(upNext.take(10));
    this.ongoings.value = List.unmodifiable(ongoings.take(10));
    this.populars.value = List.unmodifiable(populars.take(10));
  }

  @override
  void init() {
    _load();
    _repository.upNextChanges.addListener(_load);
  }

  @override
  void dispose() {
    _repository.upNextChanges.removeListener(_load);
    loading.dispose();
    upNext.dispose();
    ongoings.dispose();
    populars.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    loading.value = true;
    await refresh();
    loading.value = false;
  }
}
