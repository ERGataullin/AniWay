import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_base.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class ISearchModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<MovieBaseData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;

  set scrollController(ScrollController value);
}

class SearchModel extends ElementaryModel implements ISearchModel {
  SearchModel({
    required MoviesService service,
  }) : _service = service;

  static const Duration _queryDebounceInterval = Duration(milliseconds: 300);

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<MovieBaseData>> movies = ValueNotifier(const []);

  @override
  final SearchController queryController = SearchController();

  final MoviesService _service;

  final List<MovieBaseData> _movies = [];

  ScrollController? _scrollController;

  bool _hasNextPage = true;

  String _query = '';

  Timer? _queryDebounceTimer;

  @override
  ScrollController get scrollController => _scrollController!;

  @override
  set scrollController(ScrollController value) {
    _scrollController?.removeListener(_ensureHasScrollReserve);
    _scrollController = value..addListener(_ensureHasScrollReserve);
  }

  @override
  void init() {
    _loadMovies();
    queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryDebounceTimer?.cancel();
    scrollController.removeListener(_ensureHasScrollReserve);
    loading.dispose();
    movies.dispose();
    queryController.dispose();
  }

  void _onQueryChanged() {
    if (_query == queryController.text) {
      return;
    }

    _query = queryController.text;
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(
      _queryDebounceInterval,
      () => _loadMovies(reload: true),
    );
  }

  void _ensureHasScrollReserve() {
    final bool hasScrollReserve = scrollController.position.extentAfter >
        scrollController.position.viewportDimension;
    if (!hasScrollReserve) {
      _loadMovies();
    }
  }

  Future<void> _loadMovies({
    bool reload = false,
  }) async {
    if (loading.value || !_hasNextPage && !reload) {
      return;
    }

    loading.value = true;
    if (reload) {
      _movies.clear();
      movies.value = const [];
    }

    final List<MovieBaseData> newMovies = await _service.getMovies(
      query: queryController.text,
      offset: _movies.length,
    );

    _hasNextPage = newMovies.length >= _service.defaultMoviesLimit;
    _movies.addAll(newMovies);
    movies.value = List.unmodifiable(_movies);
    loading.value = false;

    await WidgetsBinding.instance.endOfFrame;
    _ensureHasScrollReserve();
  }
}
