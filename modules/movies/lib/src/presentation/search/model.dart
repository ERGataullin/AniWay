import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/domain/service/service.dart';

abstract interface class ISearchModel implements ElementaryModel {
  ValueListenable<bool> get loading;

  ValueListenable<List<MoviePreviewData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;
}

class SearchModel extends ElementaryModel implements ISearchModel {
  SearchModel({
    required MoviesService service,
  }) : _service = service;

  static const Duration _queryDebounceInterval = Duration(milliseconds: 300);

  @override
  final ValueNotifier<bool> loading = ValueNotifier(false);

  @override
  final ValueNotifier<List<MoviePreviewData>> movies = ValueNotifier(const []);

  @override
  final SearchController queryController = SearchController();

  @override
  final ScrollController scrollController = ScrollController();

  final MoviesService _service;

  final List<MoviePreviewData> _movies = [];

  bool _hasNextPage = true;

  int _page = 1;

  Timer? _queryDebounceTimer;

  @override
  void init() {
    queryController.addListener(_onQueryChanged);
    scrollController.addListener(_onScrollChanged);
  }

  @override
  void dispose() {
    _queryDebounceTimer?.cancel();
    loading.dispose();
    movies.dispose();
    queryController.dispose();
    scrollController.dispose();
  }

  void _onQueryChanged() {
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(
      _queryDebounceInterval,
      () => _loadMovies(reload: true),
    );
  }

  void _onScrollChanged() {
    final bool scrolledToEnd = scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;

    if (!scrolledToEnd) {
      return;
    }

    _loadMovies();
  }

  Future<void> _loadMovies({
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
      query: queryController.text,
      offset: (_page - 1) * _service.defaultMoviesLimit,
    );

    _page++;
    _hasNextPage = newMovies.length >= _service.defaultMoviesLimit;
    _movies.addAll(newMovies);
    movies.value = List.unmodifiable(_movies);
    loading.value = false;
  }
}
