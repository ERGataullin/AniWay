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

  final MoviesService _service;

  final List<MoviePreviewData> _movies = [];

  Timer? _queryDebounceTimer;

  @override
  void init() {
    queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryDebounceTimer?.cancel();
    loading.dispose();
    movies.dispose();
    queryController.dispose();
  }

  void _onQueryChanged() {
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(_queryDebounceInterval, _reloadMovies);
  }

  Future<void> _reloadMovies() async {
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = null;
    loading.value = true;
    _movies.clear();
    movies.value = List.unmodifiable(_movies);

    final List<MoviePreviewData> newMovies = await _service.getMovies(
      query: queryController.text,
    );

    _movies.addAll(newMovies);
    loading.value = false;
    movies.value = List.unmodifiable(_movies);
  }
}
