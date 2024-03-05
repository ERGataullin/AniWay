import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class ISearchModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<MoviePreviewData>> get movies;

  Future<void> loadMovies({
    required String query,
    bool reload = false,
  });
}

class SearchModel extends ElementaryModel implements ISearchModel {
  SearchModel({
    required MoviesService service,
  }) : _service = service;

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<MoviePreviewData>> movies = ValueNotifier(const []);

  final MoviesService _service;

  final List<MoviePreviewData> _movies = [];

  bool _hasNextPage = true;

  int _page = 1;

  @override
  void dispose() {
    loading.dispose();
    movies.dispose();
  }

  @override
  Future<void> loadMovies({
    required String query,
    bool reload = false,
  }) async {
    if (loading.value || !_hasNextPage && !reload) {
      return;
    }

    loading.value = true;
    if (reload) {
      _page = 1;
      _movies.clear();
      movies.value = const [];
    }

    final List<MoviePreviewData> newMovies = await _service.getMovies(
      query: query,
      offset: (_page - 1) * _service.defaultMoviesLimit,
    );

    _page++;
    _hasNextPage = newMovies.length >= _service.defaultMoviesLimit;
    _movies.addAll(newMovies);
    movies.value = List.unmodifiable(_movies);
    loading.value = false;
  }
}
