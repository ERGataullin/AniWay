import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movies/movies.dart';
import 'package:movies/src/domain/models/movie_preview.dart';
import 'package:movies/src/presentation/search/model.dart';

SearchWidgetModel searchWidgetModelFactory(BuildContext context) =>
    SearchWidgetModel(
      SearchModel(
        service: context.read<MoviesService>(),
      ),
    );

abstract interface class ISearchWidgetModel implements IWidgetModel {
  GlobalKey get globalKey;

  ValueListenable<bool> get showLoader;

  ValueListenable<String> get queryHint;

  ValueListenable<List<MoviePreviewData>> get movies;

  SearchController get queryController;

  ScrollController get scrollController;

  void onMoviePressed(int id);
}

class SearchWidgetModel extends WidgetModel<SearchWidget, ISearchModel>
    implements ISearchWidgetModel {
  SearchWidgetModel(super._model);

  static const Duration _queryDebounceInterval = Duration(milliseconds: 300);

  @override
  final GlobalKey globalKey = GlobalKey();

  @override
  final ValueNotifier<String> queryHint = ValueNotifier('');

  @override
  final SearchController queryController = SearchController();

  @override
  final ScrollController scrollController = ScrollController();

  @override
  ValueListenable<bool> get showLoader => model.loading;

  @override
  ValueListenable<List<MoviePreviewData>> get movies => model.movies;

  String _query = '';

  Timer? _queryDebounceTimer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    _loadMovies();
    queryController.addListener(_onQueryChanged);
    scrollController.addListener(_onScrollChanged);
  }

  @override
  void didChangeDependencies() {
    _updateQueryHint();
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  void _onQueryChanged() {
    if (_query == queryController.text) {
      return;
    }

    _query = queryController.text;
    _queryDebounceTimer?.cancel();
    _queryDebounceTimer = Timer(
      _queryDebounceInterval,
      () => model.loadMovies(query: _query, reload: true),
    );
  }

  void _onScrollChanged() {
    final bool scrolledToEnd = scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;

    if (!scrolledToEnd) {
      return;
    }

    model.loadMovies(query: _query);
  }

  @override
  void dispose() {
    super.dispose();
    queryHint.dispose();
    queryController.dispose();
    scrollController.dispose();
    _queryDebounceTimer?.cancel();
  }

  void _updateQueryHint() {
    queryHint.value = context.localizations.searchSearchBarHint;
  }

  Future<void> _loadMovies() async {
    do {
      model.loadMovies(query: _query);
    } while(scrollController.position.maxScrollExtent < globalKey.currentContext!.size!.height);
  }
}
