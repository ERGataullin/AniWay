import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  ValueListenable<String> get hintText;

  ValueListenable<List<MoviePreviewData>> get movies;

  ValueListenable<bool> get showLoader;

  SearchController get queryController;

  ScrollController get scrollController;

  void onMoviePressed(int id);
}

class SearchWidgetModel extends WidgetModel<SearchWidget, ISearchModel>
    implements ISearchWidgetModel {
  SearchWidgetModel(super._model);

  static const Duration _queryDebounceInterval = Duration(milliseconds: 300);

  @override
  final ValueNotifier<String> hintText = ValueNotifier('');

  @override
  final ValueNotifier<List<MoviePreviewData>> movies = ValueNotifier(const []);

  @override
  final ValueNotifier<bool> showLoader = ValueNotifier(false);

  @override
  final SearchController queryController = SearchController();

  @override
  late final ScrollController scrollController = ScrollController()
    ..addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          _hasNextPage) {
        _loadMovies();
      }
    });

  int _page = 1;

  bool _hasNextPage = true;

  Timer? _queryDebounceTimer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    queryController.addListener(_onQueryChanged);
  }

  @override
  void didChangeDependencies() {
    hintText.value = context.localizations.searchSearchBarHint;
  }

  @override
  void onMoviePressed(int id) {
    widget.onMoviePressed(id);
  }

  @override
  void dispose() {
    super.dispose();
    _queryDebounceTimer?.cancel();
    hintText.dispose();
    movies.dispose();
    showLoader.dispose();
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

  Future<void> _loadMovies({
    bool reload = false,
  }) async {
    if (!_hasNextPage && !reload) {
      return;
    }

    showLoader.value = true;
    if (reload) {
      _page = 1;
      movies.value = const [];
    }

    final List<MoviePreviewData> newMovies = await model.getMovies(
      query: queryController.text,
      offset: (_page - 1) * model.defaultMoviesLimit,
    );
    _page++;
    _hasNextPage = newMovies.length >= model.defaultMoviesLimit;
    movies.value = [...movies.value, ...newMovies];
    showLoader.value = false;
  }
}
